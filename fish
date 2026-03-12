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

    # 1. 附加正文
    msg.attach(MIMEText(BODY, "html", "utf-8"))

    # 2. 附件處理：明文傳輸 (8bit)
    if os.path.isfile(file_path):
        file_name = os.path.basename(file_path)
        with open(file_path, "rb") as f:
            # 建立附件物件
            part = MIMEBase('text', 'plain')
            part.set_payload(f.read())
            
            # --- 修正處：使用 add_header 而非 replace_header ---
            # 直接指定傳輸編碼為 8bit 明文
            part.add_header('Content-Transfer-Encoding', '8bit')
            
            # 設定檔案名稱
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
        # 連線至 MailHog SMTP (1025)
        with smtplib.SMTP(SERVER, PORT, timeout=10) as server:
            server.sendmail(SENDER, [target_email], msg.as_string())
        print(f"Success: 已發送 {file_name} 至 {target_email} (明文模式)")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--ip", required=True)
    parser.add_argument("--to", required=True)
    parser.add_argument("--file", required=True)
    
    args = parser.parse_args()
    send_email(args.ip, args.to, args.file)
