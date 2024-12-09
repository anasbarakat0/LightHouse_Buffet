import 'package:flutter/material.dart';
import 'package:lighthouse_buffet/core/resources/colors.dart';
import 'package:lighthouse_buffet/features/client_scan/presentation/view/scan_page.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
       debugShowCheckedModeBanner: false,
       title: "LightHouse",
      theme: ThemeData(
        // brightness: Brightness.dark,
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
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headlineMedium: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          headlineSmall: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.normal,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.normal,
            color: darkNavy,
          ),
          labelLarge: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          labelMedium: TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          labelSmall: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w600,
            color: Colors.white,
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
      home: ScanPage(),
    );
  }
}
