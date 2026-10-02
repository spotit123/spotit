import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../l10n/l10n.dart';
import '../models/bar.dart';

class AddSpotScreen extends StatefulWidget {
  final Function(Bar) onAddBar;

  const AddSpotScreen({
    super.key,
    required this.onAddBar,
  });

  @override
  State<AddSpotScreen> createState() => _AddSpotScreenState();
}

class _AddSpotScreenState extends State<AddSpotScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _drinksController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _hoursController = TextEditingController();
  
  String _selectedType = 'Cocktail Bar';
  final List<String> _types = ['Cocktail Bar', 'Speakeasy', 'Rooftop Bar', 'Cafè', 'Pub', 'Wine Bar'];

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _drinksController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _hoursController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final drinksList = _drinksController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final newBar = Bar(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text,
        type: _selectedType,
        description: _descriptionController.text,
        rating: 5.0, // New spots start with 5.0 rating
        reviewCount: 1,
        address: _addressController.text,
        // Madrid central geo bounds default
        latitude: 40.4270 + (DateTime.now().millisecond % 100) * 0.0002, 
        longitude: -3.7020 + (DateTime.now().millisecond % 100) * 0.0002,
        imageUrl: 'https://images.unsplash.com/photo-1543007630-9710e4a00a20?auto=format&fit=crop&w=600&q=80', // Default gorgeous bar image
        distance: 1.2,
        popularDrinks: drinksList.isEmpty ? ['Cocktail della Casa'] : drinksList,
        phone: _phoneController.text.isEmpty ? '+34 910 000 000' : _phoneController.text,
        website: _websiteController.text.isEmpty ? 'N/D' : _websiteController.text,
        openingHours: {
          'Lunedì - Domenica': _hoursController.text.isEmpty ? '18:00 - 02:00' : _hoursController.text,
        },
        vibeTags: ['Energetic', 'Chill'],
        crowdDensity: 30,
        crowdAge: '20s-30s',
        genderRatio: '50% M / 50% F',
        hasMusic: false,
        musicType: 'None',
        reviews: const [],
        galleryImages: const [],
      );

      widget.onAddBar(newBar);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr('add.added', {'name': newBar.name}),
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green[800],
        ),
      );

      // Reset form
      _formKey.currentState!.reset();
      _nameController.clear();
      _addressController.clear();
      _descriptionController.clear();
      _drinksController.clear();
      _phoneController.clear();
      _websiteController.clear();
      _hoursController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16), // Dark Theme background
      appBar: AppBar(
        backgroundColor: const Color(0xFF090D16),
        elevation: 0,
        title: Text(
          tr('add.title'),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('add.details'),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),

                // Name
                _buildTextField(
                  label: tr('add.name'),
                  controller: _nameController,
                  validator: (value) => value!.isEmpty ? tr('add.nameErr') : null,
                ),

                // Category Type (Dropdown)
                Text(
                  tr('add.type'),
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[400]),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131B2E),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFF1E293B)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedType,
                      dropdownColor: const Color(0xFF131B2E),
                      isExpanded: true,
                      style: GoogleFonts.poppins(color: Colors.white, fontSize: 15),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                      items: _types.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value!;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Address
                _buildTextField(
                  label: tr('add.address'),
                  controller: _addressController,
                  validator: (value) => value!.isEmpty ? tr('add.addressErr') : null,
                ),

                // Description
                _buildTextField(
                  label: tr('add.desc'),
                  controller: _descriptionController,
                  maxLines: 3,
                  validator: (value) => value!.isEmpty ? tr('add.descErr') : null,
                ),

                // Popular Drinks
                _buildTextField(
                  label: tr('add.drinks'),
                  controller: _drinksController,
                  hint: tr('add.drinksHint'),
                ),

                // Hours
                _buildTextField(
                  label: tr('add.hours'),
                  controller: _hoursController,
                  hint: 'es. 18:00 - 02:00',
                ),

                // Phone
                _buildTextField(
                  label: tr('add.phone'),
                  controller: _phoneController,
                  hint: 'es. +34 91 123 45 67',
                ),

                // Website
                _buildTextField(
                  label: tr('add.site'),
                  controller: _websiteController,
                  hint: tr('add.siteHint'),
                ),

                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0066FF), // Electric Blue
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: Text(
                      tr('add.save'),
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: validator,
            style: GoogleFonts.poppins(fontSize: 15, color: Colors.white),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
              filled: true,
              fillColor: const Color(0xFF131B2E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF1E293B)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF1E293B)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF0066FF), width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
