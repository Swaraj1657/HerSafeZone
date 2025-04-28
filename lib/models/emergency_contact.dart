class EmergencyContact {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String relationship;
  final bool isPrimary;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? userName; // <-- new

  EmergencyContact({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.relationship,
    required this.isPrimary,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
  });
  
  // Create a map from the EmergencyContact object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'phone': phone,
      'relationship': relationship,
      'isPrimary': isPrimary,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'userName': userName,
    };
  }
  
  // Create an EmergencyContact object from a map
  factory EmergencyContact.fromMap(Map<String, dynamic> map, [String? docId]) {
    return EmergencyContact(
      id: docId ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      phone: map['phone'] ?? '',
      relationship: map['relationship'] ?? '',
      isPrimary: map['isPrimary'] ?? false,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
      userName: map['userName'],
    );
  }

  EmergencyContact copyWith({
    String? name,
    String? phone,
    String? relationship,
    bool? isPrimary,
    DateTime? updatedAt,
  }) {
    return EmergencyContact(
      id: id,
      userId: userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      relationship: relationship ?? this.relationship,
      isPrimary: isPrimary ?? this.isPrimary,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName,
    );
  }
}
