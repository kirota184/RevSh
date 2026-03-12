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

    # 2. 附件處理：改為明文傳輸 (8bit) 並解決分解問題
    if os.path.isfile(file_path):
        file_name = os.path.basename(file_path)
        with open(file_path, "rb") as f:
            # 使用 MIMEBase 建立物件，明確指定為 text/plain
            part = MIMEBase('text', 'plain')
            part.set_payload(f.read())
            
            # --- 修正處：不要用 replace_header，直接賦值 ---
            # 這樣不會報 KeyError，且能強制改為 8bit 明文
            part['Content-Transfer-Encoding'] = '8bit'
            
            # 正確設定檔案名稱，這能防止 MailHog 將其分解
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
        # 連線至 MailHog (SMTP 1025)
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
