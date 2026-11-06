import 'package:flutter/material.dart';

import 'features/authentication/screens/login_screen.dart';

void main() {
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
