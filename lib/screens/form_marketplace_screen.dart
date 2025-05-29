import 'dart:convert';

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'package:http/http.dart' as http;

class FormMarketplaceScreen extends StatefulWidget {
  const FormMarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<FormMarketplaceScreen> createState() => _FormMarketplaceScreenState();
}

class _FormMarketplaceScreenState extends State<FormMarketplaceScreen> {
  final TextEditingController _bedroomsController = TextEditingController();
  final TextEditingController _bathroomsController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _squareMetersController = TextEditingController();
  final TextEditingController _facilitiesController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? _selectedListingType;
  String? _selectedPropertyType;

  final List<String> _listingTypes = ['Dijual', 'Disewakan'];
  final List<String> _propertyTypes = [
    'Rumah',
    'Apartemen',
    'Ruko',
    'Tanah',
    'Villa',
    'Kost'
  ];

  @override
  void dispose() {
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _addressController.dispose();
    _squareMetersController.dispose();
    _facilitiesController.dispose();
    _titleController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> addProperty(BuildContext context) async {
    final url = Uri.parse(
        'http://127.0.0.1:8000/api/properties/store/'); // Adjust as needed

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'listing_type': _selectedListingType,
        'property_type': _selectedPropertyType,
        'bedrooms': _bedroomsController.text,
        'bathrooms': _bathroomsController.text,
        'address': _addressController.text,
        'square_meters': _squareMetersController.text,
        'facilities': _facilitiesController.text,
        'title': _titleController.text,
        'harga': _priceController.text,
        'photo': '', // implement photo upload separately
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Property successfully added')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add property: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Penawaran Baru',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo upload area
            GestureDetector(
              onTap: () {
                // Implement photo upload functionality
              },
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 40,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambahkan foto',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Listing type dropdown
            _buildDropdown(
              hint: 'Dijual atau disewakan',
              value: _selectedListingType,
              items: _listingTypes,
              onChanged: (value) {
                setState(() {
                  _selectedListingType = value;
                });
              },
            ),
            const SizedBox(height: 12),

            // Property type dropdown
            _buildDropdown(
              hint: 'Jenis properti',
              value: _selectedPropertyType,
              items: _propertyTypes,
              onChanged: (value) {
                setState(() {
                  _selectedPropertyType = value;
                });
              },
            ),
            const SizedBox(height: 12),

            // Bedrooms field
            _buildTextField(
              controller: _bedroomsController,
              hintText: 'Kamar tidur',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // Title Field
            _buildTextField(
              controller: _titleController,
              hintText: 'Judul iklan',
            ),
            const SizedBox(height: 12),

// Price Field
            _buildTextField(
              controller: _priceController,
              hintText: 'Harga (cth: Rp xxx.xxx.xxx)',
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 12),

            // Bathrooms field
            _buildTextField(
              controller: _bathroomsController,
              hintText: 'Kamar mandi',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // Address field
            _buildTextField(
              controller: _addressController,
              hintText: 'Alamat properti',
            ),
            const SizedBox(height: 12),

            // Square meters field
            _buildTextField(
              controller: _squareMetersController,
              hintText: 'Meter Persegi',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            // Facilities field (multiline)
            TextField(
              controller: _facilitiesController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Fasilitas',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Save functionality
                      addProperty(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              hint,
              style: TextStyle(color: Colors.grey.shade400),
            ),
          ),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          iconSize: 24,
          elevation: 16,
          style: const TextStyle(color: Colors.black),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          borderRadius: BorderRadius.circular(12),
          items: items.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
