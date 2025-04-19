import 'package:field_project_test1/screens/mapscreen.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/safety_location_card.dart';

/// LocationScreen shows the map and nearby safe locations
class LocationScreen extends StatelessWidget {
  const LocationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: Text('Safe Locations', style: AppTextStyles.heading),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Map placeholder (Replace with actual map implementation)
          Expanded(
            flex: 6,
            child: Container(
              margin: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(child: Mapscreen()),
            ),
          ),

          // Safety locations list
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Nearby Safe Places', style: AppTextStyles.subheading),
                  const SizedBox(height: AppSpacing.md),
                  Expanded(
                    child: ListView(
                      children: const [
                        SafetyLocationCard(
                          name: 'Central Police Station',
                          distance: '0.5 km',
                          type: LocationType.police,
                        ),
                        SafetyLocationCard(
                          name: 'City Hospital',
                          distance: '1.2 km',
                          type: LocationType.hospital,
                        ),
                        SafetyLocationCard(
                          name: 'Women\'s Safety Center',
                          distance: '1.8 km',
                          type: LocationType.safetyCenter,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
