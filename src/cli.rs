use clap::{Parser, Subcommand, value_parser};
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
		/// For each bracket, we highlight with a face, 'kakeidoscope_\d+', where '\d+' is the zero-indexed
		/// nest level, modulo `face_count`
		#[arg(short, long, value_parser = value_parser!(u32).range(1..))]
		face_count: u32,

		/// File which contains '%val{selections}' of the window to be highlighted
		#[arg(short, long)]
		selections: PathBuf,

		/// File which contains '%val{selections_desc}' of the window to be highlighted
		#[arg(short = 'd', long)]
		selections_desc: PathBuf,
	},
}
