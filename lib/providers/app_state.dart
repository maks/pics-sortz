import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/group.dart';
import '../models/photo.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  final StorageService _storageService;
  final Uuid _uuid = const Uuid();

  AppState(this._storageService);

  List<Group> get groups => _storageService.groupBox.values.toList();

  Future<void> createGroup(String name) async {
    final group = Group(
      id: _uuid.v4(),
      name: name,
    );
    // Initialize empty HiveList
    group.photos = HiveList(_storageService.photoBox);
    await _storageService.groupBox.add(group);
    notifyListeners();
  }

  Future<void> addPhotoToGroup(String groupName, String filePath, String label) async {
    // Find or create group
    Group? group;
    try {
      group = groups.firstWhere((g) => g.name == groupName);
    } catch (e) {
      // Group doesn't exist, create it
      await createGroup(groupName);
      group = groups.firstWhere((g) => g.name == groupName);
    }

    final photo = Photo(
      id: _uuid.v4(),
      path: filePath,
      label: label,
      dateAdded: DateTime.now(),
    );

    await _storageService.photoBox.add(photo);
    group.photos?.add(photo);
    
    // Set cover image if not set
    if (group.coverImagePath == null) {
      group.coverImagePath = filePath;
    }
    
    await group.save();
    notifyListeners();
  }

  Future<void> deleteGroup(Group group) async {
    // Optionally delete photos inside? For now just delete group container
    // But we should probably delete photos to avoid orphans if they are not shared
    if (group.photos != null) {
      for (var photo in group.photos!) {
        await photo.delete();
      }
    }
    await group.delete();
    notifyListeners();
  }

  Future<void> renamePhoto(Photo photo, String newLabel) async {
    photo.label = newLabel;
    await photo.save();
    notifyListeners();
  }
  
  Future<void> setGroupCoverImage(Group group, String imagePath) async {
    group.coverImagePath = imagePath;
    await group.save();
    notifyListeners();
  }
}
