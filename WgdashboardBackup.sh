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
        print(f"❌ خطا در بکاپ‌گیری: {e}")
        return None

def send_backup_file(bot, backup_path):
    try:
        with open(backup_path, "rb") as f:
            bot.send_document(chat_id=CHAT_ID, document=f, caption="🎯 بکاپ دستی یا خودکار WireGuard")
        print(f"✅ فایل بکاپ ارسال شد: {backup_path}")
    except Exception as e:
        print(f"⚠️ خطا در ارسال فایل بکاپ: {e}")
    finally:
        if os.path.exists(backup_path):
            os.remove(backup_path)
            print("🧹 فایل بکاپ حذف شد.")

if __name__ == '__main__':
    bot = Bot(token=TOKEN)
    path = make_backup()
    if path:
        send_backup_file(bot, path)
