import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/mock/mock_data.dart';
import '../../core/models/models.dart';

/// ⚠️ بيانات وهمية. عند ربط Firestore يستبدلها عضو الشكاوى بـ Stream حقيقي
/// مع الحفاظ على نفس الواجهة (قائمة Complaint + updateStatus).
class ComplaintsNotifier extends StateNotifier<List<Complaint>> {
  ComplaintsNotifier() : super(mockComplaints);

  void updateStatus(String id, ComplaintStatus status, {String? note, String? fixImagePath}) {
    state = [
      for (final c in state)
        if (c.id == id) c.copyWith(status: status, note: note, fixImagePath: fixImagePath) else c,
    ];
  }

  void add(Complaint c) => state = [c, ...state];

  /// رقم الشكوى التالي بصيغة 2026-0049.
  String nextId() {
    var maxN = 0;
    for (final c in state) {
      final n = int.tryParse(c.id.split('-').last) ?? 0;
      if (n > maxN) maxN = n;
    }
    return '${DateTime.now().year}-${(maxN + 1).toString().padLeft(4, '0')}';
  }
}

final complaintsProvider =
    StateNotifierProvider<ComplaintsNotifier, List<Complaint>>((ref) => ComplaintsNotifier());

final complaintByIdProvider = Provider.family<Complaint?, String>((ref, id) {
  for (final c in ref.watch(complaintsProvider)) {
    if (c.id == id) return c;
  }
  return null;
});
