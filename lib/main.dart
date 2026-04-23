import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lighthouse_buffet/core/di/injection.dart';
import 'package:lighthouse_buffet/core/resources/colors.dart';
import 'package:lighthouse_buffet/core/utils/shared_prefrences.dart';
import 'package:lighthouse_buffet/features/client_scan/presentation/view/scan_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setUp();
  await initInjection();
  await EasyLocalization.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    if (kReleaseMode) {
      // Optional: send to Firebase Crashlytics or Sentry, e.g.:
      // FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      // or Sentry.captureException(details.exception, stackTrace: details.stack);
    }
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      child: Container(
        color: Colors.white,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[700]),
            const SizedBox(height: 16),
            Text(
              'Something went wrong.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey[800]),
            ),
          ],
        ),
      ),
    );
  };

  runZonedGuarded(
    () {
      runApp(
        EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('ar')],
          path: "assets/translations",
          fallbackLocale: const Locale('en'),
          startLocale: const Locale('en'),
          child: const MainApp(),
        ),
      );
    },
    (error, stackTrace) {
      if (kReleaseMode) {
        // Optional: send to Firebase Crashlytics or Sentry, e.g.:
        // FirebaseCrashlytics.instance.recordError(error, stackTrace);
        // or Sentry.captureException(error, stackTrace: stackTrace);
      } else {
        debugPrint('Unhandled error: $error');
        debugPrint(stackTrace.toString());
      }
    },
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: "LightHouse",
      theme: ThemeData(
        fontFamily: "Proxima Nova",
        colorScheme: ColorScheme.fromSwatch().copyWith(
          brightness: Brightness.dark,
          primary: orange,
          secondary: orange,
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: orange,
          ),
        ),
        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontSize: 30.0,
            fontWeight: FontWeight.w800,
            fontFamily: context.locale.countryCode == 'en'
                ? "Proxima Nova"
                : "NotoSansArabic",
            color: Colors.white,
          ),
          titleMedium: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.w600,
            fontFamily: context.locale.countryCode == 'en'
                ? "Proxima Nova"
                : "NotoSansArabic",
            color: navy,
          ),
          titleSmall: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w600,
            fontFamily: context.locale.countryCode == 'en'
                ? "Proxima Nova"
                : "NotoSansArabic",
            color: navy,
          ),
          bodyLarge: TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.w400,
            fontFamily: context.locale.countryCode == 'en'
                ? "Raleway"
                : "NotoKufiArabic",
            color: navy,
          ),
          bodyMedium: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w400,
            fontFamily: context.locale.countryCode == 'en'
                ? "Raleway"
                : "NotoKufiArabic",
            color: navy,
          ),
          bodySmall: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            fontFamily: context.locale.countryCode == 'en'
                ? "Raleway"
                : "NotoKufiArabic",
            color: navy,
          ),
          labelLarge: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            fontFamily: context.locale.countryCode == 'en'
                ? "Proxima Nova"
                : "NotoSansArabic",
            color: navy,
          ),
          labelMedium: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            fontFamily: context.locale.countryCode == 'en'
                ? "Proxima Nova"
                : "NotoSansArabic",
            color: navy,
          ),
          labelSmall: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            fontFamily: context.locale.countryCode == 'en'
                ? "Proxima Nova"
                : "NotoSansArabic",
            color: navy,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: orange,
            foregroundColor: darkNavy,
          ),
        ),
        scaffoldBackgroundColor: darkNavy,
        useMaterial3: true,
      ),
      home: const ScanPage(),
    );
  }
}
