mod cli;
mod error;

use clap::Parser;
use cli::{Cli, Commands};
use error::Fatal;
use itertools::Itertools;
use std::{fmt::Write, fs, path::Path};

#[derive(Debug, Clone)]
struct Point {
	bracket: char,
	x: u64,
	y: u64,
}

#[derive(Debug, Clone, Eq, Hash, PartialEq)]
struct BracketPair {
	left: char,
	right: char,
}

/// Read a path to a String.
fn read_path(path: &Path) -> Result<String, Fatal> {
	fs::read_to_string(path).map_err(|e| Fatal::CannotReadFile {
		path: path.into(),
		e,
	})
}

fn parse_brackets(
	selections: &str,
	selections_desc: &str,
) -> Result<Vec<Point>, Fatal> {
	let selections = selections
		.split(' ')
		.map(|s| s.chars().next().expect("'selections' was empty"));
	let selections_desc = selections_desc
		.split(&['.', ',', ' '])
		.tuples::<(_, _, _, _)>();

	selections
		.zip(selections_desc)
		.map(|(bracket, (y, x, _, _))| {
			match (y.parse::<u64>(), x.parse::<u64>()) {
				(Ok(y), Ok(x)) => Ok(Point { bracket, x, y }),
				_ => Err(Fatal::PointParse),
			}
		})
		.collect()
}

fn highlight(
	faces: &[String],
	pairs: &[BracketPair],
	brackets: &[Point],
) -> String {
	let mut level: i32 = 0;
	let mut unmatched = Vec::<&BracketPair>::new();

	brackets.iter().fold(
		String::from("set window kakeidoscope_range %val{timestamp}"),
		|mut highlighter, point| {
			for pair in pairs {
				let nest: i32;

				match (
					point.bracket == pair.left,
					point.bracket == pair.right
						&& unmatched.last().is_some_and(|p| pair == *p),
				) {
					(true, true) => unreachable!(), /* Guaranteed via dedup in 'start()'. */
					(true, false) => {
						nest = level;
						level += 1;
						unmatched.push(pair);
					}
					(false, true) => {
						level -= 1;
						nest = level;
						unmatched.pop();
					}
					(false, false) => continue,
				}

				let _ = write!(
					highlighter,
					" '{}.{}+1|{}'",
					point.y,
					point.x,
					faces[(nest % faces.len() as i32) as usize]
				);

				break;
			}

			highlighter
		},
	)
}

fn start() -> Result<(), Fatal> {
	let cli = Cli::parse();

	match &cli.command {
		Commands::Init => {
			println!("{}", include_str!("../rc/kakeidoscope.kak"));
		}
		Commands::Highlight {
			faces,
			pairs,
			selections,
			selections_desc,
		} => {
			let selections = &read_path(selections)?;
			let selections_desc = &read_path(selections_desc)?;

			for buffer in [selections, selections_desc] {
				if buffer.is_empty() {
					return Ok(()); /* Nothing to do. */
				}
			}

			let brackets = parse_brackets(selections, selections_desc)?;

			if pairs.len() % 2 == 1 {
				return Err(Fatal::OddBrackets);
			}

			{
				let mut refs: Vec<_> = pairs.iter().collect();
				refs.sort_unstable();

				/* Indexes are guaranteed by 'windows()'. */
				if let Some(&[a, _]) = refs.windows(2).find(|w| w[0] == w[1]) {
					return Err(Fatal::DuplicateBrackets { bracket: *a });
				}
			}

			let pairs: Vec<_> = pairs
				.iter()
				.tuples::<(_, _)>() /* Guaranteed by prior even 'len()' check. */
				.map(|(l, r)| BracketPair {
					left: *l,
					right: *r,
				})
				.collect();

			println!("{}", highlight(faces, &pairs, &brackets));
		}
	}

	Ok(())
}

fn main() {
	if let Err(e) = start() {
		eprintln!("fatal: {e}");
		std::process::exit(1);
	}
}
