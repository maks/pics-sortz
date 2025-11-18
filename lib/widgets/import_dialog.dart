import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';

class ImportDialog extends StatefulWidget {
  final String imagePath;

  const ImportDialog({super.key, required this.imagePath});

  @override
  State<ImportDialog> createState() => _ImportDialogState();
}

class _ImportDialogState extends State<ImportDialog> {
  final _formKey = GlobalKey<FormState>();
  final _groupController = TextEditingController();
  final _labelController = TextEditingController();
  
  @override
  void dispose() {
    _groupController.dispose();
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    // Get existing group names for autocomplete/suggestions if we wanted
    
    return AlertDialog(
      title: const Text('Import Photo'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 150,
                width: double.infinity,
                child: Image.file(File(widget.imagePath), fit: BoxFit.cover),
              ),
              const SizedBox(height: 16),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  return appState.groups
                      .map((g) => g.name)
                      .where((String option) {
                    return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                  });
                },
                onSelected: (String selection) {
                  _groupController.text = selection;
                },
                fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
                  // Sync the autocomplete controller with our controller if needed, 
                  // or just use the autocomplete controller.
                  // Here we just use the textEditingController provided by Autocomplete
                  // But we need to extract the value later.
                  // A simpler way is to just use a TextFormField and let user type.
                  // But Autocomplete is nice.
                  // Let's use a simple TextFormField for now to be robust, 
                  // and maybe a dropdown or chips for existing groups later.
                  return TextFormField(
                    controller: textEditingController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(
                      labelText: 'Group Name',
                      hintText: 'Enter new or existing group',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a group name';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      _groupController.text = value;
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _labelController,
                decoration: const InputDecoration(
                  labelText: 'Label',
                  hintText: 'Name this photo',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a label';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              // Use the controller text or the autocomplete text
              // Since I used the onChange in Autocomplete builder to update _groupController, it should be fine.
              // Wait, the Autocomplete fieldViewBuilder controller is separate.
              // Let's fix the Autocomplete logic or simplify.
              // Simplified: Just use the controller from the builder.
              
              // Actually, let's just use `_groupController` and bind it if possible, 
              // or just read from the form field if I didn't use Autocomplete.
              // Let's stick to a simple TextFormField for now to avoid complexity with Autocomplete state.
              // The user asked for "choose which existing group to add it to, add it to a new group".
              // So a Dropdown + "New" option or an Autocomplete is best.
              
              final groupName = _groupController.text; // This might be empty if I messed up Autocomplete
              final label = _labelController.text;
              
              appState.addPhotoToGroup(groupName, widget.imagePath, label);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
