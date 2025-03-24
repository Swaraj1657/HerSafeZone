import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/emergency_service.dart';

/// SOSButton is a custom widget that handles emergency alerts
/// It includes animations and press detection for emergency triggering
class SOSButton extends StatefulWidget {
  const SOSButton({super.key});

  @override
  State<SOSButton> createState() => _SOSButtonState();
}

class _SOSButtonState extends State<SOSButton>
    with SingleTickerProviderStateMixin {
  bool isEmergencyActive = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  /// Sets up the pulse animation for the SOS button
  void _setupAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  /// Toggles the emergency state
  void _toggleEmergency() {
    if (!isEmergencyActive) {
      // Start emergency
      EmergencyService.instance.startEmergencyProcess();
    } else {
      // Stop emergency
      EmergencyService.instance.stopEmergencyProcess();
    }

    setState(() {
      isEmergencyActive = !isEmergencyActive;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleEmergency,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isEmergencyActive ? Colors.red : AppColors.primary,
                boxShadow: [
                  BoxShadow(
                    color: (isEmergencyActive ? Colors.red : AppColors.primary)
                        .withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isEmergencyActive)
                      Text(
                        'TAP TO STOP',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }
}
