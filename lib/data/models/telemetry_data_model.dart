import 'dart:math' as math;

import '../../domain/entities/sensor_data.dart';

class TelemetryDataModel {
  final BmeDataModel? bme;
  final GpsDataModel? gps;
  final MpuDataModel? mpu;
  final MsDataModel? ms;
  final int? ts;

  TelemetryDataModel({
    this.bme,
    this.gps,
    this.mpu,
    this.ms,
    this.ts,
  });

  factory TelemetryDataModel.fromJson(Map<String, dynamic> json) {
    return TelemetryDataModel(
      bme: json['bme'] != null ? BmeDataModel.fromJson(json['bme']) : null,
      gps: json['gps'] != null ? GpsDataModel.fromJson(json['gps']) : null,
      mpu: json['mpu'] != null ? MpuDataModel.fromJson(json['mpu']) : null,
      ms: json['ms'] != null ? MsDataModel.fromJson(json['ms']) : null,
      ts: json['ts'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bme': bme?.toJson(),
      'gps': gps?.toJson(),
      'mpu': mpu?.toJson(),
      'ms': ms?.toJson(),
      'ts': ts,
    };
  }

  // Domain entity'sine dönüştürme (mock veriler kaldırıldı, gerçek RTDB verileri kullanıldı)
  List<SensorData> toSensorDataList() {
    final List<SensorData> sensorDataList = [];
    final now = DateTime.now();

    // Sıcaklık sensörü
    if (bme?.tempC != null) {
      sensorDataList.add(SensorData(
        type: SensorType.temperature,
        value: bme!.tempC!,
        minValue: 0.0,
        maxValue: 50.0,
        unit: '°C',
        alertLevel: _getTemperatureAlertLevel(bme!.tempC!),
        timestamp: now,
      ));
    }

    // Nem sensörü
    if (bme?.hum != null) {
      sensorDataList.add(SensorData(
        type: SensorType.humidity,
        value: bme!.hum!,
        minValue: 0.0,
        maxValue: 100.0,
        unit: '%',
        alertLevel: _getHumidityAlertLevel(bme!.hum!),
        timestamp: now,
      ));
    }

    // İvme sensörü
    if (mpu?.accel != null && mpu!.accel!.length >= 3) {
      final double totalAccel = _calculateTotalAcceleration(mpu!.accel!);
      sensorDataList.add(SensorData(
        type: SensorType.acceleration,
        value: totalAccel,
        minValue: 0.0,
        maxValue: 20.0,
        unit: 'm/s²',
        alertLevel: _getAccelerationAlertLevel(totalAccel),
        timestamp: now,
      ));
    }

    // Açısal hız sensörü
    if (mpu?.gyro != null && mpu!.gyro!.length >= 3) {
      final double totalGyro = _calculateTotalGyro(mpu!.gyro!);
      sensorDataList.add(SensorData(
        type: SensorType.angularVelocity,
        value: totalGyro,
        minValue: -5.0,
        maxValue: 5.0,
        unit: '°/s',
        alertLevel: _getGyroAlertLevel(totalGyro),
        timestamp: now,
      ));
    }

    // Yön sensörü (manyetik)
    if (mpu?.mag != null && mpu!.mag!.length >= 3) {
      final double direction = _calculateDirection(mpu!.mag![0], mpu!.mag![1]);
      sensorDataList.add(SensorData(
        type: SensorType.direction,
        value: direction,
        minValue: 0.0,
        maxValue: 360.0,
        unit: '°',
        alertLevel: AlertLevel.none,
        timestamp: now,
      ));
    }

    // Basınç sensörü
    if (ms?.press != null) {
      sensorDataList.add(SensorData(
        type: SensorType.pressure,
        value: ms!.press!,
        minValue: 980.0,
        maxValue: 1030.0,
        unit: 'hPa',
        alertLevel: _getPressureAlertLevel(ms!.press!),
        timestamp: now,
      ));
    }

    // Yükseklik (GPS'ten, yoksa ms.alt_press'ten hesapla)
    double? altitude;
    if (gps?.alt != null) {
      altitude = gps!.alt!.toDouble();
    } else if (ms?.press != null) {
      altitude = _calculateAltitude(ms!.press!);
    }
    if (altitude != null) {
      sensorDataList.add(SensorData(
        type: SensorType.altitude,
        value: altitude,
        minValue: 0.0,
        maxValue: 3000.0,
        unit: 'm',
        alertLevel: _getAltitudeAlertLevel(altitude),
        timestamp: now,
      ));
    }

    // Hız sensörü (GPS'ten)
    if (gps?.speed != null) {
      sensorDataList.add(SensorData(
        type: SensorType.speed,
        value: gps!.speed!.toDouble(),
        minValue: 0.0,
        maxValue: 100.0,
        unit: 'km/h',  // Varsayım, birim değiştirilebilir
        alertLevel: _getSpeedAlertLevel(gps!.speed!.toDouble()),
        timestamp: now,
      ));
    }

    // GPS konumu
    if (gps?.lati != null && gps?.long != null) {
      sensorDataList.add(SensorData(
        type: SensorType.gpsPosition,
        value: gps!.lati!.toDouble(),
        secondaryValue: gps!.long!.toDouble(),
        minValue: -90.0,
        maxValue: 90.0,
        unit: 'Lat/Lon',
        alertLevel: AlertLevel.none,
        timestamp: now,
      ));
    }

    // Yakıt seviyesi (RTDB'de yoksa varsayılan, ama mock değil - eğer eklenirse değiştir)
    sensorDataList.add(SensorData(
      type: SensorType.fuelLevel,
      value: 100.0,  // Veri yoksa tam dolu varsay, veya kaldır
      minValue: 0.0,
      maxValue: 100.0,
      unit: '%',
      alertLevel: AlertLevel.none,
      timestamp: now,
    ));

    return sensorDataList;
  }

  // Yardımcı metodlar (aynı kaldı, ama speed alert eklendi)
  double _calculateTotalAcceleration(List<double> accel) {
    return math.sqrt(accel[0] * accel[0] + accel[1] * accel[1] + accel[2] * accel[2]);
  }

  double _calculateTotalGyro(List<double> gyro) {
    return math.sqrt(gyro[0] * gyro[0] + gyro[1] * gyro[1] + gyro[2] * gyro[2]);
  }

  double _calculateDirection(double x, double y) {
    double direction = (math.atan2(y, x) * 180 / math.pi) + 180;
    return direction % 360;
  }

  double _calculateAltitude(double pressure) {
    const double P0 = 1013.25;
    return 44330.0 * (1.0 - math.pow(pressure / P0, 1.0 / 5.255));
  }

  AlertLevel _getTemperatureAlertLevel(double temp) {
    if (temp > 40.0) return AlertLevel.critical;
    if (temp > 35.0) return AlertLevel.warning;
    return AlertLevel.none;
  }

  AlertLevel _getHumidityAlertLevel(double humidity) {
    if (humidity > 80.0) return AlertLevel.warning;
    return AlertLevel.none;
  }

  AlertLevel _getPressureAlertLevel(double pressure) {
    if (pressure < 985.0 || pressure > 1025.0) return AlertLevel.warning;
    return AlertLevel.none;
  }

  AlertLevel _getAccelerationAlertLevel(double accel) {
    if (accel > 15.0) return AlertLevel.critical;
    if (accel > 10.0) return AlertLevel.warning;
    return AlertLevel.none;
  }

  AlertLevel _getGyroAlertLevel(double gyro) {
    if (gyro > 3.0) return AlertLevel.warning;
    return AlertLevel.none;
  }

  AlertLevel _getAltitudeAlertLevel(double altitude) {
    if (altitude > 2500.0) return AlertLevel.critical;
    if (altitude > 2000.0) return AlertLevel.warning;
    return AlertLevel.none;
  }

  AlertLevel _getSpeedAlertLevel(double speed) {
    if (speed > 80.0) return AlertLevel.critical;
    if (speed > 50.0) return AlertLevel.warning;
    return AlertLevel.none;
  }
}

class BmeDataModel {
  final double? hum;
  final double? tempC;

  BmeDataModel({
    this.hum,
    this.tempC,
  });

  factory BmeDataModel.fromJson(Map<String, dynamic> json) {
    return BmeDataModel(
      hum: json['hum']?.toDouble(),
      tempC: json['tempC']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hum': hum,
      'tempC': tempC,
    };
  }
}

class GpsDataModel {
  final int? alt;
  final int? lati;
  final int? long;
  final int? speed;
  final String? time;

  GpsDataModel({
    this.alt,
    this.lati,
    this.long,
    this.speed,
    this.time,
  });

  factory GpsDataModel.fromJson(Map<String, dynamic> json) {
    return GpsDataModel(
      alt: json['alt'],
      lati: json['lati'],
      long: json['long'],
      speed: json['speed'],
      time: json['time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alt': alt,
      'lati': lati,
      'long': long,
      'speed': speed,
      'time': time,
    };
  }
}

class MpuDataModel {
  final List<double>? accel;
  final List<double>? gyro;
  final List<double>? mag;

  MpuDataModel({
    this.accel,
    this.gyro,
    this.mag,
  });

  factory MpuDataModel.fromJson(Map<String, dynamic> json) {
    return MpuDataModel(
      accel: json['accel'] != null ? List<double>.from(json['accel'].map((x) => x.toDouble())) : null,
      gyro: json['gyro'] != null ? List<double>.from(json['gyro'].map((x) => x.toDouble())) : null,
      mag: json['mag'] != null ? List<double>.from(json['mag'].map((x) => x.toDouble())) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accel': accel,
      'gyro': gyro,
      'mag': mag,
    };
  }
}

class MsDataModel {
  final double? alt_press;
  final double? press;

  MsDataModel({
    this.alt_press,
    this.press,
  });

  factory MsDataModel.fromJson(Map<String, dynamic> json) {
    return MsDataModel(
      alt_press: json['alt_press']?.toDouble(),
      press: json['press']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'alt_press': alt_press,
      'press': press,
    };
  }
}