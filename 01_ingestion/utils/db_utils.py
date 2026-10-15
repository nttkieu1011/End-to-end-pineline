import os
from pathlib import Path
from dotenv import load_dotenv
from sqlalchemy import create_engine, text, TEXT, TIMESTAMP
from sqlalchemy.engine import URL
from sqlalchemy.dialects.postgresql import UUID

from datetime import datetime, timezone
import uuid

project_root = Path(__file__).resolve().parents[2]
load_dotenv(project_root / ".env")

def get_engine():
    db_user = os.getenv("DB_USER")
    db_password = os.getenv("DB_PASSWORD")
    db_host = os.getenv("DB_HOST", "localhost")
    db_port = os.getenv("DB_PORT", "5432")
    db_name = os.getenv("DB_NAME")

    if not all([db_user, db_password, db_name]):
        raise ValueError(
            "Missing DB_USER, DB_PASSWORD or DB_NAME in .env"
        )

    connection_url = URL.create(
    drivername="postgresql+psycopg2",
    username=db_user,
    password=db_password,
    host=db_host,
    port=int(db_port),
    database=db_name,
    )

    return create_engine(connection_url)

#add metadata
def add_metadata(df, source_file, source_platform, batch_id):
    df = df.copy()
    df["_source_file"] = source_file
    df["_source_platform"] = source_platform
    df["_ingestion_at"] = datetime.now(timezone.utc)
    df["_batch_id"] = batch_id
    return df

def load_data_to_bronze(df, table_name, if_exists="append"):
    engine = get_engine()
    rows_loaded = len(df)
    dtype = {
        col: TEXT()
        for col in df.columns
    }
    dtype["_ingestion_at"] = TIMESTAMP(timezone=True)
    dtype["_batch_id"] = UUID(as_uuid=False)

    df.to_sql(
        name=table_name,
        con=engine,
        schema="raw",
        if_exists=if_exists,
        index=False,    
        dtype=dtype,
    )
    return rows_loaded


def log_ingestion(batch_id, source_name, source_file, rows_loaded,
                  status, duration_sec, error_message=None):

    engine = get_engine()

    query = text("""
        insert into raw.ingest_log (
            batch_id, source_name, source_file,
            source_platform, rows_loaded, status,
            duration_sec, error_message
        )
        values (
            :batch_id, :source_name, :source_file,
            'google_drive', :rows_loaded, :status,
            :duration_sec, :error_message
        )
    """)

    with engine.begin() as conn:
        conn.execute(query, {
            "batch_id": batch_id,
            "source_name": source_name,
            "source_file": source_file,
            "rows_loaded": rows_loaded,
            "status": status,
            "duration_sec": duration_sec,
            "error_message": error_message
        })
        
