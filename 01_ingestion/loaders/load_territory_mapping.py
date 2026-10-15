
import sys
import time
import uuid
from pathlib import Path

# Đưa thư mục ingestion vào đường dẫn import
project_root = Path(__file__).resolve().parents[2]
ingestion_path = project_root / "01_ingestion"

if str(ingestion_path) not in sys.path:
    sys.path.insert(0, str(ingestion_path))

from connectors.gdrive_connector import (
    list_drive_files,
    download_file,
)
from utils.file_parser import parse_file
from utils.db_utils import (
    add_metadata,
    load_data_to_bronze,
    log_ingestion,
)

# Thay bằng ID folder chứa 10 file dữ liệu trên Google Drive
FOLDER_ID = "1DxPEHsw8n8_jv6KKSgEdAoEpbkqSWGaa"

FILE_NAME = "SRC08_territory_mapping.xlsx"
TABLE_NAME = "territory_mapping"


def run():
    batch_id = str(uuid.uuid4())
    start_time = time.time()
    rows_loaded = 0

    try:
        # Tìm file trong folder Google Drive
        files = list_drive_files(FOLDER_ID)

        if not files:
            raise FileNotFoundError(
                "Không tìm thấy file trong Google Drive."
            )

        # Tìm đúng file theo tên
        target_file = next(
            (file for file in files if file["name"] == FILE_NAME),
            None,
        )

        if target_file is None:
            raise FileNotFoundError(
                f"Không tìm thấy {FILE_NAME}."
            )

        # Tải và đọc file
        file_content = download_file(target_file["id"])
        df = parse_file(file_content, FILE_NAME)

        # Thêm metadata
        df = add_metadata(
            df,
            source_file=FILE_NAME,
            source_platform="google_drive",
            batch_id=batch_id,
        )

        # Nạp dữ liệu vào Bronze
        rows_loaded = load_data_to_bronze(
            df,
            table_name=TABLE_NAME,
            if_exists="append",
        )

        duration = round(time.time() - start_time, 2)

        # Ghi log thành công
        log_ingestion(
            batch_id=batch_id,
            source_name=TABLE_NAME,
            source_file=FILE_NAME,
            rows_loaded=rows_loaded,
            status="SUCCESS",
            duration_sec=duration,
        )

        print(f"Nạp thành công {rows_loaded} dòng vào raw.{TABLE_NAME}")
        print(f"Batch ID: {batch_id}")
        print(f"Thời gian: {duration} giây")

    except Exception as e:
        duration = round(time.time() - start_time, 2)

        # Ghi log thất bại
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
