from pathlib import Path
import sys

from google.oauth2 import service_account
from googleapiclient.discovery import build

# Xác định thư mục gốc của project
project_root = Path(__file__).resolve().parents[2]
ingestion_path = project_root / "01_ingestion"

if str(ingestion_path) not in sys.path:
    sys.path.insert(0, str(ingestion_path))
from utils.file_parser import parse_file

# Cấu hình Google Drive
credentials_path = (
    project_root / "credentials" / "minpyws-e949ad82d40b.json"
)
scopes = ["https://www.googleapis.com/auth/drive.readonly"]

# kết nối với Google Drive
def get_drive_service():
    credentials = service_account.Credentials.from_service_account_file(
        credentials_path, scopes=scopes
    )
    service = build("drive", "v3", credentials=credentials)
    return service

#kiểm tra kết nối với Google Drive
def test_connection():
    service = get_drive_service()
    results = service.about().get(fields="user").execute()
    
    print("Connected to Google Drive API thành công!")
    print("Service Account:", results["user"]["emailAddress"])

#liệt kê các files service account có quyền truy cập
def list_drive_files(folder_id):
    service = get_drive_service()
    results = service.files().list(
        q=f"'{folder_id}' in parents and trashed = false",
        pageSize=100,
        fields="files(id, name, mimeType)"
    ).execute()
    
    files= results.get("files", [])

    if not files:
        print("không tìm thấy file.")
        return
    for file in files:
        print(
            f"Tên file: {file['name']} | "
            f"ID: {file['id']} | "
            f"Loại: {file['mimeType']}"
        )
    return files
    
# tải file từ Google Drive về bộ nhớ
def download_file(file_id):
    service = get_drive_service()

    content = service.files().get_media(
        fileId=file_id
    ).execute()

    return content

#Tải file từ Google Drive và đọc thành DataFrame
def load_file_as_dataframe(file_id, file_name):
    file_content = download_file(file_id)

    df = parse_file(file_content, file_name)

    print("Tên file:", file_name)
    print("Kích thước dữ liệu (dòng, cột):", df.shape)
    print("\n5 dòng đầu tiên:")
    print(df.head())

    return df
