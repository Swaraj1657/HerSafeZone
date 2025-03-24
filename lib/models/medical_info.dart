import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalInfo {
  final String? id;
  final String? userId;
  final BasicInfo? basicInfo;
  final HealthInfo? healthInfo;
  final DateTime? updatedAt;

  MedicalInfo({
    this.id,
    this.userId,
    this.basicInfo,
    this.healthInfo,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'basicInfo': basicInfo?.toMap(),
      'healthInfo': healthInfo?.toMap(),
      'updatedAt': updatedAt,
    };
  }

  factory MedicalInfo.fromMap(Map<String, dynamic> map, String id) {
    return MedicalInfo(
      id: id,
      userId: map['userId'],
      basicInfo:
          map['basicInfo'] != null ? BasicInfo.fromMap(map['basicInfo']) : null,
      healthInfo:
          map['healthInfo'] != null
              ? HealthInfo.fromMap(map['healthInfo'])
              : null,
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

class BasicInfo {
  final double? weight;
  final double? height;
  final String? address;
  final String? sex;
  final String? bloodType;
  final String? rhBloodType;
  final DateTime? birthDate;
  final bool? isOrganDonor;

  BasicInfo({
    this.weight,
    this.height,
    this.address,
    this.sex,
    this.bloodType,
    this.rhBloodType,
    this.birthDate,
    this.isOrganDonor,
  });

  Map<String, dynamic> toMap() {
    return {
      'weight': weight,
      'height': height,
      'address': address,
      'sex': sex,
      'bloodType': bloodType,
      'rhBloodType': rhBloodType,
      'birthDate': birthDate != null ? Timestamp.fromDate(birthDate!) : null,
      'isOrganDonor': isOrganDonor,
    };
  }

  factory BasicInfo.fromMap(Map<String, dynamic> map) {
    return BasicInfo(
      weight: map['weight']?.toDouble(),
      height: map['height']?.toDouble(),
      address: map['address'],
      sex: map['sex'],
      bloodType: map['bloodType'],
      rhBloodType: map['rhBloodType'],
      birthDate: (map['birthDate'] as Timestamp?)?.toDate(),
      isOrganDonor: map['isOrganDonor'],
    );
  }
}

class HealthInfo {
  final List<String>? medicalConditions;
  final List<String>? medications;
  final List<String>? allergies;
  final List<String>? reactions;
  final String? remarks;

  HealthInfo({
    this.medicalConditions,
    this.medications,
    this.allergies,
    this.reactions,
    this.remarks,
  });

  Map<String, dynamic> toMap() {
    return {
      'medicalConditions': medicalConditions,
      'medications': medications,
      'allergies': allergies,
      'reactions': reactions,
      'remarks': remarks,
    };
  }

  factory HealthInfo.fromMap(Map<String, dynamic> map) {
    return HealthInfo(
      medicalConditions: List<String>.from(map['medicalConditions'] ?? []),
      medications: List<String>.from(map['medications'] ?? []),
      allergies: List<String>.from(map['allergies'] ?? []),
      reactions: List<String>.from(map['reactions'] ?? []),
      remarks: map['remarks'],
    );
  }
}
