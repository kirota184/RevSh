import smtplib
import argparse
import os
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email.encoders import encode_base64
from email.mime.multipart import MIMEMultipart
from email.utils import formatdate

def send_email(target_ip, target_email, file_path):
    SERVER = target_ip
    PORT = 1025
    SENDER = "hr-department@company.com"
    SUBJECT = "⚠️ 重要通知：附件內容確認"
    BODY = "<html><body><p>您好，附件為申請之相關文件，請查收。</p></body></html>"

    # 使用 multipart/mixed 作為最外層容器
    msg = MIMEMultipart('mixed')
    msg['Subject'] = SUBJECT
    msg['From'] = SENDER
    msg['To'] = target_email
    msg['Date'] = formatdate(localtime=True)

    # 1. 直接附加正文 (不要再包一層 alternative)
    msg.attach(MIMEText(BODY, "html", "utf-8"))

    # 2. 修改附件處理
    if os.path.isfile(file_path):
        file_name = os.path.basename(file_path)
        with open(file_path, "rb") as f:
            # 使用 application/octet-stream 或 text/plain
            part = MIMEBase('application', 'octet-stream')
            part.set_payload(f.read())
            encode_base64(part)
            # 確保檔案標頭格式正確
            part.add_header('Content-Disposition', 'attachment', filename=file_name)
            msg.attach(part)
    else:
        print(f"Error: {file_path} not found")
        return

    try:
        with smtplib.SMTP(SERVER, PORT) as server:
            # 移除所有 login 和 starttls 以配合 MailHog
            server.sendmail(SENDER, [target_email], msg.as_string())
        print(f"Success: {file_name} sent to {target_email}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--ip", required=True)
    parser.add_argument("--to", required=True)
    parser.add_argument("--file", required=True)
    args = parser.parse_args()
    send_email(args.ip, args.to, args.file)
