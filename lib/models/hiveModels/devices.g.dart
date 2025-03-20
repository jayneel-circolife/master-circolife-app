// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'devices.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DevicesAdapter extends TypeAdapter<Devices> {
  @override
  final int typeId = 1;

  @override
  Devices read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Devices(
      deviceId: fields[0] as String,
      deviceType: fields[1] as String,
      deviceName: fields[2] as String,
      deviceTemp: fields[3] as int,
      deviceStatus: fields[4] as bool,
      deviceMode: fields[5] as String,
      isadmin: fields[6] as bool,
      fanspeed: fields[7] as int,
      did: fields[8] as String,
      sensordata: fields[9] as String,
      isconnected: fields[10] as bool,
      econsumption: fields[11] as double,
      deviceTimer: fields[12] as int,
      selfClean: fields[13] == null ? false : fields[13] as bool,
      swing: fields[14] == null ? false : fields[14] as bool,
      childLock: fields[15] == null ? false : fields[15] as bool,
      convertible: fields[16] == null ? 0 : fields[16] as int,
      tempLock: fields[17] == null ? 0 : fields[17] as int,
      firmwareVersion: fields[18] == null ? '' : fields[18] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Devices obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.deviceId)
      ..writeByte(1)
      ..write(obj.deviceType)
      ..writeByte(2)
      ..write(obj.deviceName)
      ..writeByte(3)
      ..write(obj.deviceTemp)
      ..writeByte(4)
      ..write(obj.deviceStatus)
      ..writeByte(5)
      ..write(obj.deviceMode)
      ..writeByte(6)
      ..write(obj.isadmin)
      ..writeByte(7)
      ..write(obj.fanspeed)
      ..writeByte(8)
      ..write(obj.did)
      ..writeByte(9)
      ..write(obj.sensordata)
      ..writeByte(10)
      ..write(obj.isconnected)
      ..writeByte(11)
      ..write(obj.econsumption)
      ..writeByte(12)
      ..write(obj.deviceTimer)
      ..writeByte(13)
      ..write(obj.selfClean)
      ..writeByte(14)
      ..write(obj.swing)
      ..writeByte(15)
      ..write(obj.childLock)
      ..writeByte(16)
      ..write(obj.convertible)
      ..writeByte(17)
      ..write(obj.tempLock)
      ..writeByte(18)
      ..write(obj.firmwareVersion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DevicesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
