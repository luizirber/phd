use std::collections::HashSet;
use std::fs::File;
use std::io::{BufReader, BufWriter, Write};
use std::path::{Path, PathBuf};

use murmurhash3::murmurhash3_x64_128;
use needletail::{parse_sequence_path, Sequence};
use serde::{Deserialize, Serialize};
use serde_json;
use structopt::StructOpt;

#[derive(Serialize, Deserialize, Clone)]
struct ScaledMinHash {
    hashes: HashSet<u64>,
    max_hash: u64,
    k: usize,
    name: Option<String>,
    filename: Option<String>,
}

trait Gatherable {
    fn containment(&self, other: &Self) -> f64;
    fn subtract(&mut self, other: &Self);
}

impl ScaledMinHash {
    fn new(k: usize, scaled: usize, name: Option<String>, filename: Option<String>) -> Self {
        let max_hash = (u64::max_value() as f64 / scaled as f64) as u64;
        ScaledMinHash {
            max_hash,
            hashes: Default::default(),
            k,
            name,
            filename,
        }
    }

    fn add(&mut self, hash: u64) {
        if hash <= self.max_hash {
            self.hashes.insert(hash);
        }
    }

    fn save<P: AsRef<Path>>(&self, out: P) -> Result<(), Box<dyn std::error::Error>> {
        let mut f = BufWriter::new(File::create(out)?);
        serde_json::to_writer(&mut f, &self)?;
        Ok(())
    }

    fn load<P: AsRef<Path>>(filename: P) -> Result<Self, Box<dyn std::error::Error>> {
        let f = BufReader::new(File::open(filename)?);
        let mh = serde_json::from_reader(f)?;
        Ok(mh)
    }
}

impl Gatherable for ScaledMinHash {
    fn containment(&self, other: &ScaledMinHash) -> f64 {
        assert_eq!(self.k, other.k);
        assert_eq!(self.max_hash, other.max_hash);
        self.hashes.intersection(&other.hashes).count() as f64 / self.hashes.len() as f64
    }

    fn subtract(&mut self, other: &ScaledMinHash) {
        self.hashes = &self.hashes - &other.hashes;
    }
}

fn compute(
    filename: PathBuf,
    ksize: u8,
    scaled: usize,
    output: Option<PathBuf>,
) -> Result<(), Box<dyn std::error::Error>> {
    let mut mh = ScaledMinHash::new(
        ksize as usize,
        scaled,
        None,
        Some(filename.to_string_lossy().into()),
    );
    let mut name = None;

    parse_sequence_path(
        &filename,
        |_| {},
        |seq| {
            if name.is_none() {
                name = Some(String::from_utf8(seq.id.to_vec()).expect("Invalid sequence ID"));
            }
            let norm_seq = seq.normalize(false);
            let rc = norm_seq.reverse_complement();
            for (_, kmer, _) in norm_seq.canonical_kmers(ksize, &rc) {
                let hash = murmurhash3_x64_128(kmer, 42).0;
                mh.add(hash);
            }
        },
    )?;

    let out = output.unwrap_or_else(move || {
        let mut name = filename.file_name().unwrap().to_owned();
        name.push(".smol");
        filename.with_file_name(name)
    });

    mh.name = name;
    mh.save(out)?;

    Ok(())
}

fn find_best_contained<'a, T: Gatherable>(
    query: &T,
    collection: &'a [T],
    threshold: f64,
) -> Option<&'a T> {
    let mut best_containment = threshold;
    let mut best_match = None;

    for sig in collection {
        let containment = query.containment(&sig);
        if containment > best_containment {
            best_containment = containment;
            best_match = Some(sig);
        }
    }

    best_match
}

fn summarize_matches<W: Write>(
    matches: &[(&ScaledMinHash, f64, f64)],
    mut output: W,
) -> Result<(), Box<dyn std::error::Error>> {
    for m in matches {
        writeln!(
            &mut output,
            "'{}',{},{}",
            m.0.filename.as_ref().unwrap(),
            m.1,
            m.2
        )?;
    }
    Ok(())
}

fn search(
    query: PathBuf,
    signatures: &[PathBuf],
    output: Option<PathBuf>,
    threshold: f64,
) -> Result<(), Box<dyn std::error::Error>> {
    let collection: Vec<_> = signatures
        .iter()
        .map(|path| ScaledMinHash::load(path).expect("Error loading sketch"))
        .collect();

    let query = ScaledMinHash::load(query)?;

    let mut matches = vec![];

    for sig in &collection {
        let containment = sig.containment(&query);
        if containment > threshold {
            matches.push((sig, containment, containment));
        }
    }

    let mut out: Box<dyn Write> = match output {
        Some(path) => Box::new(BufWriter::new(File::create(path)?)),
        None => Box::new(std::io::stdout()),
    };

    summarize_matches(&matches, &mut out)?;

    Ok(())
}

fn gather(
    query: PathBuf,
    signatures: &[PathBuf],
    output: Option<PathBuf>,
    threshold: f64,
) -> Result<(), Box<dyn std::error::Error>> {
    let collection: Vec<_> = signatures
        .iter()
        .map(|path| ScaledMinHash::load(path).expect("Error loading sketch"))
        .collect();

    let original_query = ScaledMinHash::load(query)?;

    let mut query = original_query.clone();

    let mut matches = vec![];
    loop {
        match find_best_contained(&query, &collection, threshold) {
            None => break,
            Some(best) => {
                let containment = best.containment(&original_query);
                let f_match = best.containment(&query);
                query.subtract(&best);
                matches.push((best, containment, f_match));
            }
        }
    }

    let mut out: Box<dyn Write> = match output {
        Some(path) => Box::new(BufWriter::new(File::create(path)?)),
        None => Box::new(std::io::stdout()),
    };

    summarize_matches(&matches, &mut out)?;

    Ok(())
}

#[derive(StructOpt)]
enum Cli {
    Compute {
        /// The path to the file to read
        #[structopt(parse(from_os_str))]
        filename: PathBuf,

        /// ksize
        #[structopt(short = "k", long = "ksize", default_value = "21")]
        ksize: u8,

        /// scaled
        #[structopt(short = "s", long = "scaled", default_value = "1000")]
        scaled: usize,

        /// The path for output
        #[structopt(parse(from_os_str), short = "o", long = "output")]
        output: Option<PathBuf>,
    },
    Gather {
        /// Query signature
        #[structopt(parse(from_os_str))]
        query: PathBuf,

        /// Signatures to search
        #[structopt(parse(from_os_str))]
        signatures: Vec<PathBuf>,

        /// threshold
        #[structopt(short = "t", long = "threshold", default_value = "0.1")]
        threshold: f64,

        /// The path for output
        #[structopt(parse(from_os_str), short = "o", long = "output")]
        output: Option<PathBuf>,
    },
    Search {
        /// Query signature
        #[structopt(parse(from_os_str))]
        query: PathBuf,

        /// Signatures to search
        #[structopt(parse(from_os_str))]
        signatures: Vec<PathBuf>,

        /// threshold
        #[structopt(short = "t", long = "threshold", default_value = "0.1")]
        threshold: f64,

        /// The path for output
        #[structopt(parse(from_os_str), short = "o", long = "output")]
        output: Option<PathBuf>,
    },
}

fn main() {
    match Cli::from_args() {
        Cli::Compute {
            filename,
            ksize,
            scaled,
            output,
        } => {
            compute(filename, ksize, scaled, output).expect("Error running compute");
        }
        Cli::Gather {
            query,
            signatures,
            threshold,
            output,
        } => {
            gather(query, &signatures, output, threshold).expect("Error running gather");
        }
        Cli::Search {
            query,
            signatures,
            threshold,
            output,
        } => {
            search(query, &signatures, output, threshold).expect("Error running search");
        }
    };
}
