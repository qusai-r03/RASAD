import '../models/models.dart';

const mockEmployee = AppUser(id: 'e1', name: 'أحمد محمد', region: 'إربد', role: UserRole.employee);
const mockCitizen = AppUser(id: 'c1', name: 'أحمد خالد', region: 'إربد', role: UserRole.citizen);

/// شكاوى لوحة الموظف (حسب التصميم).
final mockComplaints = <Complaint>[
  Complaint(
    id: '2025-0048',
    title: 'حفرة في الطريق',
    status: ComplaintStatus.newC,
    date: DateTime(2025, 4, 27, 10, 35),
    priority: Priority.high,
    location: 'إربد - شارع الجامعة',
    description: 'حفرة كبيرة في منتصف الشارع',
    aiLabel: 'حفرة في الطريق',
    aiConfidence: .92,
    imageAsset: 'assets/images/complaint_2025-0048.jpg',
  ),
  Complaint(
    id: '2025-0047',
    title: 'كلاب ضالة',
    status: ComplaintStatus.newC,
    date: DateTime(2025, 4, 27, 9, 10),
    priority: Priority.medium,
    location: 'إربد - حي الصحة',
    description: 'تجمّع كلاب ضالة قرب المدرسة',
    aiLabel: 'كلاب ضالة',
    aiConfidence: .88,
    imageAsset: 'assets/images/complaint_2025-0047.jpg',
  ),
  Complaint(
    id: '2025-0046',
    title: 'تراكم نفايات',
    status: ComplaintStatus.inProgress,
    date: DateTime(2025, 4, 26, 14, 5),
    priority: Priority.medium,
    location: 'إربد - شارع الهاشمي',
    description: 'نفايات متراكمة بجانب الحاويات',
    aiLabel: 'تراكم نفايات',
    aiConfidence: .95,
    imageAsset: 'assets/images/complaint_2025-0046.jpg',
  ),
  Complaint(
    id: '2025-0045',
    title: 'أرصفة مكسورة',
    status: ComplaintStatus.done,
    date: DateTime(2025, 4, 25, 11, 20),
    priority: Priority.low,
    location: 'إربد - وسط البلد',
    description: 'أجزاء مكسورة من الرصيف',
    aiLabel: 'رصيف مكسور',
    aiConfidence: .81,
    imageAsset: 'assets/images/complaint_2025-0045.jpg',
  ),
];

/// إحصاءات لوحة الموظف (حسب التصميم).
const mockStats = {'new': 12, 'progress': 8, 'done': 25};

/// ملخص شكاوى المواطن (حسب التصميم): انتظار / معالجة / إنجاز.
const citizenSummary = (waiting: 2, progress: 1, done: 5);
