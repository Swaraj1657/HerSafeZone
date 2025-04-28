/// Service class to handle emergency-related functionality

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:telephony_sms/telephony_sms.dart';
import 'package:flutter_direct_call_plus/flutter_direct_call.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/emergency_contact.dart';
import 'firebase_service.dart';
import 'dart:async';

class EmergencyService {
  // Singleton instance
  static final EmergencyService instance = EmergencyService._internal();
  EmergencyService._internal();

  final _telephonySMS = TelephonySMS();
  final FirebaseService _firebaseService = FirebaseService();

  bool _isEmergencyActive = false;
  Timer? _locationUpdateTimer;
  List<Map<String, dynamic>> _locationHistory = [];
  DateTime? _startTime;

  Future<void> requestAllPermissions() async {
    await _telephonySMS.requestPermission();
    await Geolocator.requestPermission();
    await Permission.phone.request();
  }

  Future<Position> getLocation() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void _startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(const Duration(minutes: 1), (
      timer,
    ) async {
      if (!_isEmergencyActive) {
        timer.cancel();
        return;
      }

      try {
        final position = await getLocation();
        final locationData = {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'timestamp': DateTime.now(),
          'accuracy': position.accuracy,
        };

        _locationHistory.add(locationData);

        final user = _firebaseService.currentUser;
        if (user != null && _startTime != null) {
          await FirebaseFirestore.instance
              .collection('emergency_history')
              .doc(user.uid)
              .set({
                'lastUpdated': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));

          final alertDoc =
              await FirebaseFirestore.instance
                  .collection('emergency_history')
                  .doc(user.uid)
                  .collection('alerts')
                  .doc(_startTime?.toIso8601String())
                  .get();

          List<dynamic> existingLocations = [];
          if (alertDoc.exists) {
            existingLocations = alertDoc.data()?['locations'] ?? [];
          }

          existingLocations.add(locationData);

          await FirebaseFirestore.instance
              .collection('emergency_history')
              .doc(user.uid)
              .collection('alerts')
              .doc(_startTime?.toIso8601String())
              .set({
                'startTime': _startTime,
                'status': 'active',
                'locations': existingLocations,
                'lastUpdated': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));
        }
      } catch (e) {
        debugPrint('Error updating location: $e');
      }
    });
  }

  Future<void> sendMsg(List<EmergencyContact> contacts) async {
    final currentPosition = await getLocation();
    final locationUrl =
        "https://www.google.com/maps/search/?api=1&query=${currentPosition.latitude},${currentPosition.longitude}";
    final message = "EMERGENCY: I need help! My location: $locationUrl";

    for (final contact in contacts) {
      _telephonySMS.sendSMS(phone: contact.phone, message: message);
    }
  }

  Future<void> call(String phoneNumber) async {
    await Permission.phone.request();
    FlutterDirectCall.makeDirectCall(phoneNumber);
  }

  Future<void> startEmergencyProcess() async {
    await requestAllPermissions();
    if (_isEmergencyActive) return;

    _isEmergencyActive = true;
    _startTime = DateTime.now();
    _locationHistory = [];

    try {
      final contacts = await _firebaseService.getEmergencyContacts();
      if (contacts.isEmpty) {
        throw Exception(
          'No emergency contacts found. Please add at least one emergency contact.',
        );
      }

      final primaryContact = contacts.firstWhere(
        (contact) => contact.isPrimary,
        orElse: () => contacts.first,
      );

      await sendMsg(contacts);
      await call(primaryContact.phone);

      final user = _firebaseService.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('emergency_history')
            .doc(user.uid)
            .set({
              'lastUpdated': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

        await FirebaseFirestore.instance
            .collection('emergency_history')
            .doc(user.uid)
            .collection('alerts')
            .doc(_startTime?.toIso8601String())
            .set({
              'startTime': _startTime,
              'status': 'active',
              'locations': [],
              'contactsNotified': contacts.map((c) => c.phone).toList(),
              'primaryContact': primaryContact.phone,
              'lastUpdated': FieldValue.serverTimestamp(),
            });
      }

      _startLocationUpdates();
    } catch (e) {
      debugPrint('Error in emergency process: \$e');
      await stopEmergencyProcess();
      rethrow;
    }
  }

  Future<void> stopEmergencyProcess() async {
    if (!_isEmergencyActive) return;
    _isEmergencyActive = false;

    _locationUpdateTimer?.cancel();

    final user = _firebaseService.currentUser;
    if (user != null && _startTime != null) {
      try {
        await FirebaseFirestore.instance
            .collection('emergency_history')
            .doc(user.uid)
            .collection('alerts')
            .doc(_startTime?.toIso8601String())
            .set({
              'endTime': DateTime.now(),
              'status': 'completed',
              'duration': DateTime.now().difference(_startTime!).inMinutes,
              'lastUpdated': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

        await FirebaseFirestore.instance
            .collection('emergency_history')
            .doc(user.uid)
            .set({
              'lastUpdated': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Error updating emergency record: \$e');
      }
    }

    _startTime = null;
  }

  bool isEmergencyActive() => _isEmergencyActive;
}
