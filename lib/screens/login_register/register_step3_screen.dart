import 'package:animations/animations.dart';
import 'package:calendar_app/consts/colors.dart';
import 'package:calendar_app/consts/illustrations.dart';
import 'package:calendar_app/consts/strings.dart';
import 'package:calendar_app/models/register_data.dart';
import 'package:calendar_app/screens/login_register/register_confirmation_screen.dart';
import 'package:calendar_app/widgets/popups.dart';
import 'package:calendar_app/widgets/progress_counter.dart';
import 'package:flutter/material.dart';

class RegisterStep3Screen extends StatefulWidget {
  final RegisterData registerData;

  const RegisterStep3Screen({super.key, required this.registerData});

  @override
  State<RegisterStep3Screen> createState() => _RegisterStep3ScreenState();
}

class _RegisterStep3ScreenState extends State<RegisterStep3Screen> {
  String tcIdentityNumber = "";
  String phone = "";
  String address = "";

  bool invalidIdentityNumber = false;

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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 1),
              Expanded(
                flex: 2,
                child: LayoutBuilder(builder: (context, constraints) {
                  if (constraints.maxHeight < 50) return const SizedBox();

                  return locationIllustration;
                }),
              ),
              const Spacer(flex: 1),
              TextField(
                decoration: InputDecoration(
                  label: const Text("T.C. Kimlik Numarası"),
                  filled: true,
                  prefixIcon: const Icon(Icons.badge_outlined),
                  errorText: invalidIdentityNumber
                      ? "Geçersiz T.C. kimlik numarası"
                      : null,
                ),
                keyboardType: TextInputType.number,
                onChanged: tcIdentityNumberChanged,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  label: Text("Telefon Numaranız"),
                  filled: true,
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                onChanged: phoneChanged,
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  label: Text("Adresiniz"),
                  filled: true,
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                keyboardType: TextInputType.streetAddress,
                onChanged: addressChanged,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: goToRegisterConfirmationScreen,
                child: const Text("Kaydı Tamamla"),
              ),
              const SizedBox(height: 16),
              const ProgressCounter(totalCount: 3, current: 3),
            ],
          ),
        ),
      ),
    );
  }

  void tcIdentityNumberChanged(String text) {
    tcIdentityNumber = text;
  }

  void phoneChanged(String text) {
    phone = text;
  }

  void addressChanged(String text) {
    address = text;
  }

  void goToRegisterConfirmationScreen() {
    if ([tcIdentityNumber, phone, address].contains("")) {
      showWarningPopup(
        context: context,
        title: "Uyarı",
        content: [const Text(emptyInputWarning)],
      );

      return;
    }

    widget.registerData.tcIdentityNumber = int.tryParse(tcIdentityNumber);
    widget.registerData.phone = phone;
    widget.registerData.address = address;

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return RegisterConfirmationScreen(registerData: widget.registerData);
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
