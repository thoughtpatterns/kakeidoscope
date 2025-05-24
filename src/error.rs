use std::{io, path::PathBuf};
use thiserror::Error;

#[derive(Debug, Error)]
pub enum Fatal {
	#[error("failed to read file {path}: {e}")]
	CannotReadFile { path: PathBuf, e: io::Error },

	#[error("the number of brackets passed must be even")]
	OddBrackets,

	#[error("the bracket '{bracket}' was passed twice")]
	DuplicateBrackets { bracket: char },

	#[error("could not parse passed '%val{{selections_desc}}'")]
	PointParse,
}
