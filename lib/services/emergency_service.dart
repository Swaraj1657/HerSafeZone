/// Service class to handle emergency-related functionality

import 'package:geolocator/geolocator.dart';
import 'package:telephony_sms/telephony_sms.dart';
import 'package:flutter_direct_call_plus/flutter_direct_call.dart';
import 'package:permission_handler/permission_handler.dart';

class EmergencyService {
  // Singleton instance
  static final EmergencyService instance = EmergencyService._internal();
  EmergencyService._internal();
  final _telephonySMS = TelephonySMS();
  bool _isEmergencyActive = false;
  getPermissionMsg() async {
    await _telephonySMS.requestPermission();
  }

  getLocationPermission() async {
    Geolocator.requestPermission();
  }

  getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return position;
  }

  sendMsg() async {
    Position currentPostion = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    _telephonySMS.sendSMS(
      phone: "9029022260", // You might want to make this configurable
      message:
          "https://www.google.com/maps/search/?api=1&query=${currentPostion.latitude},${currentPostion.longitude}",
      // "hello",
    );
  }

  call() async {
    Permission.phone.request();
    FlutterDirectCall.makeDirectCall('9029022260');
  }

  /// Starts the emergency process when SOS is triggered
  Future<void> startEmergencyProcess() async {
    if (_isEmergencyActive) return;
    _isEmergencyActive = true;
    // getLocationPermission();
    getPermissionMsg();
    // Position position = getLocation();
    // log(position as String);
    sendMsg();
    call();

    // TODO: Implement the following emergency actions:
    // 1. Get current location
    // 2. Send alerts to emergency contacts
    // 3. Contact nearby authorities
    // 4. Start recording audio/video
    // 5. Send location updates periodically
  }

  /// Stops the emergency process
  void stopEmergencyProcess() {
    if (!_isEmergencyActive) return;
    _isEmergencyActive = false;

    // TODO: Implement the following actions:
    // 1. Stop location tracking
    // 2. Stop recording
    // 3. Send "safe" notification to contacts
    // 4. Save incident report
  }

  /// Checks if an emergency is currently active
  bool isEmergencyActive() => _isEmergencyActive;
}
