import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medical_info.dart';
import '../services/firebase_service.dart';
import '../utils/constants.dart';

class MedicalInfoScreen extends StatefulWidget {
  const MedicalInfoScreen({super.key});

  @override
  State<MedicalInfoScreen> createState() => _MedicalInfoScreenState();
}

class _MedicalInfoScreenState extends State<MedicalInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firebaseService = FirebaseService();
  bool _isLoading = false;
  String? _errorMessage;

  // Basic Info Controllers
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _addressController = TextEditingController();
  String? _selectedSex;
  String? _selectedBloodType;
  String? _selectedRhBloodType;
  DateTime? _birthDate;
  bool _isOrganDonor = false;

  // Health Info Controllers
  final _medicalConditionsController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _reactionsController = TextEditingController();
  final _remarksController = TextEditingController();

  List<String> _medicalConditions = [];
  List<String> _medications = [];
  List<String> _allergies = [];
  List<String> _reactions = [];

  @override
  void initState() {
    super.initState();
    _loadMedicalInfo();
  }

  Future<void> _loadMedicalInfo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final medicalInfo = await _firebaseService.getMedicalInfo();
      if (medicalInfo != null) {
        setState(() {
          // Basic Info
          _weightController.text =
              medicalInfo.basicInfo?.weight?.toString() ?? '';
          _heightController.text =
              medicalInfo.basicInfo?.height?.toString() ?? '';
          _addressController.text = medicalInfo.basicInfo?.address ?? '';
          _selectedSex = medicalInfo.basicInfo?.sex;
          _selectedBloodType = medicalInfo.basicInfo?.bloodType;
          _selectedRhBloodType = medicalInfo.basicInfo?.rhBloodType;
          _birthDate = medicalInfo.basicInfo?.birthDate;
          _isOrganDonor = medicalInfo.basicInfo?.isOrganDonor ?? false;

          // Health Info
          _medicalConditions = medicalInfo.healthInfo?.medicalConditions ?? [];
          _medications = medicalInfo.healthInfo?.medications ?? [];
          _allergies = medicalInfo.healthInfo?.allergies ?? [];
          _reactions = medicalInfo.healthInfo?.reactions ?? [];
          _remarksController.text = medicalInfo.healthInfo?.remarks ?? '';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load medical information';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  void _addToList(List<String> list, String value) {
    if (value.isNotEmpty) {
      setState(() {
        list.add(value);
      });
    }
  }

  void _removeFromList(List<String> list, String value) {
    setState(() {
      list.remove(value);
    });
  }

  Future<void> _saveMedicalInfo() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final medicalInfo = MedicalInfo(
          userId: _firebaseService.currentUser?.uid,
          basicInfo: BasicInfo(
            weight: double.tryParse(_weightController.text),
            height: double.tryParse(_heightController.text),
            address: _addressController.text,
            sex: _selectedSex,
            bloodType: _selectedBloodType,
            rhBloodType: _selectedRhBloodType,
            birthDate: _birthDate,
            isOrganDonor: _isOrganDonor,
          ),
          healthInfo: HealthInfo(
            medicalConditions: _medicalConditions,
            medications: _medications,
            allergies: _allergies,
            reactions: _reactions,
            remarks: _remarksController.text,
          ),
        );

        await _firebaseService.updateMedicalInfo(medicalInfo);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Medical information updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to update medical information';
        });
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      appBar: AppBar(
        backgroundColor: AppColors.secondary,
        title: const Text('Medical Information'),
        elevation: 0,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information Section
                      _buildSectionTitle('Basic Information'),
                      const SizedBox(height: 16),

                      // Weight
                      TextFormField(
                        controller: _weightController,
                        decoration: InputDecoration(
                          labelText: 'Weight (kg)',
                          prefixIcon: const Icon(Icons.monitor_weight_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppColors.cardBackground,
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),

                      // Height
                      TextFormField(
                        controller: _heightController,
                        decoration: InputDecoration(
                          labelText: 'Height (cm)',
                          prefixIcon: const Icon(Icons.height),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppColors.cardBackground,
                        ),
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),

                      // Address
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Address',
                          prefixIcon: const Icon(Icons.location_on_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppColors.cardBackground,
                        ),
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),

                      // Sex
                      DropdownButtonFormField<String>(
                        value: _selectedSex,
                        decoration: InputDecoration(
                          labelText: 'Sex',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppColors.cardBackground,
                        ),
                        items:
                            ['Male', 'Female', 'Other']
                                .map(
                                  (sex) => DropdownMenuItem(
                                    value: sex,
                                    child: Text(sex),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSex = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Blood Type
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedBloodType,
                              decoration: InputDecoration(
                                labelText: 'Blood Type',
                                prefixIcon: const Icon(Icons.bloodtype),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: AppColors.cardBackground,
                              ),
                              items:
                                  ['A', 'B', 'AB', 'O']
                                      .map(
                                        (type) => DropdownMenuItem(
                                          value: type,
                                          child: Text(type),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedBloodType = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedRhBloodType,
                              decoration: InputDecoration(
                                labelText: 'RH',
                                prefixIcon: const Icon(Icons.bloodtype),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: AppColors.cardBackground,
                              ),
                              items:
                                  ['+', '-']
                                      .map(
                                        (type) => DropdownMenuItem(
                                          value: type,
                                          child: Text(type),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedRhBloodType = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Birth Date
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Birth Date',
                            prefixIcon: const Icon(
                              Icons.calendar_today_outlined,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: AppColors.cardBackground,
                          ),
                          child: Text(
                            _birthDate != null
                                ? DateFormat('MMM dd, yyyy').format(_birthDate!)
                                : 'Select Date',
                            style: TextStyle(
                              color:
                                  _birthDate != null
                                      ? Colors.white
                                      : Colors.white.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Organ Donor
                      SwitchListTile(
                        title: const Text('Organ Donor'),
                        value: _isOrganDonor,
                        onChanged: (value) {
                          setState(() {
                            _isOrganDonor = value;
                          });
                        },
                      ),
                      const SizedBox(height: 24),

                      // Health Information Section
                      _buildSectionTitle('Health Information'),
                      const SizedBox(height: 16),

                      // Medical Conditions
                      _buildListInput(
                        label: 'Medical Conditions',
                        controller: _medicalConditionsController,
                        list: _medicalConditions,
                        onAdd:
                            () => _addToList(
                              _medicalConditions,
                              _medicalConditionsController.text,
                            ),
                        onRemove:
                            (value) =>
                                _removeFromList(_medicalConditions, value),
                      ),
                      const SizedBox(height: 16),

                      // Medications
                      _buildListInput(
                        label: 'Medications',
                        controller: _medicationsController,
                        list: _medications,
                        onAdd:
                            () => _addToList(
                              _medications,
                              _medicationsController.text,
                            ),
                        onRemove:
                            (value) => _removeFromList(_medications, value),
                      ),
                      const SizedBox(height: 16),

                      // Allergies
                      _buildListInput(
                        label: 'Allergies',
                        controller: _allergiesController,
                        list: _allergies,
                        onAdd:
                            () => _addToList(
                              _allergies,
                              _allergiesController.text,
                            ),
                        onRemove: (value) => _removeFromList(_allergies, value),
                      ),
                      const SizedBox(height: 16),

                      // Reactions
                      _buildListInput(
                        label: 'Reactions',
                        controller: _reactionsController,
                        list: _reactions,
                        onAdd:
                            () => _addToList(
                              _reactions,
                              _reactionsController.text,
                            ),
                        onRemove: (value) => _removeFromList(_reactions, value),
                      ),
                      const SizedBox(height: 16),

                      // Remarks
                      TextFormField(
                        controller: _remarksController,
                        decoration: InputDecoration(
                          labelText: 'Remarks',
                          prefixIcon: const Icon(Icons.note_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: AppColors.cardBackground,
                        ),
                        maxLines: 3,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 24),

                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveMedicalInfo,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                  : const Text(
                                    'Save Changes',
                                    style: TextStyle(fontSize: 16),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildListInput({
    required String label,
    required TextEditingController controller,
    required List<String> list,
    required VoidCallback onAdd,
    required Function(String) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller,
                decoration: InputDecoration(
                  hintText: 'Add $label',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: AppColors.cardBackground,
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {
                onAdd();
                controller.clear();
              },
              icon: const Icon(Icons.add_circle_outline),
              color: AppColors.primary,
            ),
          ],
        ),
        if (list.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                list
                    .map(
                      (item) => Chip(
                        label: Text(item),
                        deleteIcon: const Icon(Icons.close),
                        onDeleted: () => onRemove(item),
                      ),
                    )
                    .toList(),
          ),
        ],
      ],
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _addressController.dispose();
    _medicalConditionsController.dispose();
    _medicationsController.dispose();
    _allergiesController.dispose();
    _reactionsController.dispose();
    _remarksController.dispose();
    super.dispose();
  }
}
