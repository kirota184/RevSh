import smtplib
import os
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email.encoders import encode_base64
from email.mime.multipart import MIMEMultipart
from email.utils import formatdate

# === 手動設定區 ===
TARGET_IP = "192.168.x.x"  # 你的靶機 IP
TARGET_TO = "admin@gmail.com"
FILE_PATH = "test.txt"      # 你要傳送的檔案路徑
# =================

def send_email():
    # 郵件設定
    sender = "hr-department@company.com"
    subject = "⚠️ 重要通知：附件內容確認"
    body = "<html><body><p>您好，附件為申請之相關文件。</p></body></html>"

    # 使用 multipart/mixed，這是最穩定的附件容器
    msg = MIMEMultipart('mixed')
    msg['Subject'] = subject
    msg['From'] = sender
    msg['To'] = TARGET_TO
    msg['Date'] = formatdate(localtime=True)

    # 1. 加入正文
    msg.attach(MIMEText(body, "html", "utf-8"))

    # 2. 加入附件 (核心修改：確保沒有多餘的空層級)
    if os.path.exists(FILE_PATH):
        file_name = os.path.basename(FILE_PATH)
        with open(FILE_PATH, "rb") as f:
            part = MIMEBase('application', 'octet-stream')
            part.set_payload(f.read())
            encode_base64(part)
            # 注意：這裡的引號與逗號格式會影響 MailHog 的解析
            part.add_header('Content-Disposition', f'attachment; filename="{file_name}"')
            msg.attach(part)
    else:
        print(f"Error: 找不到檔案 {FILE_PATH}")
        return

    try:
        # 第一個版本成功的關鍵：簡潔的連線方式
        server = smtplib.SMTP(TARGET_IP, 1025, timeout=5)
        server.sendmail(sender, [TARGET_TO], msg.as_string())
        server.quit()
        print(f"Success: 已發送 {FILE_PATH}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    send_email()
