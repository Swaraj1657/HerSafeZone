import 'dart:math';

import 'package:field_project_test1/services/reportSheet.dart';
import 'package:field_project_test1/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class Mapscreen extends StatefulWidget {
  const Mapscreen({Key? key}) : super(key: key);

  @override
  State<Mapscreen> createState() => _MapscreenState();
}

class _MapscreenState extends State<Mapscreen> {
  double _calculateDistance(lat1, lon1, lat2, lon2) {
    const earthRadius = 6371000; // meters
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a =
        (sin(dLat / 2) * sin(dLat / 2)) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(degrees) {
    return degrees * pi / 180;
  }

  Location _locationController = Location();
  LatLng? _currentP;
  CameraPosition? initialPosition;
  String? error;
  List<Map<String, dynamic>> reportedCenters = [];
  LatLng? pickedLocation;
  LatLng? destination;

  // Add controller for the map
  GoogleMapController? _mapController;

  // Add a flag to control camera follow mode
  bool _followUser = true;

  // Empty polylines set - we won't add any polylines
  Set<Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    getLocationPermission();
  }

  Future<void> getLocationPermission() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
      if (!_serviceEnabled) {
        setState(() {
          error = "Location services are disabled.";
        });
        return;
      }
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        setState(() {
          error = "Location permission denied.";
        });
        return;
      }
    }

    // Initialize location settings for better accuracy and updates
    _locationController.changeSettings(
      accuracy: LocationAccuracy.high,
      interval: 1000, // Update every second
      distanceFilter: 5, // Update when moved at least 5 meters
    );

    _locationController.onLocationChanged.listen((currentLocation) {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        setState(() {
          _currentP = LatLng(
            currentLocation.latitude!,
            currentLocation.longitude!,
          );

          if (initialPosition == null) {
            initialPosition = CameraPosition(target: _currentP!, zoom: 16);
          }

          // If follow mode is on and map controller exists, update camera position
          if (_followUser && _mapController != null) {
            _mapController!.animateCamera(CameraUpdate.newLatLng(_currentP!));
          }
        });
      }
    });
  }

  Set<Circle> _createCircles() {
    Set<Circle> circles = {};

    for (int i = 0; i < reportedCenters.length; i++) {
      circles.add(
        Circle(
          circleId: CircleId("report_$i"),
          center: reportedCenters[i]['position'],
          radius: 300,
          strokeColor: Colors.black,
          strokeWidth: 1,
          fillColor: reportedCenters[i]['color'],
        ),
      );
    }

    if (pickedLocation != null) {
      circles.add(
        Circle(
          circleId: CircleId("tapped_point"),
          center: pickedLocation!,
          radius: 300,
          strokeColor: Colors.black,
          strokeWidth: 1,
          fillColor: Colors.grey.withOpacity(0.6),
        ),
      );
    }

    return circles;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          error != null
              ? Center(child: Text(error!, style: TextStyle(color: Colors.red)))
              : initialPosition == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                myLocationButtonEnabled: true,
                myLocationEnabled: true,
                zoomControlsEnabled: true,
                compassEnabled: true,

                mapType: MapType.hybrid,
                initialCameraPosition: initialPosition!,
                markers: {
                  if (_currentP != null)
                    Marker(
                      markerId: const MarkerId("Current_Position"),
                      icon: BitmapDescriptor.defaultMarker,
                      position: _currentP!,
                      infoWindow: const InfoWindow(title: "Your Location"),
                    ),
                  if (destination != null)
                    Marker(
                      markerId: const MarkerId("Destination"),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen,
                      ),
                      position: destination!,
                      infoWindow: const InfoWindow(title: "Destination"),
                    ),
                },
                polylines: polylines, // This will now always be an empty set
                circles: _createCircles(),
                onTap: (LatLng tappedPoint) {
                  setState(() {
                    if (pickedLocation == null) {
                      // No picked location yet, set one
                      pickedLocation = tappedPoint;
                      destination = tappedPoint;
                    } else {
                      // Check if user tapped far from picked point — then remove
                      double distance = _calculateDistance(
                        pickedLocation!.latitude,
                        pickedLocation!.longitude,
                        tappedPoint.latitude,
                        tappedPoint.longitude,
                      );

                      if (distance > 30) {
                        // You can tweak this distance (in meters)
                        pickedLocation = null;
                        destination = null;
                      }
                    }

                    _followUser = false;
                  });
                },

                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
                onCameraMove: (_) {
                  // If user manually moves the camera, disable follow mode
                  if (_followUser) {
                    setState(() {
                      _followUser = false;
                    });
                  }
                },
              ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              if (_currentP != null) {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  builder:
                      (context) => ReportSheet(
                        currentLocation: _currentP!,
                        pickedLocation: pickedLocation,
                        onReportSubmitted: (report) {
                          setState(() {
                            reportedCenters.add(report);
                          });
                        },
                      ),
                );
              }
            },
            label: const Text("Report Area"),
            icon: const Icon(Icons.report),
            backgroundColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
