CREATE TABLE IF NOT EXISTS raw.sales_target_versions (
    version_id BIGSERIAL PRIMARY KEY,
    version_label TEXT NOT NULL,
    source_file TEXT NOT NULL,
    source_sheet TEXT NOT NULL,
    version_date TEXT,
    effective_from TEXT,
    effective_to TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE (source_file, source_sheet)
);
