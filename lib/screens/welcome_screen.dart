import 'package:calendar_app/consts/colors.dart';
import 'package:calendar_app/consts/fonts.dart';
import 'package:calendar_app/consts/illustrations.dart';
import 'package:calendar_app/consts/strings.dart';
import 'package:calendar_app/models/response_status.dart';
import 'package:calendar_app/screens/home_screen.dart';
import 'package:calendar_app/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animations/animations.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  String email = "";
  String password = "";
  bool loggingIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Hoşgeldiniz",
                style: headlineMedium,
                textAlign: TextAlign.center,
              ),
              const Spacer(flex: 1),
              Expanded(
                flex: 2,
                child: LayoutBuilder(builder: (context, constraints) {
                  if (constraints.maxHeight < 100) {
                    return const SizedBox();
                  }

                  return calendarIllustration;
                }),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: LayoutBuilder(builder: (context, constraints) {
                  if (constraints.maxHeight < 50) return const SizedBox();

                  return const Text(
                    welcomeScreenText,
                    textAlign: TextAlign.center,
                  );
                }),
              ),
              const Spacer(flex: 1),
              TextField(
                decoration: InputDecoration(
                  label: const Text("E-postanız"),
                  filled: true,
                  prefixIcon: const Icon(Icons.alternate_email_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  fillColor: color1,
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: emailOnEdit,
                enabled: !loggingIn,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  label: Text("Şifreniz"),
                  filled: true,
                  prefixIcon: Icon(Icons.lock_outline_rounded),
                ),
                obscureText: true,
                onChanged: passwordOnEdit,
                enabled: !loggingIn,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: loggingIn ? null : () => login(context),
                child: Text(loggingIn ? "Oturum açılıyor..." : "Oturum Aç"),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: loggingIn ? null : () => goToRegisterScreen(context),
                child: const Text(
                  "Hesabınız yok mu? Kayıt olun.",
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void emailOnEdit(String text) {
    email = text;
  }

  void passwordOnEdit(String text) {
    password = text;
  }

  Future<void> showInvalidEmailOrPasswordPopup() async {
    return await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Oturum açılamadı"),
          content: const SingleChildScrollView(
            child: ListBody(
              children: [
                Text(wrongEmailOrPassword),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Tamam"),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      },
    );
  }

  Future<void> login(BuildContext context) async {
    setState(() {
      loggingIn = true;
    });

    final response = await ApiManager.login(
      email: email,
      password: password,
    );

    if (response.responseStatus == ResponseStatus.wrongEmailOrPassword) {
      await showInvalidEmailOrPasswordPopup();

      return setState(() {
        loggingIn = false;
      });
    }

    SharedPreferences preferences = await SharedPreferences.getInstance();

    preferences.setString("accessToken", response.accessToken!);
    preferences.setString("refreshToken", response.refreshToken!);

    if (context.mounted) {
      setState(() {
        loggingIn = false;
      });

      Navigator.of(context).pushReplacement(
        PageRouteBuilder<void>(
          pageBuilder: (context, animation, secondAnimation) {
            return const HomeScreen();
          },
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              child: child,
            );
          },
        ),
      );
    }
  }

  void goToRegisterScreen(BuildContext context) {
    print("Triggered.");
  }
}
