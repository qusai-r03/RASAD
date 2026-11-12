/// ⚠️ نماذج مؤقتة لـ Member 4. عضو البيانات (Member 3) يستبدلها بالنموذج النهائي.
enum UserRole { citizen, employee }

class AppUser {
  final String id;
  final String name;
  final String region;
  final UserRole role;
  const AppUser({required this.id, required this.name, required this.region, required this.role});

  String get firstName => name.trim().split(' ').first;
}

enum ComplaintStatus { newC, inProgress, done }

enum Priority { low, medium, high }

class Complaint {
  /// بدون علامة # (تُضاف عند العرض) حتى تصلح كجزء من الرابط.
  final String id;
  final String title;
  final ComplaintStatus status;
  final DateTime date;
  final Priority priority;
  final String location;
  final String description;

  /// نتيجة تحليل الذكاء الاصطناعي
  final String aiLabel;
  final double aiConfidence; // 0..1

  /// مسار صورة داخل assets (اختياري). إن لم يوجد الملف تظهر صورة بديلة.
  final String? imageAsset;

  /// صورة التقطها/اختارها المواطن من الجهاز (مسار محلي مؤقت لحين رفعها إلى Storage).
  final String? localImagePath;

  /// صورة بعد الإصلاح يضيفها الموظف.
  final String? fixImagePath;
  final String? note;

  const Complaint({
    required this.id,
    required this.title,
    required this.status,
    required this.date,
    this.priority = Priority.medium,
    this.location = '',
    this.description = '',
    this.aiLabel = '',
    this.aiConfidence = 0,
    this.imageAsset,
    this.localImagePath,
    this.fixImagePath,
    this.note,
  });

  Complaint copyWith({ComplaintStatus? status, String? note, String? fixImagePath}) => Complaint(
        id: id,
        title: title,
        status: status ?? this.status,
        date: date,
        priority: priority,
        location: location,
        description: description,
        aiLabel: aiLabel,
        aiConfidence: aiConfidence,
        imageAsset: imageAsset,
        localImagePath: localImagePath,
        fixImagePath: fixImagePath ?? this.fixImagePath,
        note: note ?? this.note,
      );
}
