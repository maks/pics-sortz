import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import '../models/photo.dart';
import '../models/group.dart';
import '../providers/app_state.dart';

class PhotoViewScreen extends StatefulWidget {
  final Photo photo;
  final Group group;

  const PhotoViewScreen({super.key, required this.photo, required this.group});

  @override
  State<PhotoViewScreen> createState() => _PhotoViewScreenState();
}

class _PhotoViewScreenState extends State<PhotoViewScreen> {
  late String _currentImagePath;

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.photo.path;
  }

  Future<void> _cropImage() async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: _currentImagePath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Edit Photo',
          toolbarColor: Colors.blueGrey,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Edit Photo'),
      ],
    );

    if (croppedFile != null) {
      // In a real app, we might want to save this as a new file or overwrite.
      // For simplicity, we'll overwrite the path in the model if the file is different,
      // or just update the view.
      // Since ImageCropper saves to a cache/temp file, we should probably move it
      // or just use it.

      // Let's update the photo model with the new path
      // But wait, Photo object is HiveObject.
      // We need to update it via AppState or directly.

      // NOTE: Modifying the file path in the model.
      // Ideally we should copy it to our app storage.

      setState(() {
        _currentImagePath = croppedFile.path;
      });

      // Update model
      widget.photo.path = croppedFile.path;
      await widget.photo.save();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => _showRenameDialog(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: Text(widget.photo.label)),
              const SizedBox(width: 8),
              const Icon(Icons.edit, size: 16),
            ],
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.crop), onPressed: _cropImage),
          IconButton(
            icon: const Icon(Icons.image),
            tooltip: 'Set as Group Cover',
            onPressed: () {
              context.read<AppState>().setGroupCoverImage(
                widget.group,
                _currentImagePath,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Group cover updated')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(child: Image.file(File(_currentImagePath))),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _confirmDelete(context),
        backgroundColor: Colors.red,
        child: const Icon(Icons.delete),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AppState>().deletePhoto(widget.photo, widget.group);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to group screen
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context) {
    final controller = TextEditingController(text: widget.photo.label);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Photo'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'New Label'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<AppState>().renamePhoto(
                  widget.photo,
                  controller.text,
                );
                setState(() {}); // Refresh UI to show new name
                Navigator.pop(context);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }
}
