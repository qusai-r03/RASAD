import 'package:flutter/material.dart';

class OfficialCategoryEditor extends StatefulWidget {
  final String? initialCategory;
  final List<String> categories;
  final Future<void> Function(String category) onCategoryChanged;
  final bool isPreview;

  const OfficialCategoryEditor({
    super.key,
    this.initialCategory,
    required this.categories,
    required this.onCategoryChanged,
    this.isPreview = true,
  });

  @override
  State<OfficialCategoryEditor> createState() => _OfficialCategoryEditorState();
}

class _OfficialCategoryEditorState extends State<OfficialCategoryEditor> {
  String? _selectedCategory;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _selectedCategory = widget.categories.contains(widget.initialCategory)
        ? widget.initialCategory
        : null;
  }

  @override
  void didUpdateWidget(covariant OfficialCategoryEditor oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialCategory != widget.initialCategory) {
      _selectedCategory = widget.categories.contains(widget.initialCategory)
          ? widget.initialCategory
          : null;
    }
  }

  Future<void> _confirmCategory() async {
    if (_isSaving) return;

    final category = _selectedCategory;

    if (category == null || !widget.categories.contains(category)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a valid category.')),
      );

      return;
    }

    if (category == widget.initialCategory) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('The category has not changed.')),
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

    if (!mounted || confirmed != true || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onCategoryChanged(category);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isPreview
                ? 'Category confirmed locally.'
                : 'Official category updated successfully.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to update the official category.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
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

            if (widget.isPreview) ...[
              const SizedBox(height: 8),

              const Text(
                'Preview only - no Firebase updates.',
                style: TextStyle(color: Colors.orange),
              ),
            ],

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              key: ValueKey(widget.initialCategory),
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Select Official Category',
                border: OutlineInputBorder(),
              ),
              items: widget.categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: _isSaving
                  ? null
                  : (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _confirmCategory,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(_isSaving ? 'Saving...' : 'Confirm Category'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
