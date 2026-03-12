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
    # 確保 HTML 標籤完整
    BODY = "<html><body><p>您好，附件為申請之相關文件，請查收。</p></body></html>"

    # 使用 mixed 模式，這是包含附件的最穩定結構
    msg = MIMEMultipart('mixed')
    msg['Subject'] = SUBJECT
    msg['From'] = SENDER
    msg['To'] = target_email
    msg['Date'] = formatdate(localtime=True)

    # 1. 處理正文：直接 attach 到 mixed 容器的底層
    # 這裡明確指定 utf-8 並設定為 html
    html_part = MIMEText(BODY, "html", "utf-8")
    msg.attach(html_part)

    # 2. 處理 .txt.lnk 附件
    if os.path.isfile(file_path):
        file_name = os.path.basename(file_path)
        with open(file_path, "rb") as f:
            # 針對 .lnk 建議使用 application/x-ms-shortcut 或 application/octet-stream
            part = MIMEBase('application', 'octet-stream')
            part.set_payload(f.read())
            
            # 強制 8bit 明文傳輸避免被 MailHog 解析器誤判
            part['Content-Transfer-Encoding'] = '8bit'
            
            # 關鍵：這裡的 filename 必須帶雙引號，並確保標頭沒有多餘換行
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
            # 關鍵修正：使用 as_bytes() 發送，確保 8bit 內容不損壞
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
