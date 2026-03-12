import smtplib
import argparse
import os
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email.mime.multipart import MIMEMultipart
from email.utils import formatdate
from email import encoders # 匯入編碼器

def send_email(target_ip, target_email, file_path):
    SERVER = target_ip
    PORT = 1025
    SENDER = "hr-department@company.com"
    SUBJECT = "⚠️ 重要通知：附件內容確認"
    BODY = "<html><body><p>您好，附件為申請之相關文件，請查收。</p></body></html>"

    # 使用 mixed 模式
    msg = MIMEMultipart('mixed')
    msg['Subject'] = SUBJECT
    msg['From'] = SENDER
    msg['To'] = target_email
    msg['Date'] = formatdate(localtime=True)

    # 1. 處理正文 (使用 HTML)
    html_part = MIMEText(BODY, "html", "utf-8")
    msg.attach(html_part)

    # 2. 處理附件
    if os.path.isfile(file_path):
        file_name = os.path.basename(file_path)
        with open(file_path, "rb") as f:
            # 使用 base64 編碼處理二進制檔案 (.lnk) 最安全
            part = MIMEBase('application', 'octet-stream')
            part.set_payload(f.read())
            
            # 關鍵修正：改用 base64 編碼，避免 8bit 導致的解析斷裂
            encoders.encode_base64(part)
            
            # 確保檔名處理不含換行符
            part.add_header(
                'Content-Disposition', 
                f'attachment; filename="{file_name}"'
            )
            msg.attach(part)
    else:
        print(f"Error: 找不到檔案 {file_path}")
        return

    try:
        # 使用 smtplib 發送
        with smtplib.SMTP(SERVER, PORT, timeout=10) as server:
            # 關鍵修正：發送 bytes 流，這是處理現代 MIME 郵件的最佳實踐
            server.send_message(msg) 
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
