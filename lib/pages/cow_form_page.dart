
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive/hive.dart';
import 'package:file_picker/file_picker.dart'; // For document uploads
import 'package:google_fonts/google_fonts.dart'; // For decorative fonts
import '../models/cow_model.dart';
import 'dart:io';

class CowFormPage extends StatefulWidget {
  final Cow? cow; // Optional cow data for editing
  final int? index; // Index of the cow in the Hive box

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
  File? _image;
  String? _vaccinationFilePath;
  String? _breedingFilePath;
  String? _healthFilePath;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill the form if editing an existing cow
    if (widget.cow != null) {
      _nameController.text = widget.cow!.name;
      _ageController.text = widget.cow!.age;
      _breedController.text = widget.cow!.breed;
      _weightController.text = widget.cow!.weight;
      _milkOutputController.text = widget.cow!.milkOutput;
      _vaccinationFilePath = widget.cow!.vaccinationFilePath;
      _breedingFilePath = widget.cow!.breedingFilePath;
      _healthFilePath = widget.cow!.healthFilePath;
      if (widget.cow!.imagePath.isNotEmpty) {
        _image = File(widget.cow!.imagePath);
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
      setState(() {
        _isSubmitting = true;
      });
      
      final cow = Cow(
        name: _nameController.text,
        age: _ageController.text,
        breed: _breedController.text,
        weight: _weightController.text,
        vaccinationFilePath: _vaccinationFilePath ?? '',
        breedingFilePath: _breedingFilePath ?? '',
        healthFilePath: _healthFilePath ?? '',
        milkOutput: _milkOutputController.text,
        imagePath: _image!.path,
      );

      final box = Hive.box<Cow>('cows');
      if (widget.index != null) {
        // Update existing cow
        await box.putAt(widget.index!, cow);
      } else {
        // Add new cow
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
          style: GoogleFonts.lobster(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.green[700],
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          if (widget.cow != null) // Show delete button only when editing
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red[400]),
              onPressed: _deleteCow,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Image Upload
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.green[700]!, width: 2),
                    ),
                    child: _image != null
                        ? CircleAvatar(
                            radius: 60,
                            backgroundImage: FileImage(_image!),
                          )
                        : Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                  ),
                ),
                SizedBox(height: 20),

                // Cow Name
                _buildTextField(_nameController, 'Cow Name', Icons.pets),
                SizedBox(height: 10),

                // Age
                _buildTextField(_ageController, 'Age', Icons.calendar_today),
                SizedBox(height: 10),

                // Breed
                _buildTextField(_breedController, 'Breed', Icons.agriculture),
                SizedBox(height: 10),

                // Estimated Weight
                _buildTextField(_weightController, 'Estimated Weight', Icons.scale),
                SizedBox(height: 10),

                // Average Milk Output
                _buildTextField(_milkOutputController, 'Average Milk Output', Icons.local_drink),
                SizedBox(height: 10),

                // Vaccination Records
                _buildDocumentPicker('Vaccination Records', 'vaccination'),
                SizedBox(height: 10),

                // Breeding Records
                _buildDocumentPicker('Breeding Records', 'breeding'),
                SizedBox(height: 10),

                // Health Records
                _buildDocumentPicker('Health Records', 'health'),
                SizedBox(height: 20),

                // Submit Button
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.green[700]),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDocumentPicker(String label, String type) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.document_scanner, color: Colors.green[700], size: 20),
                SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green[700]),
                ),
              ],
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              icon: Icon(Icons.upload_file),
              label: Text(
                'Choose File',
                style: TextStyle(color: Colors.white), // Changed text color to white
              ),
              onPressed: () => _pickDocument(type),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 8),
            if ((type == 'vaccination' && _vaccinationFilePath != null) ||
                (type == 'breeding' && _breedingFilePath != null) ||
                (type == 'health' && _healthFilePath != null))
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 16),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'File Selected: ${type == 'vaccination' ? _vaccinationFilePath!.split('/').last : type == 'breeding' ? _breedingFilePath!.split('/').last : _healthFilePath!.split('/').last}',
                      style: TextStyle(fontSize: 14, color: Colors.green[700]), // Filename in green
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.symmetric(horizontal: 24),
        ),
        child: _isSubmitting
            ? CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : Text(
                widget.cow == null ? 'Submit' : 'Update',
                style: GoogleFonts.roboto(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 2.0,
                      color: Colors.black45,
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
