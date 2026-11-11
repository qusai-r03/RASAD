import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';

/// ⚠️ أماكن محفوظة وهمية (أسماء فقط). تُستبدل بمستندات users/{uid}/savedPlaces
/// فيها lat/lng، وتُستعمل لإشعارات «بالقرب منك» (يحتاج عضو الخريطة اختيار الموقع).
class SavedPlacesNotifier extends StateNotifier<List<String>> {
  SavedPlacesNotifier() : super(const ['جامعة اليرموك', 'المنزل']);

  void add(String name) {
    final n = name.trim();
    if (n.isNotEmpty && !state.contains(n)) state = [...state, n];
  }

  void remove(String name) => state = [for (final p in state) if (p != name) p];
}

final savedPlacesProvider = StateNotifierProvider<SavedPlacesNotifier, List<String>>((ref) => SavedPlacesNotifier());

class SavedPlacesScreen extends ConsumerWidget {
  const SavedPlacesScreen({super.key});

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final name = await showDialog<String>(context: context, builder: (_) => const _AddPlaceDialog());
    if (name != null) ref.read(savedPlacesProvider.notifier).add(name);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final places = ref.watch(savedPlacesProvider);
    return Scaffold(
      appBar: AppBar(centerTitle: true, title: Text(context.tr('savedPlaces'))),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Text(context.tr('savedHint'), style: const TextStyle(color: AppColors.muted, height: 1.4)),
        const SizedBox(height: 12),
        if (places.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Center(child: Text(context.tr('noPlaces'), style: const TextStyle(color: AppColors.muted))),
          ),
        for (final p in places)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: AppDecor.card(radius: 14),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: AppColors.primarySoft,
                child: Icon(Icons.bookmark_rounded, color: AppColors.primary),
              ),
              title: Text(p, style: const TextStyle(fontWeight: FontWeight.w700)),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.newFg),
                onPressed: () => ref.read(savedPlacesProvider.notifier).remove(p),
              ),
            ),
          ),
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton.icon(
            onPressed: () => _add(context, ref),
            icon: const Icon(Icons.add_location_alt_outlined),
            label: Text(context.tr('addPlace')),
          ),
        ),
      ),
    );
  }
}

class _AddPlaceDialog extends StatefulWidget {
  const _AddPlaceDialog();

  @override
  State<_AddPlaceDialog> createState() => _AddPlaceDialogState();
}

class _AddPlaceDialogState extends State<_AddPlaceDialog> {
  final _c = TextEditingController();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
        title: Text(context.tr('addPlace')),
        content: TextField(controller: _c, autofocus: true, decoration: AppDecor.input(hint: context.tr('placeName'))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(context.tr('cancel'))),
          TextButton(onPressed: () => Navigator.pop(context, _c.text), child: Text(context.tr('add'))),
        ],
      );
}
