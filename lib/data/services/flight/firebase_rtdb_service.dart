import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../../models/telemetry_data_model.dart';

class FirebaseRtdbService {
  final FirebaseDatabase _database;

  FirebaseRtdbService({FirebaseDatabase? database})
      : _database = database ??
      FirebaseDatabase.instanceFor(
        app: FirebaseDatabase.instance.app,
        databaseURL:
        'https://sky-vision-control-5ca1b-default-rtdb.europe-west1.firebasedatabase.app',
      );

  // Firebase verisini recursive dönüştür (Map<Object?, Object?> -> Map<String, dynamic>)
  dynamic _convertFirebaseData(dynamic data) {
    if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(), _convertFirebaseData(value)));
    } else if (data is List) {
      return data.map(_convertFirebaseData).toList();
    } else {
      return data;
    }
  }

  // Telemetri verilerini tek seferlik çekmek için
  Future<TelemetryDataModel?> getTelemetryData(String userId) async {
    try {
      final snapshot = await _database
          .ref()
          .child(userId)
          .child('telemetri')
          .get();

      if (snapshot.exists) {
        final convertedData = _convertFirebaseData(snapshot.value);
        return TelemetryDataModel.fromJson(convertedData as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching telemetry data: $e');
      rethrow;
    }
  }

  // Telemetri verilerini gerçek zamanlı dinlemek için
  Stream<TelemetryDataModel?> observeTelemetryData(String userId) {
    final controller = StreamController<TelemetryDataModel?>();

    final subscription = _database
        .ref()
        .child(userId)
        .child('telemetri')
        .onValue
        .listen(
          (event) {
        if (event.snapshot.exists) {
          final convertedData = _convertFirebaseData(event.snapshot.value);
          final data = TelemetryDataModel.fromJson(convertedData as Map<String, dynamic>);
          controller.add(data);
        } else {
          controller.add(null);
        }
      },
      onError: (error) {
        print('Error observing telemetry data: $error');
        controller.addError(error);
      },
    );

    controller.onCancel = () {
      subscription.cancel();
    };

    return controller.stream;
  }
}