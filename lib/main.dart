import 'package:calendar_app/screens/loading_screen.dart';
import 'package:calendar_app/utils/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'consts/colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.i.init();

  initializeDateFormatting("tr_TR");
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Calendar App",
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale("tr")],
      locale: const Locale("tr"),
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
          labelMedium: GoogleFonts.inter(
            fontSize: 12,
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
          backgroundColor: color6,
          foregroundColor: color1,
        ),
        checkboxTheme: Theme.of(context).checkboxTheme.copyWith(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
              fillColor: const MaterialStatePropertyAll(color2),
              checkColor: const MaterialStatePropertyAll(color1),
            ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoadingScreen(),
    );
  }
}
