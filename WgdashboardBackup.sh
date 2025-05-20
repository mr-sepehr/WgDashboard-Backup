#!/bin/bash

echo "وارد کردن توکن ربات تلگرام:"
read -p "Bot Token: " BOT_TOKEN

echo "وارد کردن آی‌دی عددی تلگرام شما:"
read -p "Telegram Numeric Chat ID: " CHAT_ID

echo "اسم کانفیگ‌های WireGuard رو وارد کن (مثل wg1 یا wg1,wg2,wg3):"
read -p "WireGuard Configs: " CONFIGS_INPUT

# لیست کانفیگ‌ها رو به فایل کامل تبدیل می‌کنه
FILES_LIST='"/root/WGDashboard/src/db/wgdashboard_job.db",\n    "/root/WGDashboard/src/db/wgdashboard.db",'
IFS=',' read -ra CONFIG_ARRAY <<< "$CONFIGS_INPUT"
for config in "${CONFIG_ARRAY[@]}"; do
  FILES_LIST="${FILES_LIST}\n    \"/etc/wireguard/${config}.conf\","
done

# نصب نیازمندی‌ها
apt update && apt install -y python3 python3-pip
pip3 install python-telegram-bot==13.15

# ساخت فایل Python
cat > /root/backup_bot.py <<EOF
import os
import tarfile
import time
from telegram import Bot

# تنظیمات ربات
TOKEN = '${BOT_TOKEN}'
CHAT_ID = '${CHAT_ID}'

# فایل‌هایی که باید بکاپ بگیرند
FILES_TO_BACKUP = [
    ${FILES_LIST%?}  # حذف آخرین کاما
]

def make_backup():
    timestamp = time.strftime("%Y%m%d_%H%M%S")
    backup_path = f"/tmp/wg_backup_{timestamp}.tar.gz"
    try:
        with tarfile.open(backup_path, "w:gz") as tar:
            for file in FILES_TO_BACKUP:
                if os.path.exists(file):
                    tar.add(file, arcname=os.path.basename(file))
        return backup_path
    except Exception as e:
        print(f"خطا در بکاپ‌گیری: {e}")
        return None

def send_backup_file(bot, backup_path):
    with open(backup_path, "rb") as f:
        bot.send_document(chat_id=CHAT_ID, document=f, caption="🎯 بکاپ دستی یا خودکار WireGuard")
    os.remove(backup_path)

# اجرای اسکریپت
if __name__ == '__main__':
    bot = Bot(token=TOKEN)
    path = make_backup()
    if path:
        send_backup_file(bot, path)
EOF

# اضافه کردن کرون‌جاب
(crontab -l 2>/dev/null; echo "0 */3 * * * /usr/bin/python3 /root/backup_bot.py") | crontab -

echo -e "\n✅ اسکریپت ساخته شد و کرون‌جاب اضافه شد."
echo "برای تست دستی می‌تونی بزنی:"
echo "python3 /root/backup_bot.py"
