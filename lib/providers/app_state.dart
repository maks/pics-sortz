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
    final group = Group(id: _uuid.v4(), name: name);
    // Initialize empty HiveList
    group.photos = HiveList(_storageService.photoBox);
    await _storageService.groupBox.add(group);
    notifyListeners();
  }

  Future<void> addPhotoToGroup(
    String groupName,
    String filePath,
    String label,
  ) async {
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
    group.coverImagePath ??= filePath;

    await group.save();
    notifyListeners();
  }

  Future<void> deleteGroup(Group group) async {
    // Optionally delete photos inside? For now just delete group container
    // But we should probably delete photos to avoid orphans if they are not shared
    if (group.photos != null) {
      // Create a copy of the list to iterate safely while modifying
      final photosToDelete = List<Photo>.from(group.photos!);
      for (var photo in photosToDelete) {
        await photo.delete();
      }
    }
    await group.delete();
    notifyListeners();
  }

  Future<void> deletePhoto(Photo photo, Group group) async {
    // Remove from group's list
    group.photos?.remove(photo);

    // If this was the cover image, unset it or pick another one
    if (group.coverImagePath == photo.path) {
      if (group.photos != null && group.photos!.isNotEmpty) {
        group.coverImagePath = group.photos!.first.path;
      } else {
        group.coverImagePath = null;
      }
      await group.save();
    }

    // Delete the photo object itself
    await photo.delete();
    notifyListeners();
  }

  Future<void> renameGroup(Group group, String newName) async {
    group.name = newName;
    await group.save();
    notifyListeners();
  }

  Future<void> movePhoto(
    Photo photo,
    Group sourceGroup,
    Group targetGroup,
  ) async {
    // Remove from source group
    sourceGroup.photos?.remove(photo);

    // If this was the cover image of source group, update it
    if (sourceGroup.coverImagePath == photo.path) {
      if (sourceGroup.photos != null && sourceGroup.photos!.isNotEmpty) {
        sourceGroup.coverImagePath = sourceGroup.photos!.first.path;
      } else {
        sourceGroup.coverImagePath = null;
      }
      await sourceGroup.save();
    }

    // Add to target group
    targetGroup.photos?.add(photo);

    // If target group has no cover, set this as cover
    targetGroup.coverImagePath ??= photo.path;

    await targetGroup.save();
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
