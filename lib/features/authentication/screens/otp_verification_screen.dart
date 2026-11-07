import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;

  // Used only for testing the UI.
  final bool demoMode;

  // Set to true after the backend confirms OTP sending.
  final bool codeWasSent;

  // Firebase callbacks will be provided by Member 2.
  final Future<void> Function(String code)? onVerify;
  final Future<bool> Function()? onResend;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.demoMode = false,
    this.codeWasSent = false,
    this.onVerify,
    this.onResend,
  });

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _otpController = TextEditingController();

  Timer? _timer;
  DateTime? _timerEnd;

  int _remainingSeconds = 0;

  bool _isVerifying = false;
  bool _isResending = false;

  static const Color navy = Color(0xFF123B5D);
  static const Color blue = Color(0xFF0057C8);

  // =========================================
  // INITIALIZE TIMER
  // =========================================

  @override
  void initState() {
    super.initState();

    if (widget.demoMode || widget.codeWasSent) {
      _startTimer();
    }
  }

  // =========================================
  // START 60 SECONDS TIMER
  // =========================================

  void _startTimer() {
    _timer?.cancel();

    _timerEnd = DateTime.now().add(
      const Duration(seconds: 60),
    );

    _remainingSeconds = 60;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        final milliseconds =
            _timerEnd!.difference(DateTime.now()).inMilliseconds;

        final seconds = milliseconds <= 0
            ? 0
            : (milliseconds + 999) ~/ 1000;

        if (!mounted) {
          timer.cancel();
          return;
        }

        setState(() {
          _remainingSeconds = seconds;
        });

        if (seconds == 0) {
          timer.cancel();
        }
      },
    );
  }

  // =========================================
  // FORMAT TIMER
  // =========================================

  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  // =========================================
  // MASK PHONE NUMBER
  // =========================================

  String get maskedPhone {
    final phone = widget.phoneNumber;

    if (phone.length <= 4) {
      return phone;
    }

    return '${'*' * (phone.length - 4)}${phone.substring(phone.length - 4)}';
  }

  // =========================================
  // SHOW MESSAGE
  // =========================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // =========================================
  // VERIFY OTP
  // =========================================

  Future<void> _verifyOtp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (widget.demoMode || widget.onVerify == null) {
      _showMessage(
        'هذه شاشة تجريبية. التحقق الحقيقي بانتظار ربط Firebase.',
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      await widget.onVerify!(
        _otpController.text.trim(),
      );

      // Member 2's service will determine whether
      // verification succeeded.
    } catch (_) {
      _showMessage(
        'تعذر التحقق من الرمز. يرجى المحاولة مرة أخرى.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  // =========================================
  // RESEND OTP
  // =========================================

  Future<void> _resendOtp() async {
    if (_remainingSeconds > 0 || _isResending) {
      return;
    }

    // Demo mode tests the timer without sending SMS.
    if (widget.demoMode) {
      _showMessage(
        'وضع تجريبي: لم يتم إرسال SMS. تمت إعادة تشغيل المؤقت.',
      );

      setState(() {
        _otpController.clear();
        _startTimer();
      });

      return;
    }

    if (widget.onResend == null) {
      _showMessage(
        'خدمة إعادة الإرسال غير مربوطة بعد.',
      );
      return;
    }

    setState(() {
      _isResending = true;
    });

    try {
      final wasSent = await widget.onResend!();

      if (!mounted) return;

      if (wasSent) {
        setState(() {
          _otpController.clear();
          _startTimer();
        });
      } else {
        _showMessage(
          'تعذر إرسال رمز جديد.',
        );
      }
    } catch (_) {
      _showMessage(
        'حدث خطأ أثناء طلب رمز جديد.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isResending = false;
        });
      }
    }
  }

  // =========================================
  // DISPOSE
  // =========================================

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();

    super.dispose();
  }

  // =========================================
  // BUILD UI
  // =========================================

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: navy,
        resizeToAvoidBottomInset: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // =====================================
            // AMMAN BACKGROUND
            // =====================================

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

            Positioned.fill(
              child: Container(
                color: const Color(0x26091F38),
              ),
            ),

            // =====================================
            // MAIN CONTENT
            // =====================================

            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  bottom: 25,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 25),

                    // =====================================
                    // LOGO
                    // =====================================

                    SizedBox(
                      width: 245,
                      height: 175,
                      child: Image.asset(
                        'assets/images/rasd_logo_blue.png',
                        fit: BoxFit.contain,
                      ),
                    ),

                    const SizedBox(height: 8),

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

                    // =====================================
                    // WHITE CARD
                    // =====================================

                    Container(
                      width: double.infinity,
                      constraints: const BoxConstraints(
                        maxWidth: 450,
                      ),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 14,
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

                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                          children: [
                            // =====================================
                            // ICON
                            // =====================================

                            const Icon(
                              Icons.verified_user_outlined,
                              color: blue,
                              size: 55,
                            ),

                            const SizedBox(height: 15),

                            // =====================================
                            // TITLE
                            // =====================================

                            const Text(
                              'التحقق من رقم الهاتف',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: navy,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 12),

                            Text(
                              'أدخل رمز التحقق المكوّن من 6 أرقام\n'
                              'لرقم الهاتف $maskedPhone',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                height: 1.6,
                              ),
                            ),

                            if (widget.demoMode) ...[
                              const SizedBox(height: 12),
                              const Text(
                                'وضع تجريبي: لم يتم إرسال رسالة SMS.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.deepOrange,
                                  fontSize: 12,
                                ),
                              ),
                            ],

                            const SizedBox(height: 25),

                            // =====================================
                            // OTP FIELD
                            // =====================================

                            TextFormField(
                              controller: _otpController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              maxLength: 6,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              style: const TextStyle(
                                fontSize: 24,
                                letterSpacing: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                hintText: '------',
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(
                                    color: blue,
                                    width: 2,
                                  ),
                                ),
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.length != 6) {
                                  return 'الرجاء إدخال رمز مكوّن من 6 أرقام';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 25),

                            // =====================================
                            // TIMER TEXT
                            // =====================================

                            const Text(
                              'يمكنك طلب رمز جديد بعد',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: navy,
                                fontSize: 15,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // =====================================
                            // TIMER DISPLAY
                            // =====================================

                            Text(
                              formattedTime,
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.ltr,
                              style: TextStyle(
                                color: _remainingSeconds > 0
                                    ? blue
                                    : Colors.green,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 18),

                            // =====================================
                            // RESEND OTP BUTTON
                            // =====================================

                            TextButton(
                              onPressed: _remainingSeconds == 0 &&
                                      !_isResending
                                  ? _resendOtp
                                  : null,
                              child: Text(
                                _isResending
                                    ? 'جارٍ طلب الرمز...'
                                    : 'إعادة إرسال الرمز',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(height: 25),

                            // =====================================
                            // VERIFY BUTTON
                            // =====================================

                            SizedBox(
                              height: 55,
                              child: ElevatedButton(
                                onPressed:
                                    _isVerifying ? null : _verifyOtp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: blue,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14),
                                  ),
                                ),
                                child: Text(
                                  _isVerifying
                                      ? 'جارٍ التحقق...'
                                      : 'التحقق من الرمز',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // =====================================
                            // BACK BUTTON
                            // =====================================

                            TextButton(
                              onPressed: () {
                                Navigator.of(context).maybePop();
                              },
                              child: const Text(
                                'العودة',
                                style: TextStyle(
                                  color: blue,
                                  fontSize: 15,
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
            ),
          ],
        ),
      ),
    );
  }
}