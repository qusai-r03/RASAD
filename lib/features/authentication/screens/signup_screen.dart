import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final nationalIdController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  static const navy = Color(0xFF123B5D);
  static const blue = Color(0xFF0057C8);

  // Same background settings as Login Screen
  static const double backgroundZoom = 1.25;

  @override
  void dispose() {
    usernameController.dispose();
    phoneController.dispose();
    nationalIdController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 4)),
    );
  }

  void validateSignup() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Member 2 will connect Firebase Authentication and OTP.
    showMessage(
      'تم التحقق من البيانات بنجاح. إنشاء الحساب وإرسال OTP غير مربوطين بعد.',
    );
  }

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
              // SIGN UP CONTENT
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
                            // WHITE SIGN UP CARD
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
                                    // SIGN UP TITLE
                                    // =====================================

                                    const Text(
                                      'إنشاء حساب',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 27,
                                        fontWeight: FontWeight.bold,
                                        color: navy,
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    const Text(
                                      'أنشئ حسابًا جديدًا للمساهمة في رصد المشكلات البلدية في مدينتك',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 14,
                                        height: 1.5,
                                        color: Colors.grey,
                                      ),
                                    ),

                                    const SizedBox(height: 25),

                                    // =====================================
                                    // USERNAME
                                    // =====================================
                                    TextFormField(
                                      controller: usernameController,
                                      textInputAction: TextInputAction.next,
                                      decoration: fieldDecoration(
                                        hint: 'اسم المستخدم',
                                        icon: Icons.person_outline,
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'الرجاء إدخال اسم المستخدم';
                                        }

                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 18),

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

                                    const SizedBox(height: 18),

                                    // =====================================
                                    // NATIONAL ID
                                    // =====================================
                                    TextFormField(
                                      controller: nationalIdController,
                                      keyboardType: TextInputType.number,
                                      textInputAction: TextInputAction.next,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(10),
                                      ],
                                      decoration: fieldDecoration(
                                        hint: 'الرقم الوطني (10 أرقام)',
                                        icon: Icons.badge_outlined,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'الرجاء إدخال الرقم الوطني';
                                        }

                                        if (!RegExp(r'^[0-9]{10}$')
                                            .hasMatch(value)) {
                                          return 'الرقم الوطني يجب أن يتكون من 10 أرقام بالضبط';
                                        }

                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 18),

                                    // =====================================
                                    // PASSWORD
                                    // =====================================
                                    TextFormField(
                                      controller: passwordController,
                                      obscureText: !isPasswordVisible,
                                      textInputAction: TextInputAction.next,
                                      autocorrect: false,
                                      enableSuggestions: false,
                                      decoration: fieldDecoration(
                                        hint: 'كلمة المرور',
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
                                          return 'الرجاء إدخال كلمة المرور';
                                        }

                                        return null;
                                      },
                                    ),

                                    const SizedBox(height: 18),

                                    // =====================================
                                    // CONFIRM PASSWORD
                                    // =====================================
                                    TextFormField(
                                      controller: confirmPasswordController,
                                      obscureText: !isConfirmPasswordVisible,
                                      textInputAction: TextInputAction.done,
                                      autocorrect: false,
                                      enableSuggestions: false,
                                      decoration: fieldDecoration(
                                        hint: 'تأكيد كلمة المرور',
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
                                            Icons.sms_outlined,
                                            color: Color(0xFF245B33),
                                          ),

                                          SizedBox(width: 10),

                                          Expanded(
                                            child: Text(
                                              'سيتم إرسال رمز تحقق OTP إلى رقم الهاتف بعد ربط خدمة المصادقة',
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
                                    // CREATE ACCOUNT BUTTON
                                    // =====================================
                                    SizedBox(
                                      height: 55,
                                      child: ElevatedButton(
                                        onPressed: validateSignup,
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
                                          'إنشاء حساب',
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
                                        'لديك حساب بالفعل؟ تسجيل الدخول',
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
