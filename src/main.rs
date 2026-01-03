mod cli;
mod error;

use clap::Parser;
use cli::{Cli, Commands};
use error::Fatal;
use std::{fmt::Write, fs::read_to_string};

enum Chirality {
	Left,
	Right { opener: char },
}

impl Chirality {
	pub const fn from(bracket: char) -> Option<Self> {
		let result = match bracket {
			'(' => Chirality::Left,
			')' => Chirality::Right { opener: '(' },
			'[' => Chirality::Left,
			']' => Chirality::Right { opener: '[' },
			'{' => Chirality::Left,
			'}' => Chirality::Right { opener: '{' },
			'<' => Chirality::Left,
			'>' => Chirality::Right { opener: '<' },
			_ => return None,
		};

		Some(result)
	}
}

#[derive(Debug, PartialEq)]
struct Coord {
	x: u32,
	y: u32,
}

fn coordsf(selections_desc: String) -> Result<Vec<Coord>, Fatal> {
	if selections_desc.is_empty() {
		return Ok(vec![]);
	}

	let f = |desc: &str| {
		let period = desc.find('.')?;
		let comma = period + desc[period..].find(',')?;

		let x = desc[..period].parse::<u32>().ok()?;
		let y = desc[period + 1..comma].parse::<u32>().ok()?;

		Some(Coord { x, y })
	};

	selections_desc
		.split(' ')
		.map(f)
		.collect::<Option<_>>()
		.ok_or(Fatal::SelectionsDescParse)
}

fn highlightf(face_count: u32, nests: Vec<Option<u32>>, coords: Vec<Coord>) -> String {
	let f = |(nest, coord)| Some((nest?, coord));
	let g = |mut result: String, (nest, coord): (u32, Coord)| {
		let _ = write!(result, " {}.{}+1|kakeidoscope_{}", coord.x, coord.y, nest % face_count);
		result
	};

	let result = "set-option window kakeidoscope_range %val{timestamp}".to_string();
	nests.into_iter().zip(coords).filter_map(f).fold(result, g)
}

fn nestsf(selections: String) -> Vec<Option<u32>> {
	let mut nest: u32 = 0;
	let mut stack = Vec::<char>::new();

	let f = |selection| {
		let result = match Chirality::from(selection)? {
			Chirality::Left => {
				let result = Some(nest);
				nest += 1;
				stack.push(selection);
				result
			}

			Chirality::Right { opener } if Some(opener) == stack.last().copied() => {
				nest -= 1;
				let result = Some(nest);
				stack.pop();
				result
			}

			_ => None,
		};

		Some(result)
	};

	selections.chars().filter_map(f).collect()
}

fn start() -> Result<(), Fatal> {
	match Cli::parse().command {
		#[cfg(feature = "init")]
		Commands::Init => println!("{}", include_str!("../rc/kakeidoscope.kak")),
		Commands::Highlight {
			face_count,
			selections,
			selections_desc,
		} => {
			let selections = read_to_string(selections)?;
			let nests = nestsf(selections);

			let selections_desc = read_to_string(selections_desc)?;
			let coords = coordsf(selections_desc)?;

			let highlight = highlightf(face_count, nests, coords);

			println!("{}", highlight);
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

#[cfg(test)]
mod test {
	use super::*;

	#[test]
	fn coordsft() -> Result<(), Fatal> {
		macro_rules! assert_coordsf {
			($selections_desc:expr, [$(($x:expr, $y:expr)),* $(,)?] $(,)?) => {{
				let result = coordsf($selections_desc.to_string())?;
				let expected = vec![$(Coord { x: $x, y: $y }),*];
				assert_eq!(result, expected);
			}};
		}

		assert_coordsf!("", []);

		assert_coordsf!(
			"5.4,5.4 5.17,5.17 7.2,7.2 7.29,7.29 7.35,7.35 13.6,13.6 13.11,13.11 13.14,13.14",
			[(5, 4), (5, 17), (7, 2), (7, 29), (7, 35), (13, 6), (13, 11), (13, 14)],
		);

		Ok(())
	}

	#[test]
	fn highlightft() {
		macro_rules! assert_highlightf {
			($face_count:expr, [$($nest:expr),* $(,)?], [$(($x:expr, $y:expr)),* $(,)?], $expected:expr $(,)?) => {{
				let nests: Vec<Option<_>> = vec![$($nest),*];
				let coords = vec![$(Coord { x: $x, y: $y }),*];
				let result = highlightf($face_count, nests, coords);
				assert_eq!(result, $expected.to_string());
			}};
		}

		assert_highlightf!(0, [], [], "set-option window kakeidoscope_range %val{timestamp}");

		assert_highlightf!(
			3,
			[Some(0), Some(1), Some(2), Some(2), Some(1), None, Some(0)],
			[(1, 1), (2, 2), (3, 3), (4, 3), (5, 2), (7, 2), (8, 1)],
			"set-option window kakeidoscope_range %val{timestamp}".to_string()
				+ " 1.1+1|kakeidoscope_0 2.2+1|kakeidoscope_1 3.3+1|kakeidoscope_2"
				+ " 4.3+1|kakeidoscope_2 5.2+1|kakeidoscope_1 8.1+1|kakeidoscope_0",
		);

		assert_highlightf!(
			2,
			[Some(0), Some(1), Some(2), Some(2), Some(1), None, Some(0)],
			[(1, 1), (2, 2), (3, 3), (4, 3), (5, 2), (7, 2), (8, 1)],
			"set-option window kakeidoscope_range %val{timestamp}".to_string()
				+ " 1.1+1|kakeidoscope_0 2.2+1|kakeidoscope_1 3.3+1|kakeidoscope_0"
				+ " 4.3+1|kakeidoscope_0 5.2+1|kakeidoscope_1 8.1+1|kakeidoscope_0",
		);
	}

	#[test]
	fn nestsft() {
		macro_rules! assert_nestsf {
			($selections:expr, [$($nest:expr),* $(,)?] $(,)?) => {{
				let result = nestsf($selections.to_string());
				let expected : Vec<Option<_>> = vec![$($nest),*];
				assert_eq!(result, expected);
			}};
		}

		assert_nestsf!("", []);

		assert_nestsf!(
			"( [ { } ] ( ) )",
			[Some(0), Some(1), Some(2), Some(2), Some(1), Some(1), Some(1), Some(0)],
		);

		assert_nestsf!(
			"( [ { } ] > )",
			[Some(0), Some(1), Some(2), Some(2), Some(1), None, Some(0)],
		);

		assert_nestsf!(
			"( 1 [ 2 { 3 } 4 ] 5 > 6 )",
			[Some(0), Some(1), Some(2), Some(2), Some(1), None, Some(0)],
		);

		#[rustfmt::skip]
		assert_nestsf!(
			"{ ( ) > < > { { ( > ) > { ( } [ > ] > { [ } { > } > { { } < > > > { < } > } ( ) } } [ ( ) ] { }",
			[
				Some(0), Some(1), Some(1), None,    Some(1), Some(1), Some(1), Some(2), Some(3), None,
				Some(3), None,    Some(3), Some(4), None,    Some(5), None,    Some(5), None,    Some(5),
				Some(6), None,    Some(7), None,    Some(7), None,    Some(7), Some(8), Some(8), Some(8),
				Some(8), None,    None,    Some(8), Some(9), None,    Some(9), Some(8), Some(8), Some(8),
				Some(7), None,    Some(7), Some(8), Some(8), Some(7), Some(7), Some(7),
			],
		);
	}
}
