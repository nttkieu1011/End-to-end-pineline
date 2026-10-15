
CREATE TABLE IF NOT EXISTS raw.sales_target_files (
    file_id BIGSERIAL PRIMARY KEY,
    source_file TEXT NOT NULL,
    source_sheet TEXT NOT NULL,
    version_label TEXT NOT NULL,
    version_date TEXT,
    effective_from TEXT,
    effective_to TEXT,
    rows_loaded INTEGER DEFAULT 0,
    status TEXT NOT NULL,
    loaded_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (source_file, source_sheet)
);
