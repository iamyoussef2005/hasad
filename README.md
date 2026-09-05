# 🌿 حصاد | Hasad FreshStock
### نظام متكامل لإدارة مخزون محلات الخضار والفواكه والمنتجات الطازجة (Produce Inventory ERP)

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.38.5-02569B?logo=flutter" alt="Flutter" />
  <img src="https://img.shields.io/badge/Dart-3.10-0175C2?logo=dart" alt="Dart" />
  <img src="https://img.shields.io/badge/State_Management-Riverpod-2ECC71" alt="Riverpod" />
  <img src="https://img.shields.io/badge/Architecture-Feature--First_Clean_Architecture-FF6F00" alt="Clean Architecture" />
  <img src="https://img.shields.io/badge/UI_Style-Glassmorphic_Material_3-8E44AD" alt="Material 3" />
  <img src="https://img.shields.io/badge/Platforms-Android_%7C_iOS_%7C_Web_%7C_Desktop-brightgreen" alt="Platforms" />
</p>

---

## 📖 نظرة عامة عن المشروع (Project Overview)

تطبيق **"حصاد | Hasad FreshStock"** هو نظام متخصص لإدارة سلسلة إمداد ومخزون محلات الخضار والفواكه والمنتجات الزراعية سريعة التلف (Perishable Goods). 

تم بناء التطبيق لمعالجة تحديات واقعية معقدة تواجه تجار التجزئة في سوق الأغذية الطازجة:
1. **التلف والهدر السريع (Spoilage & Shrinkage):** الخضار والورقيات تفقد قيمتها خلال أيام، ويتطلب العمل التجاري تتبعاً دقيقاً للهدر المالي.
2. **تعدد وتغير وحدات القياس (Multi-Unit Handling):** البيع بالوزن (كغ/غرام)، الصناديق (Boxes)، الحبات، أو الربطات (Bundles).
3. **تذبذب أسعار سوق الجملة اليومي (Wholesale Price Volatility):** تتبع هوامش الربح الحقيقية استناداً لتقلبات سوق الخضار المركزي.
4. **حاسبة ميزان سريعة لنقاط البيع (Smart POS Weight Scale):** تسريع خدمة الزبائن وخصم المخزون فورياً.

---

## 📱 المميزات الرئيسية (Key Highlights)

| الميزة | الوصف التقني |
|---|---|
| **📊 لوحة تحكم ذكية (KPI Dashboard)** | عرض القيمة السوقية للمخزون، مبيعات اليوم، الخسائر الناتجة عن التلف، ومؤشر النضارة العام. |
| **📉 نظام تتبع الهدر والخسائر (Waste Tracker)** | تسجيل تلف الأصناف مع تصنيف الأسباب (ذبول طبيعي، تلف نقل، سوء تبريد) واحتساب الخسارة المالية تلقائياً. |
| **⚖️ حاسبة ميزان ونقطة بيع سريعة (Quick POS)** | واجهة تزن الصنف تلقائياً وتتيح خيارات سريعة (+0.25، +0.5، +1 كغ) مع سلة شراء وخصم فوري من المخزون. |
| **📈 تتبع تقلبات أسعار سوق الجملة** | رسم بياني تفاعلي باستخدام `fl_chart` يقارن سعر التكلفة اليومي بسعر البيع وهامش الربح. |
| **📦 إدارة دفعات التوريد (Batch Tracking)** | تسجيل دفعات الاستلام من المزارع وأسواق الجملة مع تواريخ التوريد والكميات المتبقية. |
| **🌐 دعم ثنائي اللغة (RTL & LTR)** | دعم كامل للغتين العربية والإنجليزية مع تبديل فوري وحفظ الحالة. |
| **🌓 الوضع الليلي والفاتح (Dark / Light Theme)** | تصميم مريح للعين مبني بنظام Glassmorphism ولمسات الزمرد الأخضر والألوان الحمضية. |

---

## 🏛️ المعمارية البرمجية (Software Architecture)

تم اتباع نمط **Feature-First Clean Architecture** لضمان فصل الاهتمامات وقابلية الاختبار والتوسع:

```
lib/
├── core/
│   ├── constants/            # لوحة الألوان والخطوط والأبعاد
│   │   ├── app_colors.dart
│   │   └── app_typography.dart
│   ├── localization/         # نصوص الترجمة العربية والإنجليزية ومزود اللغة
│   │   ├── app_locale_provider.dart
│   │   └── app_strings.dart
│   └── theme/                # سمات Material 3 للوضع الفاتح والداكن
│       └── app_theme.dart
├── data/
│   ├── models/               # النماذج الأساسية
│   │   ├── produce_item.dart
│   │   ├── produce_category.dart
│   │   ├── batch_item.dart
│   │   ├── waste_record.dart
│   │   └── price_point.dart
│   └── repositories/         # نمط المستودعات والبيانات الأولية
│       ├── produce_repository.dart
│       └── mock_produce_data.dart
├── presentation/
│   ├── controllers/          # مزودات إدارة الحالة (Riverpod State Notifiers)
│   │   ├── inventory_controller.dart
│   │   ├── waste_controller.dart
│   │   └── pos_controller.dart
│   ├── screens/              # الشاشات الرئيسية
│   │   ├── main_shell_screen.dart
│   │   ├── dashboard/
│   │   ├── inventory/
│   │   ├── pos/
│   │   ├── waste/
│   │   └── analytics/
│   └── widgets/              # العناصر القابلة لإعادة الاستخدام
└── main.dart
```

---

## 🛠️ التقنيات والمكتبات المستخدمة (Tech Stack)

- **Flutter SDK:** 3.38+
- **Dart:** 3.10+
- **State Management:** [flutter_riverpod](https://pub.dev/packages/flutter_riverpod)
- **Charts & Data Visualization:** [fl_chart](https://pub.dev/packages/fl_chart)
- **Typography & Fonts:** [google_fonts](https://pub.dev/packages/google_fonts) (IBM Plex Sans Arabic)
- **Localization:** [flutter_localizations](https://api.flutter.dev/flutter/flutter_localizations/flutter_localizations-library.html) & [intl](https://pub.dev/packages/intl)
- **Animations:** [flutter_animate](https://pub.dev/packages/flutter_animate)
- **Utility:** [uuid](https://pub.dev/packages/uuid)

---

## 🧪 الاختبارات الآلية (Testing & Quality Assurance)

المشروع مغطى باختبارات Unit Tests و Widget Smoke Tests لضمان دقة العمليات الحسابية:
- دقة معادلات هامش الربح `profitMargin`.
- سلوك إطلاق تنبيهات انخفاض المخزون `isLowStock`.
- تراكم الأوزان وحسابات نقطة البيع في `posNotifierProvider`.
- احتساب الخسارة المالية الناتجة عن التلف وخصم المخزون.

لتشغيل الاختبارات:
```bash
flutter test
```

---

## 🚀 تشغيل المشروع (Getting Started)

1. تأكد من تثبيت بيئة عمل Flutter:
```bash
flutter doctor
```

2. تثبيت الحزم والمكتبات:
```bash
flutter pub get
```

3. تشغيل التطبيق:
```bash
flutter run
```
