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

    # 使用 mixed 容器
    msg = MIMEMultipart('mixed')
    msg['Subject'] = SUBJECT
    msg['From'] = SENDER
    msg['To'] = target_email
    msg['Date'] = formatdate(localtime=True)

    # 1. 處理正文：強制使用 7bit/8bit 明文，不經過 MIMEText 的自動 Base64 邏輯
    html_part = MIMEBase('text', 'html', charset='utf-8')
    html_part.set_payload(BODY.encode('utf-8'))
    # 這裡不要用 add_header，直接設定這個屬性來確保不被轉碼
    html_part['Content-Transfer-Encoding'] = '8bit'
    msg.attach(html_part)

    # 2. 處理 .lnk 附件：必須使用 Base64 避免編碼報錯
    if os.path.isfile(file_path):
        file_name = os.path.basename(file_path)
        with open(file_path, "rb") as f:
            part = MIMEBase('application', 'octet-stream')
            part.set_payload(f.read())
            
            # LNK 是二進制，必須 Base64
            encode_base64(part)
            
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
            # 使用 as_string() 發送
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
