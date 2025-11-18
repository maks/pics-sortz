import 'package:hive/hive.dart';
import 'photo.dart';

@HiveType(typeId: 1)
class Group extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? coverImagePath;

  @HiveField(3)
  HiveList<Photo>? photos;

  Group({
    required this.id,
    required this.name,
    this.coverImagePath,
    this.photos,
  });
}

class GroupAdapter extends TypeAdapter<Group> {
  @override
  final int typeId = 1;

  @override
  Group read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Group(
      id: fields[0] as String,
      name: fields[1] as String,
      coverImagePath: fields[2] as String?,
      photos: (fields[3] as HiveList?)?.castHiveList(),
    );
  }

  @override
  void write(BinaryWriter writer, Group obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.coverImagePath)
      ..writeByte(3)
      ..write(obj.photos);
  }
}
