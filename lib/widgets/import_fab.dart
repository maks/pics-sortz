import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'import_dialog.dart';

class ImportFab extends StatelessWidget {
  const ImportFab({super.key});

  Future<void> _importImage(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && context.mounted) {
      showDialog(
        context: context,
        builder: (context) => ImportDialog(imagePath: image.path),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _importImage(context),
      child: const Icon(Icons.add_a_photo),
    );
  }
}
