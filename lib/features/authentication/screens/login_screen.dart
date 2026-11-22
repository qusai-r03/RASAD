
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../../core/services/auth_service.dart';
import '../../../app/router.dart';
import '../../../models/user_role.dart';
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

  bool isPasswordVisible = false;
  bool isLoading = false;

  static const navy = Color(0xFF123B5D);
  static const blue = Color(0xFF0057C8);
  static const double backgroundZoom = 1.25;

  @override
  void dispose() {
    idController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> validateLogin() async {
    if (isLoading) return;

    FocusScope.of(context).unfocus();

    final id = idController.text.trim();
    final password = passwordController.text;

    if (id.isEmpty) {
      showMessage('الرجاء إدخال الرقم الوطني');
      return;
    }

    if (!RegExp(r'^[0-9]{10}$').hasMatch(id)) {
      showMessage('الرقم الوطني يجب أن يتكون من 10 أرقام بالضبط');
      return;
    }

    if (password.isEmpty) {
      showMessage('الرجاء إدخال كلمة المرور');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      debugPrint('========== RASD LOGIN START ==========');
      debugPrint('National ID: $id');
      debugPrint('Attempting Firebase authentication...');

      final result = await AuthService().login(
        nationalId: id,
        password: password,
      );

      debugPrint('Firebase login successful.');
      debugPrint('User UID: ${result.uid}');
      debugPrint('User role: ${result.role}');

      if (!mounted) return;

      final UserRole userRole;

      if (result.role == 'employee') {
        userRole = UserRole.employee;
      } else if (result.role == 'citizen') {
        userRole = UserRole.citizen;
      } else {
        throw StateError('Invalid user role: ${result.role}');
      }

      roleService.setAuthenticatedUser(
        uid: result.uid,
        role: userRole,
      );

      debugPrint('Navigating to dashboard...');
      debugPrint('========== RASD LOGIN SUCCESS ==========');

      context.go('/dashboard');
    } on FirebaseAuthException catch (error, stackTrace) {
      debugPrint('========== FIREBASE LOGIN ERROR ==========');
      debugPrint('ERROR CODE: ${error.code}');
      debugPrint('ERROR MESSAGE: ${error.message}');
      debugPrint('ERROR PLUGIN: ${error.plugin}');
      debugPrintStack(stackTrace: stackTrace);
      debugPrint('==========================================');

      if (!mounted) return;

      if (error.code == 'invalid-credential' ||
          error.code == 'wrong-password' ||
          error.code == 'user-not-found' ||
          error.code == 'invalid-email') {
        showMessage('الرقم الوطني أو كلمة المرور غير صحيحة');
      } else if (error.code == 'network-request-failed') {
        showMessage('تعذر الاتصال بالإنترنت. تحقق من اتصالك');
      } else if (error.code == 'user-disabled') {
        showMessage('هذا الحساب معطل');
      } else if (error.code == 'too-many-requests') {
        showMessage('محاولات كثيرة. يرجى المحاولة لاحقاً');
      } else {
        showMessage('تعذر تسجيل الدخول. يرجى المحاولة مرة أخرى');
      }
    } catch (error, stackTrace) {
      debugPrint('========== RASD LOGIN ERROR ==========');
      debugPrint('ERROR TYPE: ${error.runtimeType}');
      debugPrint('ERROR DETAILS: $error');
      debugPrintStack(stackTrace: stackTrace);
      debugPrint('======================================');

      if (!mounted) return;

      showMessage('تعذر تسجيل الدخول. تحقق من حالة الحساب');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
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
              Positioned.fill(
                child: Container(
                  color: const Color(0x26091F38),
                ),
              ),

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
                                  Shadow(
                                    color: Colors.black54,
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 25),

                            // White login card
                            Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              constraints: const BoxConstraints(
                                maxWidth: 450,
                              ),
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

                                  // National ID field
                                  const Text(
                                    'رقم الحساب (ID)',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: navy,
                                    ),
                                  ),

                                  const SizedBox(height: 8),

                                  TextField(
                                    controller: idController,
                                    enabled: !isLoading,
                                    keyboardType: TextInputType.number,
                                    textDirection: TextDirection.ltr,
                                    textAlign: TextAlign.right,
                                    textInputAction: TextInputAction.next,
                                    autocorrect: false,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(10),
                                    ],
                                    decoration: InputDecoration(
                                      hintText: '10-digit ID',
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
                                    enabled: !isLoading,
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
                                      onPressed: isLoading
                                          ? null
                                          : () {
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
                                      onPressed:
                                          isLoading ? null : validateLogin,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: blue,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(14),
                                        ),
                                      ),
                                      child: isLoading
                                          ? const SizedBox(
                                              width: 25,
                                              height: 25,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 3,
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
                                      onPressed: isLoading
                                          ? null
                                          : () {
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
                                          borderRadius:
                                              BorderRadius.circular(14),
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
