import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Photo extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String path;

  @HiveField(2)
  String label;

  @HiveField(3)
  final DateTime dateAdded;

  Photo({
    required this.id,
    required this.path,
    required this.label,
    required this.dateAdded,
  });
}

class PhotoAdapter extends TypeAdapter<Photo> {
  @override
  final int typeId = 0;

  @override
  Photo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Photo(
      id: fields[0] as String,
      path: fields[1] as String,
      label: fields[2] as String,
      dateAdded: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Photo obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.path)
      ..writeByte(2)
      ..write(obj.label)
      ..writeByte(3)
      ..write(obj.dateAdded);
  }
}
