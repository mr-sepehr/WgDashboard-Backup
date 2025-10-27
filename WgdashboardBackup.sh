#!/bin/bash
set -e

echo "وارد کردن توکن ربات تلگرام:"
read -p "Bot Token: " BOT_TOKEN

echo "وارد کردن آی‌دی عددی تلگرام شما:"
read -p "Telegram Numeric Chat ID: " CHAT_ID

echo "اسم کانفیگ‌های WireGuard رو وارد کن (مثل wg1 یا wg1,wg2,wg3):"
read -p "WireGuard Configs: " CONFIGS_INPUT

FILES_LIST="    \"/root/WGDashboard/src/db/wgdashboard_job.db\",\n    \"/root/WGDashboard/src/db/wgdashboard.db\","
IFS=',' read -ra CONFIG_ARRAY <<< "$CONFIGS_INPUT"
for config in "${CONFIG_ARRAY[@]}"; do
  FILES_LIST="${FILES_LIST}\n    \"/etc/wireguard/${config}.conf\","
done
FILES_LIST=$(echo -e "${FILES_LIST%?}")  # حذف کامای آخر + تبدیل \n به خط واقعی

echo -e "\n⚙️ نصب نیازمندی‌ها..."
apt update -y
apt install -y python3 python3-pip cron

# --- ✅ رفع ارور externally-managed-environment ---
echo -e "\n🔧 بررسی محدودیت pip..."
mkdir -p ~/.config/pip
cat > ~/.config/pip/pip.conf <<'EOF'
[global]
break-system-packages = true
EOF
echo "✅ pip.conf ساخته شد (محدودیت برطرف شد)"

# حالا نصب پکیج‌ها بدون خطا:
pip3 install --no-cache-dir python-telegram-bot==13.15

# --- ساخت اسکریپت بکاپ ---
cat > /root/backup_bot.py <<EOF
import os
import tarfile
import time
from telegram import Bot

TOKEN = '${BOT_TOKEN}'
CHAT_ID = '${CHAT_ID}'

FILES_TO_BACKUP = [
${FILES_LIST}
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

if __name__ == '__main__':
    bot = Bot(token=TOKEN)
    path = make_backup()
    if path:
        send_backup_file(bot, path)
EOF

# --- تنظیم کرون‌جاب برای هر ۳ ساعت ---
(crontab -l 2>/dev/null; echo "0 */3 * * * /usr/bin/python3 /root/backup_bot.py") | crontab -

echo -e "\n✅ نصب کامل شد!"
echo "📦 فایل: /root/backup_bot.py"
echo "⏰ کرون‌جاب تنظیم شد (هر ۳ ساعت)"
echo "🔹 برای تست دستی:"
echo "python3 /root/backup_bot.py"
