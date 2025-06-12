import 'dart:convert'; // Required for jsonEncode (though less used now) and jsonDecode
import 'dart:typed_data'; // Required for Uint8List

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart'; // Make sure this path is correct
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart'; // Required for MediaType

import 'package:image_picker/image_picker.dart';
import 'dart:html' as html; // Used for revoking object URLs on web

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

  XFile? _pickedImageFile; // Stores the picked image file
  String? _selectedImageWebPath; // For web preview: stores the blob URL

  final ImagePicker _picker = ImagePicker();

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

  bool _isSubmitting = false; // To show a loading indicator during submission

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _addressController.dispose();
    _squareMetersController.dispose();
    _facilitiesController.dispose();
    _titleController.dispose();
    _priceController.dispose();

    if (_selectedImageWebPath != null) {
      html.Url.revokeObjectUrl(_selectedImageWebPath!);
    }
    super.dispose();
  }

  Future<int> getAuthenticatedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      print('Authentication token not found.');
      throw Exception('User not authenticated.');
    }

    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/user'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('User ID: ${data['id']}');
      if (data['id'] != null) {
        return data['id'];
      } else {
        throw Exception('User ID not found in response.');
      }
    } else {
      print('Error fetching user ID: ${response.statusCode} ${response.body}');
      throw Exception(
          'Failed to fetch user ID. Status: ${response.statusCode}');
    }
  }

  Future<void> addProperty(BuildContext context) async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final url = Uri.parse('http://127.0.0.1:8000/api/properties/store/');
      final userId = await getAuthenticatedUserId();
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      var request = http.MultipartRequest('POST', url);

      // Add headers
      request.headers['Accept'] = 'application/json';
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      // Content-Type for multipart/form-data is set automatically by MultipartRequest

      // Add text fields
      request.fields['user_id'] = userId.toString();
      if (_selectedListingType != null) {
        request.fields['listing_type'] = _selectedListingType!;
      }
      if (_selectedPropertyType != null) {
        request.fields['property_type'] = _selectedPropertyType!;
      }
      request.fields['bedrooms'] = _bedroomsController.text;
      request.fields['bathrooms'] = _bathroomsController.text;
      request.fields['address'] = _addressController.text;
      request.fields['square_meters'] = _squareMetersController.text;
      request.fields['facilities'] = _facilitiesController.text;
      request.fields['title'] = _titleController.text;
      request.fields['harga'] = _priceController.text;

      // Add image file if picked
      if (_pickedImageFile != null) {
        Uint8List imageBytes = await _pickedImageFile!.readAsBytes();
        String? mimeType = _pickedImageFile!.mimeType; // Get MIME type
        MediaType? mediaType;
        if (mimeType != null) {
            try {
                mediaType = MediaType.parse(mimeType);
            } catch (e) {
                print("Error parsing MIME type: $mimeType, error: $e");
                // Fallback or decide not to set content type if parsing fails
            }
        }


        var multipartFile = http.MultipartFile.fromBytes(
          'photo', // This is the field name your backend expects for the file
          imageBytes,
          filename: _pickedImageFile!.name, // Send the original filename
          contentType: mediaType, // Set the content type from MIME type
        );
        request.files.add(multipartFile);
      }

      // Send the request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Property successfully added')),
        );
        Navigator.pop(context);
      } else {
        print('Failed to add property. Status: ${response.statusCode}');
        print('Response body: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to add property. Server responded with: ${response.statusCode}. Details: ${response.body}')),
        );
      }
    } catch (e) {
      print('Error in addProperty: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
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
            GestureDetector(
              onTap: () async {
                if (_isSubmitting) return;

                final XFile? pickedFile =
                    await _picker.pickImage(source: ImageSource.gallery);

                if (pickedFile != null) {
                  if (_selectedImageWebPath != null) {
                    html.Url.revokeObjectUrl(_selectedImageWebPath!);
                  }
                  setState(() {
                    _pickedImageFile = pickedFile;
                    // For web, pickedFile.path is a blob URL, suitable for Image.network for local preview
                    _selectedImageWebPath = pickedFile.path;
                  });
                }
              },
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _selectedImageWebPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(11.0),
                        child: Image.network(
                          _selectedImageWebPath!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) {
                            print("Error loading image for preview: $error");
                            return const Center(
                                child: Text('Gagal memuat pratinjau',
                                    style: TextStyle(color: Colors.red)));
                          },
                        ),
                      )
                    : Column(
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
            _buildDropdown(
              hint: 'Dijual atau disewakan',
              value: _selectedListingType,
              items: _listingTypes,
              onChanged: _isSubmitting
                  ? null
                  : (value) {
                      setState(() {
                        _selectedListingType = value;
                      });
                    },
            ),
            const SizedBox(height: 12),
            _buildDropdown(
              hint: 'Jenis properti',
              value: _selectedPropertyType,
              items: _propertyTypes,
              onChanged: _isSubmitting
                  ? null
                  : (value) {
                      setState(() {
                        _selectedPropertyType = value;
                      });
                    },
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _bedroomsController,
              hintText: 'Kamar tidur',
              keyboardType: TextInputType.number,
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _titleController,
              hintText: 'Judul iklan',
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _priceController,
              hintText: 'Harga (cth: Rp xxx.xxx.xxx)',
              keyboardType: TextInputType.text, // Or number, consider formatting/parsing
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _bathroomsController,
              hintText: 'Kamar mandi',
              keyboardType: TextInputType.number,
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _addressController,
              hintText: 'Alamat properti',
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _squareMetersController,
              hintText: 'Meter Persegi',
              keyboardType: TextInputType.number,
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _facilitiesController,
              maxLines: 5,
              enabled: !_isSubmitting,
              decoration: InputDecoration(
                hintText: 'Fasilitas',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: _isSubmitting ? Colors.grey.shade100 : Colors.white,
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
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 24),
            if (_isSubmitting)
              const Center(child: CircularProgressIndicator())
            else
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
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
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
    required void Function(String?)? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: onChanged != null ? Colors.white : Colors.grey.shade100,
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
          style: TextStyle(
              color: onChanged != null ? Colors.black : Colors.grey.shade700),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          borderRadius: BorderRadius.circular(12),
          items: items.map<DropdownMenuItem<String>>((String itemValue) {
            return DropdownMenuItem<String>(
              value: itemValue,
              child: Text(itemValue),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}