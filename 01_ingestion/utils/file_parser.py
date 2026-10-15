
from io import BytesIO
import pandas as pd


def parse_file(file_content, file_name, sheet_name=0):
    file_buffer = BytesIO(file_content)
    extension = file_name.lower().rsplit(".", 1)[-1]

    if extension == "csv":
        try:
            df = pd.read_csv(file_buffer, encoding="utf-8-sig")
        except UnicodeDecodeError:
            file_buffer.seek(0)
            df = pd.read_csv(file_buffer, encoding="cp1258")

    elif extension == "xlsx":
        df = pd.read_excel(
            file_buffer,
            sheet_name=sheet_name,
            engine="openpyxl"
        )
    
    else:
        raise ValueError(
            f"Định dạng file chưa được hỗ trợ: .{extension}"
        )

    return df

