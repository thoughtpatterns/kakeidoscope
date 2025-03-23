mod cli;
mod error;

use clap::Parser;
use cli::{Cli, Commands};
use error::Fatal;
use std::{collections::HashMap, fs::read_to_string};

#[derive(Debug, Eq, Hash, PartialEq)]
struct BracketPair<'a> {
	left: &'a char,
	right: &'a char,
}

fn highlight(buffer: &str, brackets: &[BracketPair], faces: &[String]) {
	let mut x: u32 = 0;
	let mut y: u32 = 1;

	let mut nests: HashMap<&BracketPair, i32> =
		brackets.iter().map(|x| (x, 0)).collect();
	let mut unmatched: Vec<&BracketPair> = Vec::new();
	let mut highlighter: String =
		String::from("set window kakeidoscope_range %val{timestamp}");

	for c in buffer.chars() {
		if c == 0xa as char {
			x = 0;
			y += 1;
			continue;
		}

		x += 1;

		for bracket in brackets {
			let nest: i32;

			match (
				c == *bracket.left,
				c == *bracket.right
					&& unmatched.last().is_some_and(|x| bracket == *x),
			) {
				(false, false) => continue,
				(true, false) => {
					nest = nests[bracket];
					nests.entry(bracket).and_modify(|x| *x += 1);
					unmatched.push(bracket);
				}
				(false, true) => {
					nests.entry(bracket).and_modify(|x| *x -= 1);
					nest = nests[bracket];
					unmatched.pop();
				}
				_ => unreachable!(), /* We prevent this case in start(). */
			}

			highlighter += &format!(
				" '{y}.{x}+1|{}'",
				faces[(nest % faces.len() as i32) as usize]
			);

			break;
		}
	}

	println!("{highlighter}");
}

fn start() -> Result<(), Fatal> {
	let cli: Cli = Cli::parse();

	match &cli.command {
		Commands::Init => {
			println!("{}", include_str!("../rc/kakeidoscope.kak"));
		}

		Commands::Highlight {
			filename,
			brackets,
			faces,
		} => {
			if brackets.len() % 2 != 0 {
				return Err(Fatal::OddBracketsPassed);
			}

			let brackets: Vec<BracketPair> = brackets
				.chunks(2)
				.filter_map(|c| match c {
					[l, r] => {
						if l == r {
							None
						} else {
							Some(BracketPair { left: l, right: r })
						}
					}
					_ => None,
				})
				.collect();

			let buffer: String = read_to_string(filename).map_err(|e| {
				Fatal::CannotReadFile {
					path: filename.into(),
					e,
				}
			})?;

			highlight(&buffer, &brackets, faces);
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
