
CREATE TABLE IF NOT EXISTS raw.sales_targets_raw (
    target_id BIGSERIAL PRIMARY KEY,
    version_label TEXT NOT NULL,
    source_file TEXT NOT NULL,
    source_sheet TEXT NOT NULL,
    employee_id TEXT,
    employee_name TEXT,
    region TEXT,
    team TEXT,
    year TEXT,
    month_col TEXT NOT NULL,
    target_revenue TEXT,
    target_quantity TEXT,
    target_new_customers TEXT,
    _source_file TEXT,
    _source_platform TEXT,
    _ingested_at TIMESTAMPTZ DEFAULT NOW(),
    _batch_id UUID
);
