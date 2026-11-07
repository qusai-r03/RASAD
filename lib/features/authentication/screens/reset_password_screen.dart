import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;

  static const navy = Color(0xFF123B5D);
  static const blue = Color(0xFF0057C8);

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Password requirements:
  // 1. At least 8 characters
  // 2. At least one number
  // 3. At least one special character
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }

    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    }

    if (!RegExp(r'[!@#$%^&*()_+\-=\[\]{};:"\\|,.<>/?~`]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على رمز خاص واحد على الأقل';
    }

    return null;
  }

  void submitReset() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // UI demonstration only.
    // No password is changed in Firebase.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'البيانات صحيحة، لكن تغيير كلمة المرور '
          'الحقيقي بانتظار ربط Firebase.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: navy,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Amman background
            Positioned.fill(
              child: Transform.scale(
                scale: 1.25,
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 22,
                ),
                child: Column(
                  children: [
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
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 25),

                    Container(
                      width: double.infinity,
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

                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Icon(
                              Icons.password_outlined,
                              size: 55,
                              color: blue,
                            ),

                            const SizedBox(height: 15),

                            const Text(
                              'تعيين كلمة مرور جديدة',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: navy,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 12),

                            const Text(
                              'أدخل كلمة المرور الجديدة ثم أكدها',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 15),

                            // Password requirements info
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF3FF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'يجب أن تحتوي كلمة المرور على:\n'
                                '• 8 أحرف على الأقل\n'
                                '• رقم واحد على الأقل\n'
                                '• رمز خاص واحد على الأقل مثل @ أو # أو !',
                                style: TextStyle(
                                  color: navy,
                                  fontSize: 13,
                                  height: 1.7,
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            // New password
                            const Text(
                              'كلمة المرور الجديدة',
                              style: TextStyle(
                                color: navy,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            TextFormField(
                              controller: passwordController,
                              obscureText: !showPassword,
                              autocorrect: false,
                              enableSuggestions: false,
                              decoration: InputDecoration(
                                hintText: 'Password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      showPassword = !showPassword;
                                    });
                                  },
                                  icon: Icon(
                                    showPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),

                              // New password validation
                              validator: validatePassword,
                            ),

                            const SizedBox(height: 18),

                            // Confirm password
                            const Text(
                              'تأكيد كلمة المرور',
                              style: TextStyle(
                                color: navy,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            TextFormField(
                              controller: confirmPasswordController,
                              obscureText: !showConfirmPassword,
                              autocorrect: false,
                              enableSuggestions: false,
                              decoration: InputDecoration(
                                hintText: 'Confirm Password',
                                prefixIcon: const Icon(
                                  Icons.lock_reset_outlined,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      showConfirmPassword =
                                          !showConfirmPassword;
                                    });
                                  },
                                  icon: Icon(
                                    showConfirmPassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),

                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء تأكيد كلمة المرور';
                                }

                                if (value != passwordController.text) {
                                  return 'كلمتا المرور غير متطابقتين';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 15),

                            const Text(
                              'وضع تجريبي: لن يتم تغيير كلمة مرور أي حساب.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.deepOrange,
                                fontSize: 12,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Submit button
                            SizedBox(
                              height: 55,
                              child: ElevatedButton(
                                onPressed: submitReset,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
                                  'تأكيد كلمة المرور الجديدة',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Back to login
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .popUntil((route) => route.isFirst);
                              },
                              child: const Text(
                                'العودة إلى تسجيل الدخول',
                                style: TextStyle(color: blue),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
