import smtplib
import argparse
import os
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email.encoders import encode_base64
from email.mime.multipart import MIMEMultipart
from email.utils import formatdate

def send_email(target_ip, target_email, file_path):
    # 預設配置
    SERVER = target_ip
    PORT = 1025
    SENDER = "hr-department@company.com"
    SUBJECT = "⚠️ 重要通知：附件內容確認"
    BODY = "<html><body><p>您好，附件為申請之相關文件，請查收。</p></body></html>"

    # 建立郵件
    msg = MIMEMultipart('mixed')
    msg['Subject'] = SUBJECT
    msg['From'] = SENDER
    msg['To'] = target_email
    msg['Date'] = formatdate(localtime=True)
    msg.attach(MIMEText(BODY, "html"))

    # 修改附件部分：直接讀取參數指定的檔案
    if os.path.isfile(file_path):
        file_name = os.path.basename(file_path)
        with open(file_path, "rb") as f:
            part = MIMEBase('application', 'octet-stream')
            part.set_payload(f.read())
            encode_base64(part)
            part.add_header('Content-Disposition', f'attachment; filename="{file_name}"')
            msg.attach(part)
    else:
        print(f"Error: 找不到檔案 {file_path}")
        return

    # 發送至 MailHog
    try:
        with smtplib.SMTP(SERVER, PORT) as server:
            server.sendmail(SENDER, [target_email], msg.as_string())
        print(f"Success: 已發送 {file_name} 至 {target_email}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--ip", required=True, help="靶機 IP")
    parser.add_argument("--to", required=True, help="收件者")
    parser.add_argument("--file", required=True, help="要夾帶的檔案路徑")
    
    args = parser.parse_args()
    send_email(args.ip, args.to, args.file)
