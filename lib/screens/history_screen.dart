import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/constants.dart';
import '../widgets/incident_card.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'All';

  Stream<QuerySnapshot> _getEmergencyHistoryStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('No user logged in');
      return const Stream.empty();
    }

    var query = FirebaseFirestore.instance
        .collection('emergency_history')
        .doc(user.uid)
        .collection('alerts')
        .orderBy('startTime', descending: true);

    // Filter based on status if needed
    if (_selectedFilter != 'All') {
      if (_selectedFilter == 'Alerts') {
        query = query.where('status', isEqualTo: 'completed');
      }
    }

    return query.snapshots();
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: Text('Emergency History', style: AppTextStyles.heading),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    isSelected: _selectedFilter == 'All',
                    onTap: () => setState(() => _selectedFilter = 'All'),
                  ),
                  _FilterChip(
                    label: 'Alerts',
                    isSelected: _selectedFilter == 'Alerts',
                    onTap: () => setState(() => _selectedFilter = 'Alerts'),
                  ),
                ],
              ),
            ),
          ),

          // Emergency history list
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getEmergencyHistoryStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  debugPrint('Error loading emergency history: ${snapshot.error}');
                  return Center(
                    child: Text(
                      'Error loading emergency history',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text(
                      'No emergency history found',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    
                    // Handle null timestamp safely
                    DateTime? startTime;
                    try {
                      final timestamp = data['startTime'] as Timestamp?;
                      startTime = timestamp?.toDate();
                    } catch (e) {
                      debugPrint('Error converting timestamp: $e');
                    }
                    
                    // Skip this entry if startTime is null
                    if (startTime == null) {
                      return const SizedBox.shrink();
                    }
                    
                    // Get location count and data
                    final locations = data['locations'] as List<dynamic>? ?? [];
                    final contactsNotified = data['contactsNotified'] as List<dynamic>? ?? [];
                    final status = data['status'] as String? ?? 'Unknown';
                    final duration = data['duration'] as int? ?? 0;
                    
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.md),
                      color: AppColors.cardBackground,
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                          listTileTheme: ListTileThemeData(
                            textColor: AppColors.textSecondary,
                          ),
                        ),
                        child: ExpansionTile(
                          title: Text(
                            'Emergency Alert',
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            '${_formatDateTime(startTime)} ${_formatTime(startTime)}\n'
                            'Status: $status',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Duration: $duration minutes',
                                    style: TextStyle(color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    'Contacts Notified: ${contactsNotified.length}',
                                    style: TextStyle(color: AppColors.textSecondary),
                                  ),
                                  if (locations.isNotEmpty) ...[
                                    const SizedBox(height: AppSpacing.md),
                                    Text(
                                      'Location History',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Container(
                                      height: 200,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: AppColors.cardBackground),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: ListView.builder(
                                        padding: const EdgeInsets.all(AppSpacing.sm),
                                        itemCount: locations.length,
                                        itemBuilder: (context, locationIndex) {
                                          final location = locations[locationIndex];
                                          final timestamp = location['timestamp'] as Timestamp?;
                                          final locationTime = timestamp?.toDate();
                                          
                                          return ListTile(
                                            dense: true,
                                            title: Text(
                                              locationTime != null 
                                                ? _formatTime(locationTime)
                                                : 'Location ${locationIndex + 1}',
                                              style: TextStyle(color: AppColors.textSecondary),
                                            ),
                                            subtitle: Text(
                                              'Lat: ${location['latitude']?.toStringAsFixed(6)}\n'
                                              'Long: ${location['longitude']?.toStringAsFixed(6)}',
                                              style: TextStyle(color: AppColors.textSecondary),
                                            ),
                                            trailing: Icon(
                                              Icons.location_on,
                                              color: AppColors.primary,
                                            ),
                                            onTap: () {
                                              final lat = location['latitude'];
                                              final long = location['longitude'];
                                              if (lat != null && long != null) {
                                                // Launch maps URL here
                                                final url = 
                                                  "https://www.google.com/maps/search/?api=1&query=$lat,$long";
                                                // Implement url_launcher here
                                              }
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _FilterChip({required this.label, this.isSelected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textSecondary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
