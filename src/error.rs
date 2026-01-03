use thiserror::Error;

#[derive(Debug, Error)]
pub enum Fatal {
	#[error("failed to read file")]
	FileRead(#[from] std::io::Error),

	#[error("failed to parse '%val{{selections_desc}}'")]
	SelectionsDescParse,
}
