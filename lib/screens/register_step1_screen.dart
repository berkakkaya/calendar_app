import 'package:animations/animations.dart';
import 'package:calendar_app/consts/colors.dart';
import 'package:calendar_app/consts/illustrations.dart';
import 'package:calendar_app/models/register_data.dart';
import 'package:calendar_app/screens/register_step2_screen.dart';
import 'package:calendar_app/widgets/progress_counter.dart';
import 'package:flutter/material.dart';

class RegisterStep1Screen extends StatefulWidget {
  const RegisterStep1Screen({super.key});

  @override
  State<RegisterStep1Screen> createState() => _RegisterStep1ScreenState();
}

class _RegisterStep1ScreenState extends State<RegisterStep1Screen> {
  String name = "";
  String surname = "";
  String username = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kayıt Ol"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(flex: 1),
              Expanded(
                flex: 2,
                child: personalInfoIllustration,
              ),
              const Spacer(flex: 1),
              TextField(
                decoration: const InputDecoration(
                  label: Text("Adınız"),
                  filled: true,
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                keyboardType: TextInputType.name,
                onChanged: nameChanged,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  label: Text("Soyadınız"),
                  filled: true,
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                keyboardType: TextInputType.name,
                onChanged: surnameChanged,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  label: Text("Kullanıcı adınız"),
                  filled: true,
                  prefixIcon: Icon(Icons.alternate_email_outlined),
                ),
                onChanged: usernameChanged,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: goToNextPage,
                child: const Text("Devam et"),
              ),
              const SizedBox(height: 16),
              const ProgressCounter(totalCount: 3, current: 1),
            ],
          ),
        ),
      ),
    );
  }

  void nameChanged(String name) {
    this.name = name;
  }

  void surnameChanged(String surname) {
    this.surname = surname;
  }

  void usernameChanged(String username) {
    this.username = username;
  }

  void goToNextPage() {
    final data = RegisterData();

    data.name = name;
    data.surname = surname;
    data.username = username;

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return RegisterStep2Screen(registerData: data);
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
