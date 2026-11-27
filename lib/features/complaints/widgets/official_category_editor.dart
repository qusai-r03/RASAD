import 'package:flutter/material.dart';

class OfficialCategoryEditor extends StatefulWidget {
  final String? initialCategory;
  final List<String> categories;
  final ValueChanged<String> onCategoryChanged;

  const OfficialCategoryEditor({
    super.key,
    this.initialCategory,
    required this.categories,
    required this.onCategoryChanged,
  });

  @override
  State<OfficialCategoryEditor> createState() => _OfficialCategoryEditorState();
}

class _OfficialCategoryEditorState extends State<OfficialCategoryEditor> {
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();

    _selectedCategory = widget.categories.contains(widget.initialCategory)
        ? widget.initialCategory
        : null;
  }

  Future<void> _confirmCategory() async {
    final category = _selectedCategory;

    if (category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Official Category'),
        content: Text('Set the official category to "$category"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    widget.onCategoryChanged(category);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Official Category Correction',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Preview only - no Firebase updates.',
              style: TextStyle(color: Colors.orange),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Select Official Category',
                border: OutlineInputBorder(),
              ),
              items: widget.categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _confirmCategory,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Confirm Category'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
