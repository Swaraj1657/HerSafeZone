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

  // Start location updates every 2 minutes
  void _startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(const Duration(minutes: 2), (
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

        // Update location in Firebase
        final user = _firebaseService.currentUser;
        if (user != null && _startTime != null) {
          // Create or update the emergency_history document
          await FirebaseFirestore.instance
              .collection('emergency_history')
              .doc(user.uid)
              .set({
                'lastUpdated': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));

          // Get the current alert document to preserve existing locations
          final alertDoc =
              await FirebaseFirestore.instance
                  .collection('emergency_history')
                  .doc(user.uid)
                  .collection('alerts')
                  .doc(_startTime?.toIso8601String())
                  .get();

          // Get existing locations array or initialize empty array
          List<dynamic> existingLocations = [];
          if (alertDoc.exists) {
            existingLocations = alertDoc.data()?['locations'] ?? [];
          }

          // Add new location to the array
          existingLocations.add(locationData);

          // Update the alert document with the complete locations array
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

  sendMsg(List<EmergencyContact> contacts) async {
    Position currentPostion = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final locationUrl =
        "https://www.google.com/maps/search/?api=1&query=${currentPostion.latitude},${currentPostion.longitude}";
    final message = "EMERGENCY: I need help! My location: $locationUrl";

    for (final contact in contacts) {
      _telephonySMS.sendSMS(phone: contact.phone, message: message);
    }
  }

  call(String phoneNumber) async {
    Permission.phone.request();
    FlutterDirectCall.makeDirectCall(phoneNumber);
  }

  /// Starts the emergency process when SOS is triggered
  Future<void> startEmergencyProcess() async {
    getPermissionMsg();
    if (_isEmergencyActive) return;
    _isEmergencyActive = true;
    _startTime = DateTime.now();
    _locationHistory = [];

    try {
      // Get emergency contacts
      final contacts = await _firebaseService.getEmergencyContacts();
      if (contacts.isEmpty) {
        throw Exception(
          'No emergency contacts found. Please add at least one emergency contact',
        );
      }

      // Find primary contact
      final primaryContact = contacts.firstWhere(
        (contact) => contact.isPrimary,
        orElse: () => contacts.first,
      );

      // Get permissions
      // getPermissionMsg();
      getLocationPermission();

      // Send SMS to all contacts
      sendMsg(contacts);

      // Call primary contact
      call(primaryContact.phone);

      // Create emergency record in Firebase
      final user = _firebaseService.currentUser;
      if (user != null) {
        // First, create or update the emergency_history document
        await FirebaseFirestore.instance
            .collection('emergency_history')
            .doc(user.uid)
            .set({
              'lastUpdated': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

        // Then, create the initial alert document
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

      // Start location updates
      _startLocationUpdates();
    } catch (e) {
      debugPrint('Error in emergency process: $e');
      stopEmergencyProcess();
      rethrow;
    }
  }

  /// Stops the emergency process
  Future<void> stopEmergencyProcess() async {
    if (!_isEmergencyActive) return;
    _isEmergencyActive = false;

    // Cancel location updates
    _locationUpdateTimer?.cancel();

    // Update emergency record in Firebase
    final user = _firebaseService.currentUser;
    if (user != null && _startTime != null) {
      try {
        // Update the alert document
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

        // Update the lastUpdated timestamp in the emergency_history document
        await FirebaseFirestore.instance
            .collection('emergency_history')
            .doc(user.uid)
            .set({
              'lastUpdated': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Error updating emergency record: $e');
      }
    }

    _startTime = null;
  }

  /// Checks if an emergency is currently active
  bool isEmergencyActive() => _isEmergencyActive;
}
