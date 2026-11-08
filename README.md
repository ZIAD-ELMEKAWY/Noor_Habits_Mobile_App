# نور العادات — Noor Habits

تطبيق متابعة العادات الروحانية + منبه ذكي (Flutter)

## خطوات الحصول على APK موقّع (من غير تثبيت أي حاجة على الكمبيوتر)

### 1) ارفع المشروع على GitHub

- اعمل repo جديد وارفع كل الملفات دي عليه (عن طريق "upload files" من المتصفح).

### 2) ولّد Keystore (مرة واحدة بس)

- روح تبويب **Actions** في الريبو
- اختار workflow اسمه **Generate Keystore (run once)** واضغط **Run workflow**
- لما يخلص، افتح الـ artifact اسمه **keystore-files**
- افتح ملف `noor_keystore.b64` وانسخ محتواه كله (نص طويل)

### 3) ضيف الـ Secrets

- في الريبو: **Settings → Secrets and variables → Actions → New repository secret**
- ضيف الأربعة secrets دول:

| الاسم | القيمة |
| --- | --- |
| `ANDROID_KEYSTORE_BASE64` | محتوى ملف noor_keystore.b64 اللي نسخته |
| `KEYSTORE_PASSWORD` | `noor2026pass` |
| `KEY_PASSWORD` | `noor2026pass` |
| `KEY_ALIAS` | `noor` |

### 4) ابني الـ APK

- من تبويب **Actions** شغّل workflow اسمه **Build Signed APK**
- بعد 10-15 دقيقة هتلاقي artifact اسمه **NoorHabits-Signed** — ده الـ APK
- حمّله على الموبايل وثبّته (فعّل "التثبيت من مصادر غير معروفة")

### 5) التحديثات الجاية

- لو عدّلت على الكود وعملت push على فرع main، الـ APK الجديد يتبني تلقائياً
- وبما إنه موقّع بنفس الـ keystore، هتقدر تثبّت فوق النسخة القديمة من غير ما تضيع بياناتك

## ملاحظات

- لازم تسيب ملف `noor.keystore` وكلمة السر محفوظين عندك — من غيرهم مش هتقدر تحدّث التطبيق على نفس اسم الحزمة.
- المنبه الذكي محتاج تصريح "Alarms & reminders" يتفعّل يدوياً من إعدادات التطبيق على أندرويد 12+.
