import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'features/authentication/screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase before opening the login screen.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const RasdLoginPreview());
}

class RasdLoginPreview extends StatelessWidget {
  const RasdLoginPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'RASD - Login Preview',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}