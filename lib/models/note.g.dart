// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteAdapter extends TypeAdapter<Note> {
  @override
  final int typeId = 0;

  @override
  Note read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Note(
      name: fields[0] as String,
      link: fields[1] as String,
      course: fields[2] as String,
      subject: fields[3] as String,
      userName: fields[4] as String,
      userDP: fields[5] as String,
      userUid: fields[6] as String,
      description: fields[7] as String,
      likesCount: fields[8] as int,
      uploadedAt: fields[9] as DateTime,
      noteId: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Note obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.link)
      ..writeByte(2)
      ..write(obj.course)
      ..writeByte(3)
      ..write(obj.subject)
      ..writeByte(4)
      ..write(obj.userName)
      ..writeByte(5)
      ..write(obj.userDP)
      ..writeByte(6)
      ..write(obj.userUid)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.likesCount)
      ..writeByte(9)
      ..write(obj.uploadedAt)
      ..writeByte(10)
      ..write(obj.noteId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
