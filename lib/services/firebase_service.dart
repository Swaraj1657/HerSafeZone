import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medical_info.dart';
import '../models/emergency_contact.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Get user document reference
  DocumentReference<Map<String, dynamic>> get userDoc =>
      _firestore.collection('users').doc(currentUser?.uid);

  // Get medical info document reference
  DocumentReference<Map<String, dynamic>> get medicalInfoDoc =>
      _firestore.collection('medical_info').doc(currentUser?.uid);

  // Get reference to emergency contacts collection
  CollectionReference<Map<String, dynamic>> get _emergencyContactsCollection =>
      _firestore.collection('emergency_contacts');

  // Create or update user profile
  Future<void> updateUserProfile({
    required String name,
    required String phone,
    DateTime? birthDate,
  }) async {
    if (currentUser == null) throw Exception('No user logged in');

    await userDoc.set({
      'name': name,
      'phone': phone,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate) : null,
      'email': currentUser!.email,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUser == null) return null;

    final doc = await userDoc.get();
    return doc.data();
  }

  // Update specific profile field
  Future<void> updateProfileField(String field, dynamic value) async {
    if (currentUser == null) throw Exception('No user logged in');

    await userDoc.update({
      field: value,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Delete user profile
  Future<void> deleteUserProfile() async {
    if (currentUser == null) throw Exception('No user logged in');

    await userDoc.delete();
  }

  // Medical Information Methods
  Future<void> updateMedicalInfo(MedicalInfo medicalInfo) async {
    if (currentUser == null) throw Exception('No user logged in');

    await medicalInfoDoc.set({
      'userId': currentUser!.uid,
      'basicInfo': medicalInfo.basicInfo?.toMap(),
      'healthInfo': medicalInfo.healthInfo?.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<MedicalInfo?> getMedicalInfo() async {
    if (currentUser == null) return null;

    final doc = await medicalInfoDoc.get();
    if (!doc.exists) return null;

    return MedicalInfo.fromMap(doc.data()!, doc.id);
  }

  Future<void> deleteMedicalInfo() async {
    if (currentUser == null) throw Exception('No user logged in');

    await medicalInfoDoc.delete();
  }

  // Emergency Contacts Methods
  Future<void> addEmergencyContact(EmergencyContact contact) async {
    if (currentUser == null) throw Exception('No user logged in');

    // If this is primary contact, unset any existing primary contact
    if (contact.isPrimary) {
      final existingContacts =
          await _emergencyContactsCollection
              .where('userId', isEqualTo: currentUser!.uid)
              .where('isPrimary', isEqualTo: true)
              .get();

      for (var doc in existingContacts.docs) {
        await doc.reference.update({'isPrimary': false});
      }
    }

    await _emergencyContactsCollection.add(contact.toMap());
  }

  Future<List<EmergencyContact>> getEmergencyContacts() async {
    if (currentUser == null) throw Exception('No user logged in');

    final snapshot =
        await _emergencyContactsCollection
            .where('userId', isEqualTo: currentUser!.uid)
            .orderBy('isPrimary', descending: true)
            .orderBy('name')
            .get();

    return snapshot.docs
        .map((doc) => EmergencyContact.fromMap(doc.data()))
        .toList();
  }

  Future<void> updateEmergencyContact(EmergencyContact contact) async {
    if (currentUser == null) throw Exception('No user logged in');

    // If this is primary contact, unset any existing primary contact
    if (contact.isPrimary) {
      final existingContacts =
          await _emergencyContactsCollection
              .where('userId', isEqualTo: currentUser!.uid)
              .where('isPrimary', isEqualTo: true)
              .where('id', isNotEqualTo: contact.id)
              .get();

      for (var doc in existingContacts.docs) {
        await doc.reference.update({'isPrimary': false});
      }
    }

    await _emergencyContactsCollection.doc(contact.id).update(contact.toMap());
  }

  Future<void> deleteEmergencyContact(String contactId) async {
    if (currentUser == null) throw Exception('No user logged in');

    await _emergencyContactsCollection.doc(contactId).delete();
  }
}
