import 'package:animations/animations.dart';
import 'package:calendar_app/consts/colors.dart';
import 'package:calendar_app/consts/strings.dart';
import 'package:calendar_app/models/register_data.dart';
import 'package:calendar_app/models/response_status.dart';
import 'package:calendar_app/screens/events/home_screen.dart';
import 'package:calendar_app/utils/api.dart';
import 'package:calendar_app/widgets/info_placeholder.dart';
import 'package:calendar_app/widgets/popups.dart';
import 'package:flutter/material.dart';

class RegisterConfirmationScreen extends StatefulWidget {
  final RegisterData registerData;

  const RegisterConfirmationScreen({super.key, required this.registerData});

  @override
  State<RegisterConfirmationScreen> createState() =>
      _RegisterConfirmationScreenState();
}

class _RegisterConfirmationScreenState
    extends State<RegisterConfirmationScreen> {
  bool registerLock = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bilgileri Onaylayın"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Spacer(),
              InfoPlaceholder(
                icon: const Icon(Icons.person_outline_rounded, color: color5),
                title: "İsim ve Soyisim",
                content: Text(
                  "${widget.registerData.name!} ${widget.registerData.surname!}",
                ),
              ),
              const SizedBox(height: 32),
              InfoPlaceholder(
                icon: const SizedBox(
                  width: 16,
                  height: 16,
                  child: Icon(Icons.alternate_email_rounded, color: color5),
                ),
                title: "Kullanıcı Adınız",
                content: Text(widget.registerData.username!),
              ),
              const SizedBox(height: 32),
              InfoPlaceholder(
                icon: const SizedBox(
                  width: 16,
                  height: 16,
                  child: Icon(Icons.email_outlined, color: color5),
                ),
                title: "E-postanız",
                content: Text(widget.registerData.email!),
              ),
              const SizedBox(height: 32),
              InfoPlaceholder(
                icon: const SizedBox(
                  width: 16,
                  height: 16,
                  child: Icon(Icons.badge_outlined, color: color5),
                ),
                title: "T.C. Kimlik Numarası",
                content: Text(widget.registerData.tcIdentityNumber!.toString()),
              ),
              const SizedBox(height: 32),
              InfoPlaceholder(
                icon: const SizedBox(
                  width: 16,
                  height: 16,
                  child: Icon(Icons.phone_outlined, color: color5),
                ),
                title: "Telefon Numarası",
                content: Text(widget.registerData.phone!),
              ),
              const SizedBox(height: 32),
              InfoPlaceholder(
                icon: const SizedBox(
                  width: 16,
                  height: 16,
                  child: Icon(Icons.location_on_outlined, color: color5),
                ),
                title: "Adres",
                content: Text(widget.registerData.address!),
              ),
              const Spacer(),
              FilledButton(
                onPressed: widget.registerData.allDataProvided && !registerLock
                    ? () => register(context)
                    : null,
                child: const Text("Tamamdır, kaydı tamamla"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> register(BuildContext context) async {
    if (registerLock) return;

    setState(() {
      registerLock = true;
    });

    final authData = await ApiManager.register(
      registerData: widget.registerData,
    );

    if (authData.responseStatus == ResponseStatus.serverError) {
      if (context.mounted) {
        await showWarningPopup(
          context: context,
          title: "Sunucu hatası",
          content: [
            const Text(serverError),
          ],
        );

        setState(() {
          registerLock = false;
        });
      }

      return;
    }

    if (authData.responseStatus == ResponseStatus.duplicateExists) {
      if (context.mounted) {
        await showWarningPopup(
          context: context,
          title: "Hesap zaten kayıtlı",
          content: [const Text(duplicateAccountExists)],
        );

        setState(() {
          registerLock = false;
        });
      }

      return;
    }

    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return const HomeScreen();
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
        (route) => false,
      );
    }
  }
}
