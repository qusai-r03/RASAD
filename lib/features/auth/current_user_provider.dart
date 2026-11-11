import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/models.dart';

/// ⚠️ عقد الربط مع عضو الـ Auth:
/// عند جاهزية الـ Auth الحقيقي، استبدل هذا الـ Provider بنسخة تقرأ المستخدم
/// من خدمة الـ Auth (null = غير مسجل دخول). باقي الشاشات تعتمد عليه فقط.
final currentUserProvider = StateProvider<AppUser?>((_) => null);
