import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final phoneController = TextEditingController();
  final otpController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  static const navy = Color(0xFF123B5D);
  static const blue = Color(0xFF0057C8);

  // Same background settings as Login and Sign Up
  static const double backgroundZoom = 1.25;

  @override
  void dispose() {
    phoneController.dispose();
    otpController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // =====================================
  // SHOW MESSAGE
  // =====================================

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
    );
  }

  // =====================================
  // SEND OTP
  // =====================================

  void sendOtp() {
    FocusScope.of(context).unfocus();

    final phone = phoneController.text.trim();

    if (!RegExp(r'^[0-9]{9,15}$').hasMatch(phone)) {
      showMessage('الرجاء إدخال رقم هاتف صحيح');
      return;
    }

    // Member 2 will implement real OTP sending.
    showMessage('إرسال رمز OTP غير مربوط بخدمة المصادقة بعد');
  }

  // =====================================
  // RESET PASSWORD
  // =====================================

  void resetPassword() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Member 2 must verify OTP securely before
    // updating the user's password.
    showMessage('المدخلات صحيحة، لكن تغيير كلمة المرور بانتظار ربط OTP');
  }

  // =====================================
  // TEXT FIELD DESIGN
  // =====================================

  InputDecoration fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFB8BDC6)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: blue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
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
              // BACKGROUND OVERLAY
              // =====================================
              Positioned.fill(child: Container(color: const Color(0x26091F38))),

              // =====================================
              // FORGOT PASSWORD CONTENT
              // =====================================
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.only(bottom: 20),
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
                            // WHITE FORGOT PASSWORD CARD
                            // =====================================
                            Container(
                              width: double.infinity,
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

                              child: Form(
                                key: _formKey,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    // =====================================
                                    // PAGE TITLE
                                    // =====================================

                                    const Text(
                                      'نسيت كلمة المرور؟',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 27,
                                        fontWeight: FontWeight.bold,
                                        color: navy,
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    const Text(
                                      'أدخل رقم هاتفك المسجل لاستعادة كلمة المرور',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.5,
                                        color: Colors.grey,
                                      ),
                                    ),

                                    const SizedBox(height: 25),

                                    // =====================================
                                    // PHONE NUMBER
                                    // =====================================
                                    TextFormField(
                                      controller: phoneController,
                                      keyboardType: TextInputType.phone,
                                      textInputAction: TextInputAction.next,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(15),
                                      ],
                                      decoration: fieldDecoration(
                                        hint: 'رقم الهاتف',
                                        icon: Icons.phone_outlined,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'الرجاء إدخال رقم الهاتف';
                                        }

                                        if (!RegExp(r'^[0-9]{9,15}$')
                                            .hasMatch(value)) {
                                          return 'الرجاء إدخال رقم هاتف صحيح';
                                        }

                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 16),

                                    // =====================================
                                    // SEND OTP BUTTON
                                    // =====================================
                                    SizedBox(
                                      height: 50,
                                      child: OutlinedButton.icon(
                                        onPressed: sendOtp,
                                        icon: const Icon(Icons.sms_outlined),
                                        label: const Text(
                                          'إرسال رمز التحقق',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: blue,
                                          side: const BorderSide(
                                            color: blue,
                                            width: 1.5,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 20),

                                    // =====================================
                                    // OTP CODE
                                    // =====================================
                                    TextFormField(
                                      controller: otpController,
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.next,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(6),
                                      ],
                                      decoration: fieldDecoration(
                                        hint: 'رمز التحقق OTP (6 أرقام)',
                                        icon: Icons.verified_user_outlined,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'الرجاء إدخال رمز التحقق';
                                        }

                                        if (!RegExp(r'^[0-9]{6}$')
                                            .hasMatch(value)) {
                                          return 'رمز التحقق يجب أن يتكون من 6 أرقام';
                                        }

                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 20),

                                    // =====================================
                                    // NEW PASSWORD
                                    // =====================================
                                    TextFormField(
                                      controller: passwordController,
                                      obscureText: !isPasswordVisible,
                                      textInputAction: TextInputAction.next,
                                      autocorrect: false,
                                      enableSuggestions: false,
                                      decoration: fieldDecoration(
                                        hint: 'كلمة المرور الجديدة',
                                        icon: Icons.lock_outline,
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
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'الرجاء إدخال كلمة المرور الجديدة';
                                        }

                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 18),

                                    // =====================================
                                    // CONFIRM NEW PASSWORD
                                    // =====================================
                                    TextFormField(
                                      controller: confirmPasswordController,
                                      obscureText: !isConfirmPasswordVisible,
                                      textInputAction: TextInputAction.done,
                                      autocorrect: false,
                                      enableSuggestions: false,
                                      decoration: fieldDecoration(
                                        hint: 'تأكيد كلمة المرور الجديدة',
                                        icon: Icons.lock_reset_outlined,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            isConfirmPasswordVisible
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              isConfirmPasswordVisible =
                                                  !isConfirmPasswordVisible;
                                            });
                                          },
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

                                    const SizedBox(height: 22),

                                    // =====================================
                                    // OTP INFORMATION
                                    // =====================================
                                    Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE5F4E5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: Color(0xFF245B33),
                                          ),

                                          SizedBox(width: 10),

                                          Expanded(
                                            child: Text(
                                              'يجب التحقق من رمز OTP قبل تغيير كلمة المرور',
                                              style: TextStyle(
                                                fontSize: 13,
                                                height: 1.5,
                                                color: Color(0xFF245B33),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    // =====================================
                                    // RESET PASSWORD BUTTON
                                    // =====================================
                                    SizedBox(
                                      height: 55,
                                      child: ElevatedButton(
                                        onPressed: resetPassword,
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
                                          'تغيير كلمة المرور',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 16),

                                    // =====================================
                                    // BACK TO LOGIN
                                    // =====================================
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text(
                                        'العودة إلى تسجيل الدخول',
                                        style: TextStyle(
                                          fontSize: 15,
                                          color: blue,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
