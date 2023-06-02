import 'package:calendar_app/consts/strings.dart';
import 'package:calendar_app/screens/events/home_screen.dart';
import 'package:calendar_app/screens/login_register/welcome_screen.dart';
import 'package:calendar_app/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  bool initializeLock = false;
  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  void initializeApp() async {
    if (initializeLock) return;

    setState(() {
      initializeLock = true;
    });

    String? apiUrl;
    String? accessToken;
    String? refreshToken;

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    // Set the API initialization
    while (apiUrl == null) {
      // Firstly get the API
      apiUrl = sharedPreferences.getString("apiUrl");

      // If it isn't defined, show an popup and get it from the user
      if (apiUrl == null) {
        await _getNewUrl();
        continue;
      }

      // Try to initialize the API Manager
      await ApiManager.initialize(baseUrl: apiUrl);

      // It it failed, this could be a issue with API URL.
      // Unset the value and try to get it again
      if (!ApiManager.isReady) {
        sharedPreferences.remove("apiUrl");
        apiUrl = null;

        continue;
      }
    }

    accessToken = sharedPreferences.getString("accessToken");
    refreshToken = sharedPreferences.getString("refreshToken");

    // If user has logged in before, go to the home screen
    if (accessToken != null && refreshToken != null) {
      ApiManager.setTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      if (context.mounted) {
        navigateToScreen(context, const HomeScreen());
      }

      return;
    }

    // If not, navigate to the login screen (aka. Welcome Screen)
    if (context.mounted) {
      navigateToScreen(context, const WelcomeScreen());
    }
  }

  void navigateToScreen(BuildContext context, Widget screen) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => screen,
      ),
    );
  }

  Future<void> _getNewUrl() async {
    String apiUrl = "";

    return await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("API Adresini Ayarla"),
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                const Text(apiUrlWarning),
                const SizedBox(height: 32),
                TextField(
                  decoration: const InputDecoration(
                    label: Text("API URL'si"),
                  ),
                  controller:
                      TextEditingController(text: "http://192.168.1.1:5000"),
                  keyboardType: TextInputType.url,
                  onChanged: (text) => apiUrl = text,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Tamam"),
              onPressed: () {
                _setApiUrl(apiUrl);
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  Future<void> _setApiUrl(String url) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    await preferences.setString("apiUrl", url);
  }
}
