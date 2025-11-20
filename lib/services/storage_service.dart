import 'package:hive_flutter/hive_flutter.dart';
import '../models/photo.dart';
import '../models/group.dart';

class StorageService {
  static const String photoBoxName = 'photos';
  static const String groupBoxName = 'groups';

  Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(PhotoAdapter());
    Hive.registerAdapter(GroupAdapter());

    await Hive.openBox<Photo>(photoBoxName);
    await Hive.openBox<Group>(groupBoxName);
  }

  Box<Photo> get photoBox => Hive.box<Photo>(photoBoxName);
  Box<Group> get groupBox => Hive.box<Group>(groupBoxName);
}
