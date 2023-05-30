import 'package:calendar_app/screens/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'consts/colors.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Calendar App",
      theme: ThemeData(
        colorSchemeSeed: color3,
        scaffoldBackgroundColor: color1,
        appBarTheme: const AppBarTheme(
          backgroundColor: color1,
        ),
        textTheme: TextTheme(
          bodyLarge: GoogleFonts.inter(
            fontWeight: FontWeight.w400,
            fontSize: 16,
            color: color5,
          ),
          bodyMedium: GoogleFonts.inter(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            color: color5,
          ),
          labelLarge: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: color5,
          ),
          titleLarge: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 22,
            color: color5,
          ),
          titleMedium: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: color5,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: color3,
              width: 2,
            ),
          ),
          fillColor: color1,
          iconColor: color3,
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.disabled)) {
                return Colors.black12;
              }

              return color3;
            }),
            padding: MaterialStateProperty.all(
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            minimumSize: MaterialStateProperty.all(const Size.fromHeight(64)),
            shape: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.pressed)) {
                return RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                );
              }

              if (states.contains(MaterialState.disabled)) {
                return RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                );
              }

              return RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              );
            }),
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          linearTrackColor: color3,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: color3,
          foregroundColor: color1,
        ),
        useMaterial3: true,
      ),
      home: const LoadingScreen(),
    );
  }
}
