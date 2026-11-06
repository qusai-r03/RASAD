import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final idController = TextEditingController();
  final passwordController = TextEditingController();

  bool isCitizen = true;
  bool isPasswordVisible = false;

  static const navy = Color(0xFF123B5D);
  static const blue = Color(0xFF0057C8);

  // Controls how much of the buildings appear higher
  static const double backgroundZoom = 1.25;

  @override
  void dispose() {
    idController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  void validateLogin() {
    FocusScope.of(context).unfocus();

    final id = idController.text.trim();
    final password = passwordController.text;

    if (id.isEmpty) {
      showMessage(
        isCitizen ? 'الرجاء إدخال الرقم الوطني' : 'الرجاء إدخال الرقم الوظيفي',
      );
      return;
    }

    if (isCitizen && !RegExp(r'^[0-9]{10}$').hasMatch(id)) {
      showMessage('الرقم الوطني يجب أن يتكون من 10 أرقام بالضبط');
      return;
    }

    if (password.isEmpty) {
      showMessage('الرجاء إدخال كلمة المرور');
      return;
    }

    // Member 2 will connect Firebase Authentication
    showMessage('تم التحقق من المدخلات، بانتظار ربط Firebase');
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: navy,
          systemNavigationBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: navy,

          body: Stack(
            fit: StackFit.expand,
            children: [
              // =====================================
              // FULL SCREEN AMMAN BACKGROUND
              // =====================================

              Positioned.fill(
                child: Transform.scale(
                  scale: backgroundZoom,
                  alignment: Alignment.bottomCenter,

                  child: Image.asset(
                    'assets/images/amman_background.png',
                    fit: BoxFit.cover,
                    alignment: Alignment.bottomCenter,
                  ),
                ),
              ),

              // =====================================
              // BLUE OVERLAY
              // =====================================
              Positioned.fill(child: Container(color: const Color(0x26091F38))),

              // =====================================
              // LOGIN CONTENT
              // =====================================
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,

                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),

                        child: Column(
                          children: [
                            const SizedBox(height: 22),

                            // =====================================
                            // TRANSPARENT RASD LOGO
                            // =====================================
                            SizedBox(
                              width: 245,
                              height: 175,

                              child: Image.asset(
                                'assets/images/rasd_logo_blue.png',
                                fit: BoxFit.contain,
                              ),
                            ),

                            const SizedBox(height: 5),

                            // =====================================
                            // APP SUBTITLE
                            // =====================================
                            const Text(
                              'منصة رصد البلدية',
                              textAlign: TextAlign.center,

                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                shadows: [
                                  Shadow(color: Colors.black54, blurRadius: 6),
                                ],
                              ),
                            ),

                            const SizedBox(height: 25),

                            // =====================================
                            // WHITE LOGIN CARD
                            // =====================================
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),

                              constraints: const BoxConstraints(maxWidth: 450),

                              padding: const EdgeInsets.all(24),

                              decoration: BoxDecoration(
                                color: Colors.white,

                                borderRadius: BorderRadius.circular(30),

                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 20,
                                    offset: Offset(0, 8),
                                  ),
                                ],
                              ),

                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,

                                children: [
                                  // =====================================
                                  // LOGIN TITLE
                                  // =====================================

                                  const Text(
                                    'تسجيل الدخول',
                                    textAlign: TextAlign.center,

                                    style: TextStyle(
                                      fontSize: 27,
                                      fontWeight: FontWeight.bold,
                                      color: navy,
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  const Text(
                                    'ادخل إلى حسابك لمتابعة البلاغات والمشكلات في مدينتك',
                                    textAlign: TextAlign.center,

                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      height: 1.5,
                                    ),
                                  ),

                                  const SizedBox(height: 22),

                                  // =====================================
                                  // ACCOUNT TYPE
                                  // =====================================
                                  const Text(
                                    'نوع الحساب',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: navy,
                                    ),
                                  ),

                                  RadioGroup<bool>(
                                    groupValue: isCitizen,

                                    onChanged: (bool? value) {
                                      if (value == null) return;

                                      setState(() {
                                        isCitizen = value;
                                        idController.clear();
                                      });
                                    },

                                    child: const Row(
                                      children: [
                                        Expanded(
                                          child: RadioListTile<bool>(
                                            title: Text('مواطن'),
                                            value: true,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),

                                        Expanded(
                                          child: RadioListTile<bool>(
                                            title: Text('موظف'),
                                            value: false,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 14),

                                  // =====================================
                                  // NATIONAL ID / EMPLOYEE ID
                                  // =====================================
                                  TextField(
                                    controller: idController,

                                    keyboardType: isCitizen
                                        ? TextInputType.number
                                        : TextInputType.text,

                                    inputFormatters: isCitizen
                                        ? [
                                            FilteringTextInputFormatter
                                                .digitsOnly,

                                            LengthLimitingTextInputFormatter(
                                              10,
                                            ),
                                          ]
                                        : [],

                                    decoration: InputDecoration(
                                      hintText: isCitizen
                                          ? 'الرقم الوطني (10 أرقام)'
                                          : 'الرقم الوظيفي',

                                      prefixIcon: const Icon(
                                        Icons.badge_outlined,
                                      ),

                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),

                                        borderSide: const BorderSide(
                                          color: blue,
                                          width: 2,
                                        ),
                                      ),

                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  // =====================================
                                  // PASSWORD FIELD
                                  // =====================================
                                  TextField(
                                    controller: passwordController,

                                    obscureText: !isPasswordVisible,
                                    autocorrect: false,
                                    enableSuggestions: false,

                                    decoration: InputDecoration(
                                      hintText: 'كلمة المرور',

                                      prefixIcon: const Icon(
                                        Icons.lock_outline,
                                      ),

                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),

                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          isPasswordVisible
                                              ? Icons.visibility_off
                                              : Icons.visibility,
                                        ),

                                        onPressed: () {
                                          setState(() {
                                            isPasswordVisible =
                                                !isPasswordVisible;
                                          });
                                        },
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  // =====================================
                                  // FORGOT PASSWORD
                                  // =====================================
                                  Align(
                                    alignment: Alignment.centerLeft,

                                    child: TextButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ForgotPasswordScreen(),
                                          ),
                                        );
                                      },

                                      child: const Text(
                                        'نسيت كلمة المرور؟',
                                        style: TextStyle(color: blue),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 18),

                                  // =====================================
                                  // LOGIN BUTTON
                                  // =====================================
                                  SizedBox(
                                    height: 55,

                                    child: ElevatedButton(
                                      onPressed: validateLogin,

                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: blue,
                                        foregroundColor: Colors.white,

                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),

                                      child: const Text(
                                        'تسجيل الدخول',

                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // =====================================
                                  // SIGN UP BUTTON
                                  // =====================================
                                  SizedBox(
                                    height: 55,

                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const SignupScreen(),
                                          ),
                                        );
                                      },

                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: blue,

                                        side: const BorderSide(
                                          color: blue,
                                          width: 2,
                                        ),

                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),

                                      child: const Text(
                                        'إنشاء حساب',

                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
