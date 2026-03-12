import smtplib
from email.mime.text import MIMEText
from email.mime.base import MIMEBase
from email.encoders import encode_base64
from email.mime.multipart import MIMEMultipart
from email.utils import formatdate

MAILHOG_IP = "192.168.x.x"  
MAILHOG_PORT = 1025
SENDER_EMAIL = "hr-department@company.com"
TARGET_EMAIL = "victim@example.com"
EMAIL_SUBJECT = "⚠️ 重要通知：2026年度薪資調整清單"
EMAIL_BODY_HTML = """
<html>
<body>
    <p>各位同仁您好，</p>
    <p>附件為 2026 年度個人薪資調整建議表，請下載並確認內容。</p>
    <p>若有任何疑問，請回覆本郵件聯繫 HR 部門。</p>
    <br>
    <p>祝 順心，<br>人力資源部</p>
</body>
</html>
"""
FILE_NAME = "Salary_Adjustment_2026.txt"
FILE_CONTENT = "這是一個測試附件內容。\n員工編號：9527\n薪資調幅：+15%\n請確認..."

def send_txt_email():
    msg = MIMEMultipart('mixed')
    msg['Subject'] = EMAIL_SUBJECT
    msg['From'] = SENDER_EMAIL
    msg['To'] = TARGET_EMAIL
    msg['Date'] = formatdate(localtime=True)

    msg.attach(MIMEText(EMAIL_BODY_HTML, "html"))

    attachment = MIMEBase('application', 'octet-stream')
    attachment.set_payload(FILE_CONTENT.encode('utf-8'))
    encode_base64(attachment)
    attachment.add_header('Content-Disposition', f'attachment; filename="{FILE_NAME}"')
    msg.attach(attachment)

    try:
        with smtplib.SMTP(MAILHOG_IP, MAILHOG_PORT) as server:
            server.sendmail(SENDER_EMAIL, [TARGET_EMAIL], msg.as_string())
        print(f"Success: {TARGET_EMAIL}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    send_txt_email()
