import smtplib
import argparse
import os
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email.mime.multipart import MIMEMultipart
from email.encoders import encode_base64
from email.utils import formatdate

def send_email(target_ip, target_email, file_path):
    SERVER = target_ip
    PORT = 1025
    SENDER = "hr-department@company.com"
    SUBJECT = "⚠️ 重要通知：附件內容確認"
    BODY = "<html><body><p>您好，附件為申請之相關文件，請查收。</p></body></html>"

    # 使用 mixed 模式確保附件結構穩定
    msg = MIMEMultipart('mixed')
    msg['Subject'] = SUBJECT
    msg['From'] = SENDER
    msg['To'] = target_email
    msg['Date'] = formatdate(localtime=True)

    # 1. 正文部分
    msg.attach(MIMEText(BODY, "html", "utf-8"))

    # 2. 附件部分 (處理 .lnk)
    if os.path.isfile(file_path):
        file_name = os.path.basename(file_path)
        with open(file_path, "rb") as f:
            # 針對二進位檔案使用 octet-stream
            part = MIMEBase('application', 'octet-stream')
            part.set_payload(f.read())
            
            # 關鍵：針對二進位檔案必須使用 Base64，否則 Python 會噴 Unicode 編碼錯誤
            encode_base64(part)
            
            # 設定檔名
            part.add_header(
                'Content-Disposition', 
                'attachment', 
                filename=file_name
            )
            msg.attach(part)
    else:
        print(f"Error: 找不到檔案 {file_path}")
        return

    try:
        with smtplib.SMTP(SERVER, PORT, timeout=10) as server:
            # 這裡使用 as_string()，因為 Base64 處理後已經是純 ASCII 了
            server.sendmail(SENDER, [target_email], msg.as_string())
        print(f"Success: {file_name} -> {target_email} (Target: {SERVER})")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--ip", default="10.9.8.187")
    parser.add_argument("--to", required=True)
    parser.add_argument("--file", required=True)
    
    args = parser.parse_args()
    send_email(args.ip, args.to, args.file)
