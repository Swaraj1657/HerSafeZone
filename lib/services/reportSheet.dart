import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportSheet extends StatefulWidget {
  final LatLng currentLocation;
  final LatLng? pickedLocation;
  final Function(Map<String, dynamic>) onReportSubmitted;

  ReportSheet({
    required this.currentLocation,
    required this.onReportSubmitted,
    this.pickedLocation,
  });

  @override
  _ReportSheetState createState() => _ReportSheetState();
}

class _ReportSheetState extends State<ReportSheet> {
  String? selectedIncident;
  String? selectedIntensity;
  String? selectedLocation;
  TextEditingController descriptionController = TextEditingController();

  final List<String> location = ['Current Location', 'Picked Location'];
  final List<String> incidents = [
    'Robbery',
    'Not safe for alone',
    'Not safe for women',
  ];
  final List<String> intensities = ['Low', 'Medium', 'High'];

  Future<void> _saveReportToFirebase(Map<String, dynamic> report) async {
    try {
      // Convert LatLng to GeoPoint for Firestore
      GeoPoint geoPoint = GeoPoint(
        report['position'].latitude,
        report['position'].longitude,
      );

      // Create report data
      final reportData = {
        'position': geoPoint,
        'incident': report['incident'],
        'intensity': report['intensity'],
        'description': report['description'],
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('reports')
          .add(reportData);
    } catch (e) {
      print('Error saving report: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: 20,
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Report an Incident",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            /// Select Location
            DropdownButtonFormField<String>(
              value: selectedLocation,
              decoration: InputDecoration(
                labelText: "Select Location ",
                border: OutlineInputBorder(),
              ),
              items:
                  location.map((value) {
                    return DropdownMenuItem(value: value, child: Text(value));
                  }).toList(),
              onChanged: (val) {
                setState(() => selectedLocation = val);
              },
            ),
            SizedBox(height: 16),

            /// INCIDENT TYPE
            DropdownButtonFormField<String>(
              value: selectedIncident,
              decoration: InputDecoration(
                labelText: "Select Incident Type",
                border: OutlineInputBorder(),
              ),
              items:
                  incidents.map((value) {
                    return DropdownMenuItem(value: value, child: Text(value));
                  }).toList(),
              onChanged: (val) {
                setState(() => selectedIncident = val);
              },
            ),
            SizedBox(height: 16),

            /// INTENSITY
            DropdownButtonFormField<String>(
              value: selectedIntensity,
              decoration: InputDecoration(
                labelText: "Select Intensity",
                border: OutlineInputBorder(),
              ),
              items:
                  intensities.map((value) {
                    return DropdownMenuItem(value: value, child: Text(value));
                  }).toList(),
              onChanged: (val) {
                setState(() => selectedIntensity = val);
              },
            ),
            SizedBox(height: 16),

            /// DESCRIPTION
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Add Description",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),

            /// SUBMIT BUTTON
            ElevatedButton.icon(
              onPressed: () async {
                if (selectedIncident != null &&
                    selectedIntensity != null &&
                    selectedLocation != null) {
                  final LatLng selectedLatLng =
                      (selectedLocation == 'Picked Location' &&
                              widget.pickedLocation != null)
                          ? widget.pickedLocation!
                          : widget.currentLocation;

                  final color = _getColorBasedOnIncidentAndIntensity(
                    selectedIncident!,
                    selectedIntensity!,
                  );

                  final report = {
                    'position': selectedLatLng,
                    'incident': selectedIncident,
                    'intensity': selectedIntensity,
                    'description': descriptionController.text,
                    'color': color,
                  };

                  await _saveReportToFirebase(report);
                  widget.onReportSubmitted(report);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Please select both incident and intensity",
                      ),
                    ),
                  );
                }
              },
              icon: Icon(Icons.send),
              label: Text("Submit Report"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorBasedOnIncidentAndIntensity(
    String incident,
    String intensity,
  ) {
    Color baseColor;

    switch (incident) {
      case 'Robbery':
        baseColor = Colors.yellow;
        break;
      case 'Not safe for women':
        baseColor = Colors.red;
        break;
      case 'Not safe for alone':
        baseColor = Colors.orange;
        break;
      default:
        baseColor = Colors.grey;
    }

    double opacity;
    switch (intensity) {
      case 'Low':
        opacity = 0.15;
        break;
      case 'Medium':
        opacity = 0.22;
        break;
      case 'High':
        opacity = 0.3;
        break;
      default:
        opacity = 0.1;
    }

    return baseColor.withOpacity(opacity);
  }
}
