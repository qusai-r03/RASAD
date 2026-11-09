import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/auth_api_service.dart';

import 'signup_screen.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isLoggingIn = false;

  final AuthApiService authApi = AuthApiService();

  static const navy = Color(0xFF123B5D);
  static const blue = Color(0xFF0057C8);
  static const double backgroundZoom = 1.25;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  Future<void> validateLogin() async {
    if (isLoggingIn) return;

    FocusScope.of(context).unfocus();

    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty) {
      showMessage('الرجاء إدخال اسم المستخدم');
      return;
    }

    if (!RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(username)) {
      showMessage(
        'اسم المستخدم يجب أن يكون من 3 إلى 20 حرفًا أو رقمًا إنجليزيًا',
      );
      return;
    }

    if (password.isEmpty) {
      showMessage('الرجاء إدخال كلمة المرور');
      return;
    }

    setState(() => isLoggingIn = true);

    try {
      await authApi.login(username: username, password: password);

      if (!mounted) return;

      showMessage('تم تسجيل الدخول بنجاح');
    } catch (e) {
      if (!mounted) return;

      showMessage('فشل تسجيل الدخول. تحقق من البيانات أو اتصال الخادم.');
    } finally {
      if (mounted) {
        setState(() => isLoggingIn = false);
      }
    }
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
              // Amman background
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

              // Blue overlay
              Positioned.fill(child: Container(color: const Color(0x26091F38))),

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

                            // RASD logo
                            SizedBox(
                              width: 245,
                              height: 175,
                              child: Image.asset(
                                'assets/images/rasd_logo_blue.png',
                                fit: BoxFit.contain,
                              ),
                            ),

                            const SizedBox(height: 5),

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

                            // White login card
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

                                  const SizedBox(height: 25),

                                  // Username field
                                  const Text(
                                    'اسم المستخدم',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: navy,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  TextField(
                                    controller: usernameController,
                                    keyboardType: TextInputType.text,
                                    textDirection: TextDirection.ltr,
                                    textAlign: TextAlign.right,
                                    textInputAction: TextInputAction.next,
                                    autocorrect: false,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[a-zA-Z0-9_]'),
                                      ),
                                      LengthLimitingTextInputFormatter(20),
                                    ],
                                    decoration: InputDecoration(
                                      hintText: 'Username',
                                      prefixIcon: const Icon(
                                        Icons.person_outline,
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

                                  // Password field
                                  const Text(
                                    'كلمة المرور',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: navy,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  TextField(
                                    controller: passwordController,
                                    obscureText: !isPasswordVisible,
                                    autocorrect: false,
                                    enableSuggestions: false,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) => validateLogin(),
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

                                  // Forgot password
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

                                  // Login button
                                  SizedBox(
                                    height: 55,
                                    child: ElevatedButton(
                                      onPressed: isLoggingIn
                                          ? null
                                          : validateLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: blue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                      child: isLoggingIn
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text(
                                              'تسجيل الدخول',
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),

                                  const SizedBox(height: 16),

                                  // Sign Up button
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
