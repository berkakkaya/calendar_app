import 'package:calendar_app/consts/strings.dart';
import 'package:calendar_app/models/enums.dart';
import 'package:calendar_app/models/user.dart';
import 'package:calendar_app/screens/login_register/welcome_screen.dart';
import 'package:calendar_app/utils/api.dart';
import 'package:calendar_app/utils/checks.dart';
import 'package:calendar_app/utils/singletons/s_user.dart';
import 'package:calendar_app/widgets/info_placeholder.dart';
import 'package:calendar_app/widgets/popups.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  FullUser? user;
  bool isLoggingOut = false;

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil"),
      ),
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : _ProfileView(
              user: user!,
              logoutFunction: isLoggingOut ? null : () => logout(context),
            ),
    );
  }

  Future<void> fetchUser() async {
    late FullUser fetchedUser;

    await checkAuthenticationStatus(
      context: context,
      apiCall: () async {
        fetchedUser = await ApiManager.getProfile();

        return fetchedUser;
      },
    );

    if (fetchedUser.responseStatus == ResponseStatus.authorizationError) {
      if (context.mounted) Navigator.of(context).pop();
      return;
    }

    if (fetchedUser.responseStatus == ResponseStatus.invalidRequest) {
      if (context.mounted) Navigator.of(context).pop();
      return;
    }

    if (fetchedUser.responseStatus == ResponseStatus.serverError) {
      if (context.mounted) {
        await showWarningPopup(
          context: context,
          title: "Sunucu hatası",
          content: [const Text(serverError)],
        );
      }

      return;
    }

    setState(() {
      user = fetchedUser;
    });
  }

  Future<void> logout(BuildContext context) async {
    if (isLoggingOut) return;

    setState(() {
      isLoggingOut = true;
    });

    final bool isConfirmed = await showConfirmationDialog(
      context: context,
      title: "Oturumu kapat",
      content: [const Text("Oturumu kapatmayı gerçekten istiyor musunuz?")],
    );

    if (!isConfirmed) {
      if (context.mounted) {
        setState(() {
          isLoggingOut = false;
        });
      }

      return;
    }

    // Unset the access and refresh tokens
    SharedPreferences preferences = await SharedPreferences.getInstance();

    await preferences.remove("accessToken");
    await preferences.remove("refreshToken");

    ApiManager.setTokens(
      accessToken: null,
      refreshToken: null,
    );

    SUser.resetAll();

    // Return to the welcome screen
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const WelcomeScreen(),
        ),
        (route) => false,
      );
    }
  }
}

class _ProfileView extends StatelessWidget {
  final FullUser user;
  final void Function()? logoutFunction;

  const _ProfileView({
    required this.user,
    required this.logoutFunction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Spacer(),
          InfoPlaceholder(
            icon: const Icon(Icons.person_outline_rounded),
            title: "Adınız ve Soyadınız",
            content: Text("${user.name!} ${user.surname!}"),
          ),
          const SizedBox(height: 32),
          InfoPlaceholder(
            icon: const Icon(Icons.alternate_email_rounded),
            title: "Kullanıcı Adınız",
            content: Text("@${user.username!}"),
          ),
          const SizedBox(height: 32),
          InfoPlaceholder(
            icon: const Icon(Icons.email_outlined),
            title: "E-postanız",
            content: Text(user.email!),
          ),
          const SizedBox(height: 32),
          InfoPlaceholder(
            icon: const Icon(Icons.badge_outlined),
            title: "T.C. Kimlik Numaranız",
            content: Text("${user.tcIdentityNumber!}"),
          ),
          const SizedBox(height: 32),
          InfoPlaceholder(
            icon: const Icon(Icons.phone_outlined),
            title: "Telefon Numaranız",
            content: Text(user.phone!),
          ),
          const SizedBox(height: 32),
          InfoPlaceholder(
            icon: const Icon(Icons.location_on_outlined),
            title: "Adresiniz",
            content: Text(
              user.address!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const Spacer(),
          FilledButton(
            onPressed: logoutFunction,
            child: const Text("Çıkış Yap"),
          ),
        ],
      ),
    );
  }
}
