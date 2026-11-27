import 'package:flutter/material.dart';

class EmployeeReportEditingPanel extends StatefulWidget {
  final String initialCategory;
  final String initialPriority;
  final bool allowCategoryEditing;

  final Future<void> Function({
    required String category,
    required String priority,
  })
  onSave;

  const EmployeeReportEditingPanel({
    super.key,
    required this.initialCategory,
    required this.initialPriority,
    required this.onSave,
    this.allowCategoryEditing = true,
  });

  @override
  State<EmployeeReportEditingPanel> createState() =>
      _EmployeeReportEditingPanelState();
}

class _EmployeeReportEditingPanelState
    extends State<EmployeeReportEditingPanel> {
  late final TextEditingController _categoryController;
  late String _selectedPriority;

  bool _isSaving = false;

  static const List<String> _priorities = ['low', 'medium', 'high'];

  @override
  void initState() {
    super.initState();

    _categoryController = TextEditingController(text: widget.initialCategory);

    final priority = widget.initialPriority.toLowerCase();

    _selectedPriority = _priorities.contains(priority) ? priority : 'medium';
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final category = _categoryController.text.trim();

    if (category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category cannot be empty.')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Changes'),
          content: const Text('Are you sure you want to save these changes?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await widget.onSave(category: category, priority: _selectedPriority);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Changes saved successfully.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to save changes.')));
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
            Text(
              widget.allowCategoryEditing
                  ? 'Employee Report Editing'
                  : 'Report Priority Editing',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _categoryController,
              readOnly: !widget.allowCategoryEditing,
              decoration: InputDecoration(
                labelText: 'Official Category',
                border: const OutlineInputBorder(),
                helperText: widget.allowCategoryEditing
                    ? null
                    : 'Use the Official Category Correction section.',
                suffixIcon: widget.allowCategoryEditing
                    ? null
                    : const Icon(Icons.lock_outline),
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              initialValue: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
              items: _priorities.map((priority) {
                return DropdownMenuItem(
                  value: priority,
                  child: Text(priority.toUpperCase()),
                );
              }).toList(),
              onChanged: _isSaving
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() {
                          _selectedPriority = value;
                        });
                      }
                    },
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveChanges,
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
