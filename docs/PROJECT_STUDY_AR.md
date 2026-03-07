# دراسة مشروع LightHouse Buffet

## نظرة عامة
التطبيق مبني بـ **Flutter (Dart)** ويستخدم:
- **BLoC** لإدارة الحالة (الفواتير والمنتجات)
- **Dio** للاتصال بالـ API
- **GetIt** و **SharedPreferences** للتخزين (غير مهيأ بشكل صحيح حالياً)
- **Syncfusion DataGrid** لعرض بيانات الفاتورة
- **Easy Localization** للترجمة (عربي/إنجليزي)

---

# الجزء الأول: أسباب إغلاق التطبيق أو توقفه (Crashes)

## 1. عدم تهيئة GetIt و SharedPreferences (أولوية عالية)

**الموقع:** `lib/core/utils/shared_prefrences.dart` و `lib/main.dart`

**المشكلة:** الدالة `setUp()` التي تسجّل `SharedPreferences` في GetIt **لا تُستدعى أبداً** من `main()`. بينما في `lib/core/utils/service.dart` يتم استخدام:
```dart
storage.get<SharedPreferences>().getString("token")
```
عند استدعاء `options(true)` (للطلبات التي تحتاج مصادقة). إذا تم استدعاء أي خدمة تستخدم `options(true)` قبل تهيئة GetIt، التطبيق **سيتوقف** بسبب استثناء من GetIt (مثل "Object/factory not registered").

**الحالة الحالية:** `CreateInvoiceService` يستخدم `options(false)` فقط، لذلك قد لا يظهر الخطأ في مسار إنشاء الفاتورة الحالي. لكن أي شاشة أو خدمة مستقبلية تستخدم المصادقة ستسبب إغلاق التطبيق.

**التوصية:** استدعاء `await setUp()` في `main()` قبل `runApp()` وضمان تهيئة GetIt مرة واحدة عند بدء التطبيق.

---

## 2. استثناءات Dio بدون التحقق من null (أولوية عالية)

**الموقع:**  
- `lib/features/invoice/data/source/remote/create_invoice_service.dart` (سطور 21–24)  
- `lib/features/invoice/data/repository/create_invoice_repo.dart` (سطور 31–34)

**المشكلة:** في `CreateInvoiceService`:
```dart
} on DioException catch (e) {
  if (e.response!.data["status"] == "BAD_REQUEST") {
```
يتم استخدام `e.response!` و `e.response!.data` بدون التحقق من أن `e.response` أو `e.response.data` غير null. في حالات مثل:
- انقطاع الشبكة
- timeout
- اتصال مرفوض (connection refused)

قد يكون `e.response` **null**، فيؤدي ذلك إلى استثناء غير معالج وإغلاق التطبيق.

**نفس الفكرة** في `create_invoice_repo.dart` عند استخدام `e.response!.data`.

**التوصية:** التحقق دائماً من `e.response != null` و `e.response?.data != null` قبل الوصول إلى الحقول، ومعاملة الحالات التي لا يوجد فيها response (مثل عدم الاتصال) بشكل آمن (مثلاً إرجاع رسالة خطأ مناسبة بدلاً من إعادة رمي الاستثناء).

---

## 3. setState بعد عمليات async بدون التحقق من mounted (أولوية عالية)

**الموقع:**  
- `lib/features/client_scan/presentation/view/scan_page.dart` (بعد `_verifyQrCode`)  
- `lib/features/invoice/presentation/view/invoice_page.dart` (داخل `onBarcodeScanned`)

**المشكلة:** بعد `await` (مثلاً بعد استدعاء الـ API)، يتم استدعاء `setState()` أو استخدام `context` (مثل `Navigator.push(context, ...)` أو `ScaffoldMessenger.of(context)`). إذا كان المستخدم قد غادر الشاشة أو أزال الـ widget من الشجرة، يصبح الـ widget **غير mounted** واستدعاء `setState` يسبب الخطأ المعروف: **"setState() called after dispose()"** أو استخدام **context بعد الـ dispose**، مما قد يوقف التطبيق أو يسبب سلوكاً غير متوقع.

**أمثلة:**
- في `scan_page.dart`: بعد `await _qrCodeVerificationRepo.verifyQrCode(qrCode)` يتم استدعاء `setState` و `Navigator.push(context, ...)` بدون التحقق من `mounted`.
- في `invoice_page.dart`: داخل `onBarcodeScanned` بعد `await _getProductByBarcodeRepo.getProductByBarcode(value)` يتم استدعاء `setState` و `ScaffoldMessenger.of(context)` بدون التحقق من `mounted`.

**التوصية:** قبل أي `setState` أو استخدام `context` بعد `await`، التحقق من `if (!mounted) return;` ثم تنفيذ التحديث أو الانتقال.

---

## 4. عدم وجود معالجة أخطاء على مستوى التطبيق (أولوية متوسطة)

**الموقع:** `lib/main.dart`

**المشكلة:** لا يوجد:
- `FlutterError.onError` لالتقاط أخطاء Flutter
- `runZonedGuarded` (أو ما يعادله) لالتقاط الأخطاء غير المعالجة في الـ zone
- **ErrorWidget.builder** لعرض واجهة بديلة عند فشل بناء widget بدلاً من الشاشة الحمراء

أي استثناء غير مُلتقط في الشجرة يمكن أن يظهر للمستخدم كشاشة حمراء أو يغلق التطبيق دون تسجيل أو معالجة منظمة.

**التوصية:** إضافة معالجة أخطاء مركزية في `main()` (مثل `FlutterError.onError` و zone guard) واختيارياً **ErrorWidget.builder** لعرض رسالة ودية بدلاً من الـ stack trace الكامل.

---

## 5. استخدام RawKeyboardListener (مهمة صيانة)

**الموقع:** `lib/features/invoice/presentation/widget/invoice_widget.dart`

**المشكلة:** `RawKeyboardListener` **مهمل (deprecated)** في Flutter. يُفضّل استخدام آلية الـ focus الجديدة (مثل `Focus` و `KeyboardListener` أو `Shortcuts`). عدم التحديث قد يسبب تحذيرات أو سلوكاً غير متوقع في إصدارات مستقبلية.

**التوصية:** استبدال `RawKeyboardListener` بـ `KeyboardListener` أو آلية الـ focus الموصى بها في الوثائق الرسمية.

---

## 6. عدم وجود تسجيل للأعطال (Crash reporting)

**المشكلة:** لا يوجد تكامل مع أدوات مثل **Firebase Crashlytics** أو **Sentry**. عند حدوث تعطل في أجهزة المستخدمين، لا يوجد تقرير تلقائي يساعد في تتبع السبب.

**التوصية:** إضافة Crashlytics أو Sentry (أو غيرهما) وتسجيل الأخطاء غير المعالجة والاستثناءات الحرجة لتحليل أسباب الإغلاق وتحسين الاستقرار.

---

# الجزء الثاني: تحسين السرعة والأداء

## 1. تهيئة الاعتماديات مرة واحدة وإعادة استخدامها (أولوية عالية)

**الموقع:** `lib/features/invoice/presentation/view/invoice_page.dart` و `lib/features/client_scan/presentation/view/scan_page.dart`

**المشكلة:** في كل مرة يتم فيها فتح الشاشة يتم إنشاء:
- عدة نسخ من `Dio()`
- عدة نسخ من `NetworkConnection` و `InternetConnectionChecker.createInstance(...)`
- خدمات وريبو جديدة

هذا يزيد استهلاك الذاكرة ويُبطئ فتح الشاشة، ويفتح اتصالات/موارد قد لا تُغلَق بشكل صريح.

**التوصية:**  
- تسجيل `Dio` و `NetworkConnection` (وغيرها من الخدمات المشتركة) في GetIt أو في مكان مركزي واحد.  
- إنشاء الـ repositories والـ use cases مرة واحدة (على مستوى التطبيق أو الصفحة عند أول دخول) وإعادة استخدامها بدلاً من إنشائها في كل `build` أو عند كل دخول للشاشة.

---

## 2. إنشاء BLoC واعتمادياته داخل build (أولوية عالية)

**الموقع:** `lib/features/invoice/presentation/view/invoice_page.dart` — `MultiBlocProvider` و `BlocProvider(create: ...)`

**المشكلة:** داخل `build()` يتم إنشاء:
- `GetAllProductsBloc` مع `GetAllProductsUsecase` و `GetAllProductsRepo` و `GetAllProductsService` و `NetworkConnection` و...  
- `CreateInvoiceBloc` مع `CreateInvoiceRepo` وخدماته وـ `NetworkConnection`...

دالة `build` يمكن أن تُستدعى كثيراً. إنشاء كل هذه الكائنات في كل مرة يعيد بناء الـ widget يسبب:
- استهلاك ذاكرة ووقت معالجة غير ضروري
- احتمال إعادة جلب البيانات أو إعادة تهيئة الحالة بشكل غير متوقع

**التوصية:**  
- نقل إنشاء الـ BLoCs والريبو والخدمات إلى مستوى أعلى (مثلاً في الـ parent مرة واحدة)، أو استخدام **RepositoryProvider** و **BlocProvider** مع حقن الاعتماديات من GetIt.  
- تجنب إنشاء شبكة كاملة من الـ repos والـ services داخل `create` الذي يُستدعى من `build`.

---

## 3. تحسين قائمة المنتجات (GridView) (أولوية متوسطة)

**الموقع:** `lib/features/invoice/presentation/view/invoice_page.dart` — `GridView.builder` وعناصر `ProductCardWidget`

**المشكلة:**  
- تحويل كل عنصر من الـ response إلى `ProductModel` داخل `itemBuilder` عبر `ProductModel.fromMap(state.response.body[index].toMap())` في كل إعادة بناء.  
- عدم استخدام `const` حيثما أمكن يزيد عدد إعادة البناء غير الضرورية.

**التوصية:**  
- تخزين قائمة `ProductModel` في الحالة (مثلاً في الـ BLoC) بعد جلب البيانات مرة واحدة، واستخدامها في الـ Grid بدون إعادة تحويل في كل frame.  
- استخدام `itemExtent` أو `childAspectRatio` ثابت لتحسين أداء الـ scroll.  
- إضافة `cacheExtent` إذا كانت القائمة طويلة لتحسين السلوك عند التمرير.  
- جعل الـ widgets التي لا تعتمد على بيانات متغيرة `const` حيثما أمكن.

---

## 4. إعادة إنشاء ProductDataSource في كل تحديث (أولوية متوسطة)

**الموقع:** `lib/features/invoice/presentation/view/invoice_page.dart` — `_updateTotalPrice()` و `productDataSource = ProductDataSource(...)`

**المشكلة:** في كل تغيير للكمية أو إزالة منتج يتم استدعاء `_updateTotalPrice()` التي تعيد إنشاء `ProductDataSource` بالكامل. الـ `InvoiceWidget` يعتمد على `productDataSource`؛ إعادة الإنشاء المتكررة قد تسبب إعادة بناء كبيرة للواجهة وتستهلك وقت معالجة.

**التوصية:**  
- تصميم `ProductDataSource` بحيث يدعم تحديث البيانات (مثلاً طريقة `updateData(List<ProductInvoice> newData)`) دون إنشاء كائن جديد في كل مرة، أو تقليل عدد مرات إنشاء الـ DataSource إلى الحد الأدنى.

---

## 5. استخدام Syncfusion DataGrid مقابل ListView في InvoiceWidget (أولوية منخفضة)

**الموقع:** `lib/features/invoice/data/source/local/product_data_source.dart` و `lib/features/invoice/presentation/widget/invoice_widget.dart`

**المشكلة:** في الواقع واجهة الفاتورة تعرض قائمة عناصر باستخدام **ListView.builder** مع تصميم مخصص لكل عنصر. الـ `ProductDataSource` المستخدم مع Syncfusion **DataGrid** يبدو أنه مصمم لـ DataGrid، بينما في الواجهة يتم استخدام **ListView** مع `widget.productDataSource.rows`. خلط الاستخدام أو وجود مصدر بيانات ثقيل بدون حاجة لجميع إمكانيات الـ grid قد يزيد التعقيد والأعباء.

**التوصية:** توحيد العرض: إما استخدام قائمة عادية من `ProductInvoice` مع `ListView.builder` فقط (بدون Syncfusion لهذه القائمة) لتبسيط الكود وتحسين الأداء، أو الاستفادة من ميزات الـ DataGrid (مثل الـ virtualization) بشكل واضح وتقليل إعادة البناء.

---

## 6. طلبات الشبكة والتحقق من الاتصال (أولوية متوسطة)

**المشكلة:** في كل طلب يتم التحقق من الاتصال عبر `networkConnection.isConnected` (الذي يستخدم عناوين مثل Google و 1.1.1.1). إنشاء `InternetConnectionChecker` جديد في أماكن متعددة مع نفس القوائم يكرر الموارد.

**التوصية:**  
- استخدام نسخة واحدة مشتركة من `NetworkConnection` / `InternetConnectionChecker` (مثلاً عبر GetIt).  
- إضافة **timeout** واضح لطلبات Dio لتجنب الانتظار الطويل عند ضعف الشبكة.  
- تخزين مؤقت (cache) لنتيجة "قائمة المنتجات" لفترة قصيرة إذا كانت البيانات لا تتغير كل ثانية، لتقليل عدد الطلبات عند الدخول المتكرر للشاشة.

---

## 7. أصلاح ثغرة في Service.options (أولوية منخفضة لكن مهمة للأمان)

**الموقع:** `lib/core/utils/service.dart`

**المشكلة:** عند استدعاء `options(true)` إذا كان الـ token يساوي `null`، الـ header يصبح `'Bearer null '` مما قد يسبب رفض الطلبات أو سلوكاً غير متوقع من الخادم.

**التوصية:** التحقق من وجود الـ token قبل إضافته إلى الـ header، وإما عدم إرسال مصادقة أو إرجاع خطأ واضح للمستخدم (مثل "يجب تسجيل الدخول أولاً").

---

# ملخص التوصيات حسب الأولوية

| الأولوية | الإجراء |
|----------|---------|
| عالية (استقرار) | تهيئة GetIt في `main()`، التحقق من `e.response` في Dio، استخدام `mounted` قبل `setState` و `context` بعد async |
| عالية (أداء) | تهيئة Dio و NetworkConnection والخدمات مرة واحدة، عدم إنشاء BLoC وكل الاعتماديات داخل `build` |
| متوسطة | معالجة أخطاء مركزية في `main`، تحسين GridView وقائمة المنتجات، تقليل إعادة إنشاء ProductDataSource |
| منخفضة | استبدال RawKeyboardListener، إضافة Crashlytics/Sentry، توحيد عرض قائمة الفاتورة، معالجة token null |

بعد تطبيق التوصيات ذات الأولوية العالية، من المتوقع أن يقل عدد الإغلاقات غير المتوقعة وأن يصبح التطبيق أسرع وأكثر استقراراً. يمكن بعدها المتابعة مع تحسينات الأداء المتوسطة والمنخفضة حسب الحاجة.
