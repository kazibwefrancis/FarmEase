import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/cow_model.dart';
import 'dart:io';

class CowFormPage extends StatefulWidget {
  final Cow? cow;
  final int? index;

  const CowFormPage({super.key, this.cow, this.index});

  @override
  _CowFormPageState createState() => _CowFormPageState();
}

class _CowFormPageState extends State<CowFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _breedController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _milkOutputController = TextEditingController();
  final TextEditingController _milkConditionController = TextEditingController();
  File? _image;
  String? _vaccinationFilePath;
  String? _breedingFilePath;
  String? _healthFilePath;
  bool _isSubmitting = false;
  bool _showDocumentsSection = false;
  double? _feedRecommendation;
  Map<DateTime, String> _dailyMilkProduction = {};

  @override
  void initState() {
    super.initState();
    if (widget.cow != null) {
      _nameController.text = widget.cow!.name;
      _ageController.text = widget.cow!.age;
      _breedController.text = widget.cow!.breed;
      _weightController.text = widget.cow!.weight;
      _milkOutputController.text = widget.cow!.milkOutput;
      _milkConditionController.text = widget.cow!.milkCondition;
      _vaccinationFilePath = widget.cow!.vaccinationFilePath;
      _breedingFilePath = widget.cow!.breedingFilePath;
      _healthFilePath = widget.cow!.healthFilePath;
      if (widget.cow!.imagePath.isNotEmpty) {
        _image = File(widget.cow!.imagePath);
      }
      // Load existing daily milk production data
      if (widget.cow!.dailyMilkProduction != null) {
        _dailyMilkProduction = Map.fromEntries(
          widget.cow!.dailyMilkProduction!.entries.map((entry) {
            return MapEntry(DateTime.parse(entry.key as String), entry.value);
          })
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDocument(String type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        if (type == 'vaccination') {
          _vaccinationFilePath = result.files.single.path!;
        } else if (type == 'breeding') {
          _breedingFilePath = result.files.single.path!;
        } else if (type == 'health') {
          _healthFilePath = result.files.single.path!;
        }
      });
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate() && _image != null) {
      setState(() => _isSubmitting = true);
      
      final cow = Cow(
        name: _nameController.text,
        age: _ageController.text,
        breed: _breedController.text,
        weight: _weightController.text,
        vaccinationFilePath: _vaccinationFilePath ?? '',
        breedingFilePath: _breedingFilePath ?? '',
        healthFilePath: _healthFilePath ?? '',
        milkOutput: _milkOutputController.text,
        milkCondition: _milkConditionController.text,
        imagePath: _image!.path,
        dailyMilkProduction: _dailyMilkProduction,
      );

      final box = Hive.box<Cow>('cows');
      if (widget.index != null) {
        await box.putAt(widget.index!, cow);
      } else {
        await box.add(cow);
      }

      Navigator.pop(context);
    }
  }

  void _deleteCow() async {
    if (widget.index != null) {
      final box = Hive.box<Cow>('cows');
      await box.deleteAt(widget.index!);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.cow == null ? 'Add Cow Details' : 'Edit Cow Details',
          style: GoogleFonts.roboto(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[700],
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          if (widget.cow != null)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red[400]),
              onPressed: _deleteCow,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green[700]!, width: 2),
                      color: Colors.grey[200],
                    ),
                    child: _image != null
                        ? CircleAvatar(
                            radius: 60,
                            backgroundImage: FileImage(_image!),
                          )
                        : Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                  ),
                ),
                SizedBox(height: 25),

                _buildSectionHeader('Basic Information'),
                _buildTextField(_nameController, 'Cow Name', Icons.pets),
                SizedBox(height: 15),
                _buildTextField(_ageController, 'Age (years)', Icons.calendar_today),
                SizedBox(height: 15),
                _buildTextField(_breedController, 'Breed', Icons.agriculture),
                SizedBox(height: 15),
                _buildTextField(_weightController, 'Weight (kg)', Icons.scale),
                SizedBox(height: 15),
                _buildTextField(_milkOutputController, 'Average Daily Milk Output (liters)', Icons.local_drink),
                SizedBox(height: 15),
                _buildMilkConditionField(),
                SizedBox(height: 25),

                _buildDailyMilkProductionSection(),
                SizedBox(height: 25),

                _buildFeedRecommendationSection(),
                SizedBox(height: 25),

                Row(
                  children: [
                    Icon(Icons.folder_special, color: Colors.green[700], size: 24),
                    SizedBox(width: 12),
                    Text(
                      'Additional Records',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(_showDocumentsSection ? Icons.expand_less : Icons.expand_more, color: Colors.green[700]),
                      onPressed: () => setState(() => _showDocumentsSection = !_showDocumentsSection),
                    ),
                  ],
                ),
                
                if (_showDocumentsSection)
                  Column(
                    children: [
                      SizedBox(height: 15),
                      _buildDocumentPicker('Vaccination Records', 'vaccination'),
                      SizedBox(height: 15),
                      _buildDocumentPicker('Breeding Records', 'breeding'),
                      SizedBox(height: 15),
                      _buildDocumentPicker('Health Records', 'health'),
                      SizedBox(height: 25),
                    ],
                  ),

                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.label_outline, color: Colors.green[700], size: 20),
          SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.roboto(
            color: Colors.green[700],
            fontSize: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(icon, color: Colors.green[700], size: 24),
          contentPadding: EdgeInsets.all(18),
          floatingLabelBehavior: FloatingLabelBehavior.always,
        ),
        style: GoogleFonts.roboto(fontSize: 16),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildMilkConditionField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Icon(Icons.local_drink, color: Colors.green[700], size: 24),
            SizedBox(width: 16),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _milkConditionController.text.isEmpty ? null : _milkConditionController.text,
                onChanged: (String? newValue) {
                  setState(() {
                    _milkConditionController.text = newValue!;
                  });
                },
                items: <String>['Excellent', 'Good', 'Fair', 'Poor'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: GoogleFonts.roboto(fontSize: 16),
                    ),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Milk Condition',
                  labelStyle: GoogleFonts.roboto(
                    color: Colors.green[700],
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select milk condition';
                  }
                  return null;
                },
                icon: Icon(Icons.arrow_drop_down, color: Colors.green[700]),
                style: GoogleFonts.roboto(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentPicker(String label, String type) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.document_scanner, color: Colors.green[700], size: 20),
              SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            icon: Icon(Icons.upload_file, size: 20),
            label: Text(
              'Choose File',
              style: GoogleFonts.roboto(fontSize: 16),
            ),
            onPressed: () => _pickDocument(type),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          SizedBox(height: 12),
          if ((type == 'vaccination' && _vaccinationFilePath != null) ||
              (type == 'breeding' && _breedingFilePath != null) ||
              (type == 'health' && _healthFilePath != null))
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[700], size: 18),
                SizedBox(width: 12),
                Flexible(
                  child: Text(
                    'Selected: ${_getFileName(type)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[700],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _getFileName(String type) {
    switch (type) {
      case 'vaccination': return _vaccinationFilePath!.split('/').last;
      case 'breeding': return _breedingFilePath!.split('/').last;
      case 'health': return _healthFilePath!.split('/').last;
      default: return '';
    }
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 32),
        ),
        child: _isSubmitting
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              )
            : Text(
                widget.cow == null ? 'Submit' : 'Update',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 3.0,
                      color: Colors.black54,
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDailyMilkProductionSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, color: Colors.green[700], size: 24),
              SizedBox(width: 12),
              Text(
                'Daily Milk Production',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Track daily milk production to monitor your cow\'s performance:',
            style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey[700]),
          ),
          SizedBox(height: 16),
          _buildCalendarView(),
          SizedBox(height: 16),
          _buildAddProductionEntry(),
        ],
      ),
    );
  }

  Widget _buildCalendarView() {
    final now = DateTime.now();
    final lastWeek = now.subtract(Duration(days: 7));

    return Container(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        itemBuilder: (context, index) {
          final day = lastWeek.add(Duration(days: index));
          final formattedDate = DateFormat('MMM d').format(day);
          final production = _dailyMilkProduction[day] ?? '';

          return Container(
            width: 100,
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    formattedDate,
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      color: Colors.green[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Divider(color: Colors.green[700]),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    production.isEmpty ? 'No data' : '$production L',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.green[800],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddProductionEntry() {
    return Row(
      children: [
        Expanded(
          child: _buildTextField(
            _milkOutputController, 
            'Today\'s Milk Production (liters)', 
            Icons.local_drink
          ),
        ),
        SizedBox(width: 16),
        ElevatedButton(
          onPressed: () => _addDailyProduction(),
          child: Text('Add Entry'),
        ),
      ],
    );
  }

  void _addDailyProduction() {
    try {
      double milkOutput = double.parse(_milkOutputController.text);
      final now = DateTime.now();
      setState(() {
        _dailyMilkProduction[now] = milkOutput.toStringAsFixed(1);
        _milkOutputController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid number for milk output')),
      );
    }
  }

  Widget _buildFeedRecommendationSection() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.grain, color: Colors.green[700], size: 24),
              SizedBox(width: 12),
              Text(
                'Feed Recommendation',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Text(
            'Based on the cow\'s milk production and condition, here is a feed recommendation:',
            style: GoogleFonts.roboto(fontSize: 16, color: Colors.grey[700]),
          ),
          SizedBox(height: 16),
          _buildFeedCalculator(),
          SizedBox(height: 16),
          _buildAIBasedRecommendation(),
        ],
      ),
    );
  }

  Widget _buildFeedCalculator() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                _milkOutputController, 
                'Average Daily Milk Output (liters)', 
                Icons.local_drink
              ),
            ),
            SizedBox(width: 16),
            ElevatedButton(
              onPressed: () => _calculateFeedRecommendation(),
              child: Text('Calculate Feed'),
            ),
          ],
        ),
        SizedBox(height: 16),
        if (_feedRecommendation != null)
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recommended Daily Feed:',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '${_feedRecommendation!.toStringAsFixed(2)} kg',
                    style: GoogleFonts.roboto(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _calculateFeedRecommendation() {
    try {
      double milkOutput = double.parse(_milkOutputController.text);
      double cowWeight = double.parse(_weightController.text);
      double feed = (milkOutput * 0.5) + (cowWeight * 0.01) + 2;
      setState(() {
        _feedRecommendation = feed;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid numbers for milk output and cow weight')),
      );
    }
  }

  Widget _buildAIBasedRecommendation() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI-Based Feed Optimization',
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green[700],
            ),
          ),
          SizedBox(height: 12),
          Text(
            'This section provides advanced feed recommendations based on machine learning analysis of your cow\'s data.',
            style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[700]),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            icon: Icon(Icons.smart_toy),
            label: Text('Generate AI Recommendation'),
            onPressed: () => _generateAIRecommendation(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
            ),
          ),
        ],
      ),
    );
  }

  void _generateAIRecommendation() {
    String milkCondition = _milkConditionController.text;
    String recommendation;

    switch (milkCondition) {
      case 'Excellent':
        recommendation = 'Maintain current feed regimen. Consider adding 1-2kg of high-protein supplement.';
        break;
      case 'Good':
        recommendation = 'Consider increasing feed by 1-2kg with balanced nutrition to improve milk quality.';
        break;
      case 'Fair':
        recommendation = 'Increase feed by 2-3kg with focus on protein and minerals. Monitor condition closely.';
        break;
      case 'Poor':
        recommendation = 'Significantly increase feed intake. Consult with a veterinarian for potential health issues.';
        break;
      default:
        recommendation = 'No specific recommendation available.';
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('AI Feed Recommendation'),
        content: Text(recommendation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}