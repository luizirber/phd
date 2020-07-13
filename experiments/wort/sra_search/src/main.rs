use std::fs::File;
use std::io::{BufRead, BufReader, BufWriter, Write};
use std::path::{Path, PathBuf};
use std::sync::atomic::{AtomicUsize, Ordering};

use log::info;
use rayon::prelude::*;
use sourmash::signature::{Signature, SigsTrait};
use sourmash::sketch::minhash::{max_hash_for_scaled, KmerMinHash};
use sourmash::sketch::Sketch;
use structopt::StructOpt;

#[derive(StructOpt, Debug)]
struct Cli {
    /// List of queries (one sig per file)
    #[structopt(parse(from_os_str))]
    querylist: PathBuf,

    /// List of signatures to search
    #[structopt(parse(from_os_str))]
    siglist: PathBuf,

    /// ksize
    #[structopt(short = "k", long = "ksize", default_value = "31")]
    ksize: u8,

    /// threshold
    #[structopt(short = "t", long = "threshold", default_value = "0.85")]
    threshold: f64,

    /// scaled
    #[structopt(short = "s", long = "scaled", default_value = "1000")]
    scaled: usize,

    /// The path for output
    #[structopt(parse(from_os_str), short = "o", long = "output")]
    output: Option<PathBuf>,
}

fn search<P: AsRef<Path>>(
    querylist: P,
    siglist: P,
    threshold: f64,
    ksize: u8,
    scaled: usize,
) -> Result<Vec<(String, String, f64)>, Box<dyn std::error::Error>> {
    info!("Loading queries");

    let querylist_file = BufReader::new(File::open(querylist)?);
    let query_sigs: Vec<PathBuf> = querylist_file
        .lines()
        .map(|line| {
            let mut path = PathBuf::new();
            path.push(line.unwrap());
            path
        })
        .collect();

    let max_hash = max_hash_for_scaled(scaled as u64).unwrap();
    let template_mh = KmerMinHash::builder()
        .num(0u32)
        .ksize(ksize as u32)
        .max_hash(max_hash)
        .build();
    let template = Sketch::MinHash(template_mh);

    let queries: Vec<(String, KmerMinHash)> = query_sigs
        .into_iter()
        .filter_map(|query| {
            let query_sig = Signature::from_path(query).unwrap();

            let mut query = None;
            for sig in &query_sig {
                if let Some(sketch) = sig.select_sketch(&template) {
                    if let Sketch::MinHash(mh) = sketch {
                        query = Some((sig.name(), mh.clone()));
                    }
                }
            }
            query
        })
        .collect();
    info!("Loaded {} query signatures", queries.len());

    info!("Loading siglist");
    let siglist_file = BufReader::new(File::open(siglist)?);
    let search_sigs: Vec<PathBuf> = siglist_file
        .lines()
        .map(|line| {
            let mut path = PathBuf::new();
            path.push(line.unwrap());
            path
        })
        .collect();
    info!("Loaded {} sig paths in siglist", search_sigs.len());

    let processed_sigs = AtomicUsize::new(0);

    Ok(search_sigs
        .par_iter()
        .filter_map(|filename| {
            let i = processed_sigs.fetch_add(1, Ordering::SeqCst);
            if i % 1000 == 0 {
                info!("Processed {} search sigs", i);
            }

            let mut search_mh = None;
            let search_sig = &Signature::from_path(&filename).unwrap()[0];
            if let Some(sketch) = search_sig.select_sketch(&template) {
                if let Sketch::MinHash(mh) = sketch {
                    search_mh = Some(mh);
                }
            }
            let search_mh = search_mh.unwrap();

            let match_fn = filename.clone().into_os_string().into_string().unwrap();
            let mut results = vec![];

            for (name, query) in &queries {
                let containment =
                    query.count_common(search_mh, false).unwrap() as f64 / query.size() as f64;
                if containment > threshold {
                    results.push((name.clone(), match_fn.clone(), containment))
                }
            }
            if results.is_empty() {
                None
            } else {
                Some(results)
            }
        })
        .flatten()
        .collect())
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    env_logger::Builder::from_env(env_logger::Env::default().default_filter_or("info")).init();

    let opts = Cli::from_args();

    let matches = search(
        opts.querylist,
        opts.siglist,
        opts.threshold,
        opts.ksize,
        opts.scaled,
    )?;

    let mut out: Box<dyn Write> = match opts.output {
        Some(path) => Box::new(BufWriter::new(File::create(path)?)),
        None => Box::new(std::io::stdout()),
    };

    for m in matches {
        writeln!(&mut out, "'{}','{}',{}", m.0, m.1, m.2)?;
    }

    Ok(())
}
