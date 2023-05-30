import 'package:animations/animations.dart';
import 'package:calendar_app/consts/colors.dart';
import 'package:calendar_app/consts/illustrations.dart';
import 'package:calendar_app/consts/strings.dart';
import 'package:calendar_app/models/register_data.dart';
import 'package:calendar_app/screens/login_register/register_step3_screen.dart';
import 'package:calendar_app/widgets/popups.dart';
import 'package:calendar_app/widgets/progress_counter.dart';
import 'package:flutter/material.dart';

class RegisterStep2Screen extends StatefulWidget {
  final RegisterData registerData;

  const RegisterStep2Screen({super.key, required this.registerData});

  @override
  State<RegisterStep2Screen> createState() => _RegisterStep2ScreenState();
}

class _RegisterStep2ScreenState extends State<RegisterStep2Screen> {
  String email = "";
  String password = "";
  String passwordAgain = "";

  bool passwordMismatch = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kayıt Ol"),
      ),
      body: SafeArea(
        child: LayoutBuilder(builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            reverse: true,
            child: ListBody(
              children: [
                passwordIllustration,
                const SizedBox(height: 32),
                TextField(
                  decoration: const InputDecoration(
                    label: Text("E-postanız"),
                    filled: true,
                    prefixIcon: Icon(Icons.alternate_email_rounded),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: emailChanged,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    label: const Text("Şifreniz"),
                    filled: true,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    errorText: passwordMismatch ? "Şifreler eşleşmiyor." : null,
                  ),
                  obscureText: true,
                  onChanged: passwordChanged,
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    label: const Text("Şifreniz (yeniden)"),
                    filled: true,
                    prefixIcon: const Icon(Icons.lock_outline_rounded),
                    errorText: passwordMismatch ? "Şifreler eşleşmiyor." : null,
                  ),
                  obscureText: true,
                  onChanged: passwordAgainChanged,
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: () => goToNextPage(context),
                  child: const Text("Devam et"),
                ),
                const SizedBox(height: 16),
                const ProgressCounter(totalCount: 3, current: 2),
              ],
            ),
          );
        }),
      ),
    );
  }

  void emailChanged(String text) {
    email = text;
  }

  void passwordChanged(String text) {
    password = text;
  }

  void passwordAgainChanged(String text) {
    passwordAgain = text;
  }

  void goToNextPage(context) {
    if ([email, password, passwordAgain].contains("")) {
      showWarningPopup(
        context: context,
        title: "Uyarı",
        content: [const Text(emptyInputWarning)],
      );

      return;
    }

    setState(() {
      passwordMismatch = password != passwordAgain;
    });

    if (passwordMismatch) return;

    widget.registerData.email = email;
    widget.registerData.password = password;

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return RegisterStep3Screen(registerData: widget.registerData);
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SharedAxisTransition(
            transitionType: SharedAxisTransitionType.horizontal,
            animation: animation,
            secondaryAnimation: secondaryAnimation,
            fillColor: color1,
            child: child,
          );
        },
      ),
    );
  }
}
