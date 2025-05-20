# WgDashboard-Backup

اسکریپت بکاپ‌گیری خودکار از دیتابیس و کانفیگ‌های WireGuard در WGDashboard و ارسال آن به ربات تلگرام شما.

---

## ویژگی‌ها:
- بکاپ‌گیری از فایل‌های دیتابیس WGDashboard
- پشتیبانی از چندین فایل کانفیگ WireGuard (مثلاً: `wg1`, `wg2`, ...)
- پشتیبانی از job ها
- پشتیبانی از data usage کاربران
- ارسال خودکار فایل بکاپ به ربات تلگرام شما
- حذف فایل بکاپ بعد از ارسال
- اجرای خودکار هر ۳ ساعت با کرون‌جاب

---

## نصب سریع (با یک خط دستور)

کافیست دستور زیر را در سرور اوبونتوی خود وارد کنید:

```bash
bash -i <(curl -sSL https://raw.githubusercontent.com/mr-sepehr/WgDashboard-Backup/main/WgdashboardBackup.sh)
