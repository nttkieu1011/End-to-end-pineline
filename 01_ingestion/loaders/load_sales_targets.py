

import sys
import time
import uuid
from pathlib import Path

from sqlalchemy import text

project_root = Path(__file__).resolve().parents[2]
ingestion_path = project_root / "01_ingestion"

if str(ingestion_path) not in sys.path:
    sys.path.insert(0, str(ingestion_path))

from connectors.gdrive_connector import list_drive_files, download_file
from utils.file_parser import parse_file
from utils.db_utils import (
    add_metadata,
    load_data_to_bronze,
    log_ingestion,
    get_engine,
)

FOLDER_ID = "1DxPEHsw8n8_jv6KKSgEdAoEpbkqSWGaa"
FILE_NAME = "SRC02_sales_target_plan.xlsx"
TABLE_NAME = "sales_targets_raw"
SHEET_NAME = "Plan_v2_Adjustment_H2"
VERSION_LABEL = "v2"


def run():
    batch_id = str(uuid.uuid4())
    start_time = time.time()
    rows_loaded = 0

    try:
        # 1. Tìm file trên Google Drive
        files = list_drive_files(FOLDER_ID)
        target_file = next(
            (f for f in files if f["name"] == FILE_NAME),
            None,
        )

        if target_file is None:
            raise FileNotFoundError(f"Không tìm thấy {FILE_NAME}")

        # 2. Đọc sheet v1
        file_content = download_file(target_file["id"])
        df = parse_file(
            file_content,
            FILE_NAME,
            sheet_name=SHEET_NAME,
        )

        df.columns = df.columns.astype(str).str.strip().str.lower()

        # 3. Lấy thông tin phiên bản
        version_date = str(df["version_date"].iloc[0])
        effective_from = str(df["effective_from"].iloc[0])
        effective_to = str(df["effective_to"].iloc[0])

        # 4. Loại dòng tổng nếu có
        df = df[
            df["employee_name"].astype(str).str.strip().str.upper() != "TỔNG"
        ].copy()

        
        # 5. Chuẩn hóa tháng và thêm thông tin phiên bản
        df = df.rename(columns={"month": "month_col"})
        df["month_col"] = df["month_col"].apply(
            lambda month: f"T{int(month)}"
        )
        df["version_label"] = VERSION_LABEL
        df["source_file"] = FILE_NAME
        df["source_sheet"] = SHEET_NAME

        # 6. Chỉ giữ các cột dữ liệu cần thiết
        df = df[
            [
                "version_label",
                "source_file",
                "source_sheet",
                "employee_id",
                "employee_name",
                "region",
                "team",
                "year",
                "month_col",
                "target_revenue",
                "target_quantity",
                "target_new_customers",
            ]
        ]

        # 7. Thêm metadata
        df = add_metadata(
            df,
            source_file=FILE_NAME,
            source_platform="google_drive",
            batch_id=batch_id,
        )
        df = df.rename(columns={"_ingestion_at": "_ingested_at"})
    
        
        # 8. Kiểm tra phiên bản đã được ghi nhận chưa
        engine = get_engine()

        with engine.begin() as conn:
            existing = conn.execute(
                text("""
                    SELECT 1
                    FROM raw.sales_target_files
                    WHERE source_file = :source_file
                      AND source_sheet = :source_sheet
                """),
                {
                    "source_file": FILE_NAME,
                    "source_sheet": SHEET_NAME,
                },
            ).fetchone()

            if existing:
                raise ValueError(
                    f"Sheet {SHEET_NAME} đã được ghi nhận. "
                    "Dừng để tránh nạp trùng dữ liệu."
                )

        # 9. Nạp dữ liệu vào Bronze
        rows_loaded = load_data_to_bronze(
            df,
            table_name=TABLE_NAME,
            if_exists="append",
        )

        # 10. Ghi thông tin phiên bản và file đã nạp
        with engine.begin() as conn:
            conn.execute(
                text("""
                    INSERT INTO raw.sales_target_versions (
                        version_label,
                        source_file,
                        source_sheet,
                        version_date,
                        effective_from,
                        effective_to
                    )
                    VALUES (
                        :version_label,
                        :source_file,
                        :source_sheet,
                        :version_date,
                        :effective_from,
                        :effective_to
                    )
                    ON CONFLICT (source_file, source_sheet) DO NOTHING
                """),
                {
                    "version_label": VERSION_LABEL,
                    "source_file": FILE_NAME,
                    "source_sheet": SHEET_NAME,
                    "version_date": version_date,
                    "effective_from": effective_from,
                    "effective_to": effective_to,
                },
            )

            conn.execute(
                text("""
                    INSERT INTO raw.sales_target_files (
                        source_file,
                        source_sheet,
                        version_label,
                        version_date,
                        effective_from,
                        effective_to,
                        rows_loaded,
                        status
                    )
                    VALUES (
                        :source_file,
                        :source_sheet,
                        :version_label,
                        :version_date,
                        :effective_from,
                        :effective_to,
                        :rows_loaded,
                        'SUCCESS'
                    )
                """),
                {
                    "source_file": FILE_NAME,
                    "source_sheet": SHEET_NAME,
                    "version_label": VERSION_LABEL,
                    "version_date": version_date,
                    "effective_from": effective_from,
                    "effective_to": effective_to,
                    "rows_loaded": rows_loaded,
                },
            )

        # 11. Ghi log thành công
        duration = round(time.time() - start_time, 2)

        log_ingestion(
            batch_id=batch_id,
            source_name=TABLE_NAME,
            source_file=FILE_NAME,
            rows_loaded=rows_loaded,
            status="SUCCESS",
            duration_sec=duration,
        )

        print(f"Nạp thành công {rows_loaded} dòng vào raw.{TABLE_NAME}")
        print(f"Phiên bản: {VERSION_LABEL}")
        print(f"Sheet: {SHEET_NAME}")

    except Exception as e:
        duration = round(time.time() - start_time, 2)

        log_ingestion(
            batch_id=batch_id,
            source_name=TABLE_NAME,
            source_file=FILE_NAME,
            rows_loaded=rows_loaded,
            status="FAILED",
            duration_sec=duration,
            error_message=str(e),
        )

        raise


if __name__ == "__main__":
    run()
