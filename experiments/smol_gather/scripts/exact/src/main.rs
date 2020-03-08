use std::collections::HashSet;
use std::fs::File;
use std::io::{BufReader, BufWriter};

use bincode::{deserialize_from, serialize_into};
use needletail::{parse_sequence_path, Sequence};
use structopt::StructOpt;

#[derive(StructOpt)]
enum Cli {
    Generate {
        /// The path to the file to read
        #[structopt(parse(from_os_str))]
        path: std::path::PathBuf,

        /// ksize
        #[structopt(short = "k", long = "ksize", default_value = "21")]
        ksize: u8,

        /// The path for output
        #[structopt(parse(from_os_str))]
        output: std::path::PathBuf,
    },
    Containment {
        /// Path to metagenome k-mer set
        #[structopt(parse(from_os_str))]
        mg_path: std::path::PathBuf,

        /// Paths to reference genomes k-mer sets
        #[structopt(parse(from_os_str))]
        refs_paths: Vec<std::path::PathBuf>,
    },
}

fn main() {
    match Cli::from_args() {
        Cli::Generate {
            path,
            ksize,
            output,
        } => {
            let mut kmers: HashSet<Vec<u8>> = HashSet::new();

            parse_sequence_path(
                path,
                |_| {},
                |seq| {
                    let norm_seq = seq.normalize(false);
                    let rc = norm_seq.reverse_complement();
                    for (_, kmer, _) in norm_seq.canonical_kmers(ksize, &rc) {
                        kmers.insert(kmer.into());
                    }
                },
            )
            .expect("Error parsing input");

            let mut f = BufWriter::new(File::create(output).unwrap());
            serialize_into(&mut f, &kmers).unwrap();
        }
        Cli::Containment {
            mg_path,
            refs_paths,
        } => {
            let f = BufReader::new(File::open(mg_path).unwrap());
            let mg: HashSet<Vec<u8>> = deserialize_from(f).unwrap();

            for ref_path in refs_paths {
                let f = BufReader::new(File::open(&ref_path).unwrap());
                let reference: HashSet<Vec<u8>> = deserialize_from(f).unwrap();

                let intersection = reference.intersection(&mg).count();
                println!(
                    "{:?}, {}, {}, {}",
                    ref_path,
                    intersection as f64 / reference.len() as f64,
                    intersection,
                    reference.len(),
                );
            }
        }
    };
}
