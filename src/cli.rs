use clap::{Parser, Subcommand};
use std::path::PathBuf;

#[derive(Debug, Parser)]
#[command(version, about)]
pub struct Cli {
	#[command(subcommand)]
	pub command: Commands,
}

#[derive(Debug, Subcommand)]
pub enum Commands {
	/// Print KakouneScript to initialize, then exit
	#[cfg(feature = "init")]
	Init,

	/// Print a highlighter for nested brackets of the passed file
	Highlight {
		/// List of Kakoune faces to descend through for each nest level
		#[arg(short, long, num_args = 1.., required = true)]
		faces: Vec<String>,

		/// File which contains '%val{selections}' of the window to be highlighted
		#[arg(short, long)]
		selections: PathBuf,

		/// File which contains '%val{selections_desc}' of the window to be highlighted
		#[arg(short = 'd', long)]
		selections_desc: PathBuf,
	},
}
