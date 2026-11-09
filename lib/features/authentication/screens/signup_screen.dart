import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'otp_verification_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final dobController = TextEditingController();
  final phoneController = TextEditingController();
  final idController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  DateTime? selectedDate;

  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  static const navy = Color(0xFF123B5D);
  static const blue = Color(0xFF0057C8);
  static const double backgroundZoom = 1.25;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    dobController.dispose();
    phoneController.dispose();
    idController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> selectDateOfBirth() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'اختر تاريخ الميلاد',
      cancelText: 'إلغاء',
      confirmText: 'تأكيد',
    );

    if (date != null && mounted) {
      setState(() {
        selectedDate = date;

        dobController.text =
            '${date.year}-'
            '${date.month.toString().padLeft(2, '0')}-'
            '${date.day.toString().padLeft(2, '0')}';
      });
    }
  }

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

    if (!RegExp(r'[^a-zA-Z0-9\s]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على رمز خاص واحد على الأقل';
    }

    return null;
  }

  void validateSignup() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Demo only: no Firebase account is created.
    // Member 2 must check ID uniqueness and link the ID to Firebase.

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationScreen(
          phoneNumber: phoneController.text.trim(),
          demoMode: true,
        ),
      ),
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

  Widget buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: navy,
            ),
          ),

          const SizedBox(height: 7),

          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            readOnly: readOnly,
            onTap: onTap,
            inputFormatters: inputFormatters,
            autocorrect: false,
            enableSuggestions: !obscureText,
            decoration: fieldDecoration(
              hint: hint,
              icon: icon,
              suffixIcon: suffixIcon,
            ),
            validator: validator,
          ),
        ],
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
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(
                    left: 14,
                    right: 14,
                    top: 22,
                    bottom: 30,
                  ),
                  child: Column(
                    children: [
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
                        ),
                      ),

                      const SizedBox(height: 25),

                      // White signup card
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

                              // 1. First Name
                              buildField(
                                label: 'الاسم الأول',
                                controller: firstNameController,
                                icon: Icons.person_outline,
                                hint: 'First Name',
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'الرجاء إدخال الاسم الأول';
                                  }
                                  return null;
                                },
                              ),

                              // 2. Last Name
                              buildField(
                                label: 'اسم العائلة',
                                controller: lastNameController,
                                icon: Icons.person_outline,
                                hint: 'Last Name',
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'الرجاء إدخال اسم العائلة';
                                  }
                                  return null;
                                },
                              ),

                              // 3. Date of Birth
                              buildField(
                                label: 'تاريخ الميلاد',
                                controller: dobController,
                                icon: Icons.calendar_month_outlined,
                                hint: 'YYYY-MM-DD',
                                readOnly: true,
                                onTap: selectDateOfBirth,
                                validator: (_) {
                                  if (selectedDate == null) {
                                    return 'الرجاء اختيار تاريخ الميلاد';
                                  }
                                  return null;
                                },
                              ),

                              // 4. Phone Number
                              buildField(
                                label: 'رقم الهاتف',
                                controller: phoneController,
                                icon: Icons.phone_outlined,
                                hint: '07XXXXXXXX',
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'الرجاء إدخال رقم الهاتف';
                                  }

                                  if (!RegExp(r'^07[0-9]{8}$')
                                      .hasMatch(value.trim())) {
                                    return 'أدخل رقم هاتف أردني صحيحًا من 10 أرقام';
                                  }

                                  return null;
                                },
                              ),

                              // 5. ID
                              buildField(
                                label: 'رقم الحساب (ID)',
                                controller: idController,
                                icon: Icons.badge_outlined,
                                hint: '10-digit ID',
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                validator: (value) {
                                  final id = value?.trim() ?? '';

                                  if (id.isEmpty) {
                                    return 'الرجاء إدخال رقم الحساب (ID)';
                                  }

                                  if (!RegExp(r'^[0-9]{10}$').hasMatch(id)) {
                                    return 'رقم الحساب (ID) يجب أن يتكون من 10 أرقام بالضبط';
                                  }

                                  return null;
                                },
                              ),

                              // 6. Password
                              buildField(
                                label: 'كلمة المرور',
                                controller: passwordController,
                                icon: Icons.lock_outline,
                                hint: 'Password',
                                obscureText: !isPasswordVisible,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isPasswordVisible
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isPasswordVisible = !isPasswordVisible;
                                    });
                                  },
                                ),
                                validator: validatePassword,
                              ),

                              // 7. Confirm Password
                              buildField(
                                label: 'تأكيد كلمة المرور',
                                controller: confirmPasswordController,
                                icon: Icons.lock_reset_outlined,
                                hint: 'Confirm Password',
                                obscureText: !isConfirmPasswordVisible,
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

                              const SizedBox(height: 10),

                              // OTP information
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
                                        'التحقق من الهاتف تجريبي حاليًا. سيتم إرسال رمز OTP بعد ربط Firebase.',
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

                              // Create Account button
                              SizedBox(
                                height: 55,
                                child: ElevatedButton(
                                  onPressed: validateSignup,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: blue,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
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

                              // Back to Login
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'لديك حساب بالفعل؟ تسجيل الدخول',
                                  style: TextStyle(fontSize: 15, color: blue),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
