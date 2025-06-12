import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:html' as html;

// Assuming you have a file like this for your colors
// e.g., class AppColors { static const primary = Colors.blue; }
class AppColors {
  static const primary = Colors.blue;
}

const String API_BASE_URL = 'http://127.0.0.1:8000/api';

class EditMarketplaceScreen extends StatefulWidget {
  final Map<String, dynamic> property;
  const EditMarketplaceScreen({Key? key, required this.property})
      : super(key: key);

  @override
  State<EditMarketplaceScreen> createState() => _EditMarketplaceScreenState();
}

class _EditMarketplaceScreenState extends State<EditMarketplaceScreen> {
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _addressController = TextEditingController();
  final _squareMetersController = TextEditingController();
  final _facilitiesController = TextEditingController();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();

  XFile? _pickedImageFile;
  String? _selectedImageWebPath;
  String? _selectedListingType;
  String? _selectedPropertyType;

  final _picker = ImagePicker();
  final _listingTypes = ['Dijual', 'Disewakan'];
  final _propertyTypes = [
    'Rumah',
    'Apartemen',
    'Ruko',
    'Tanah',
    'Villa',
    'Kost'
  ];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final p = widget.property;
    _bedroomsController.text = p['bedrooms']?.toString() ?? '';
    _bathroomsController.text = p['bathrooms']?.toString() ?? '';
    _addressController.text = p['address'] ?? '';
    _facilitiesController.text = p['facilities'] ?? '';
    _titleController.text = p['title'] ?? '';
    _squareMetersController.text = p['square_meters']?.toString() ?? '';
    _priceController.text = p['harga']?.toString() ?? '';
    _selectedListingType = p['listing_type'];
    _selectedPropertyType = p['property_type'];
    if (p['image_url'] != null && p['image_url'].toString().isNotEmpty) {
      _selectedImageWebPath = p['image_url'];
    }
  }

  @override
  void dispose() {
    for (var controller in [
      _bedroomsController,
      _bathroomsController,
      _addressController,
      _squareMetersController,
      _facilitiesController,
      _titleController,
      _priceController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _updateProperty() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      setState(() => _isSubmitting = false);
      return;
    }

    var req = http.MultipartRequest(
      'POST',
      Uri.parse('$API_BASE_URL/properties/${widget.property['id']}/update'),
    );

    req.headers['Authorization'] = 'Bearer $token';
    req.headers['Accept'] = 'application/json';
    req.fields['_method'] = 'PUT';

    req.fields['listing_type'] = _selectedListingType ?? '';
    req.fields['property_type'] = _selectedPropertyType ?? '';
    req.fields['bedrooms'] = _bedroomsController.text;
    req.fields['bathrooms'] = _bathroomsController.text;
    req.fields['address'] = _addressController.text;
    req.fields['facilities'] = _facilitiesController.text;
    req.fields['title'] = _titleController.text;
    req.fields['square_meters'] = _squareMetersController.text;
    req.fields['harga'] = _priceController.text;

    if (_pickedImageFile != null) {
      final bytes = await _pickedImageFile!.readAsBytes();
      final mediaType = _pickedImageFile!.mimeType != null
          ? MediaType.parse(_pickedImageFile!.mimeType!)
          : MediaType('image', 'jpeg');

      req.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          bytes,
          filename: _pickedImageFile!.name,
          contentType: mediaType,
        ),
      );
    }

    try {
      var resp = await req.send();
      final body = await http.Response.fromStream(resp);
      setState(() => _isSubmitting = false);

      if (resp.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Properti berhasil diperbarui')),
        );
        Navigator.pop(context, true);
      } else {
        final errorData = jsonDecode(body.body);
        final errorMessage = errorData['message'] ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal update: $errorMessage')),
        );
      }
    } catch (e) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi error: $e')),
      );
    }
  }

  Widget _buildDropdown(String hint, String? value, List<String> items,
      ValueChanged<String?>? onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(color: Colors.grey.shade500)),
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(i)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController c, String hint,
          {TextInputType type = TextInputType.text, int maxLines = 1}) =>
      TextField(
          controller: c,
          keyboardType: type,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white,
          ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Properti')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              // ✅ FIX: The onTap callback is now async
              onTap: () async {
                final file =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (file != null) {
                  // ✅ FIX: Perform async operation *before* calling setState
                  final bytes = await file.readAsBytes();
                  final newImageWebPath =
                      html.Url.createObjectUrlFromBlob(html.Blob([bytes]));

                  // Revoke the old URL to prevent memory leaks on web
                  if (_selectedImageWebPath != null) {
                    html.Url.revokeObjectUrl(_selectedImageWebPath!);
                  }

                  // Now, update the state synchronously
                  setState(() {
                    _pickedImageFile = file;
                    _selectedImageWebPath = newImageWebPath;
                  });
                }
              },
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12)),
                child: _selectedImageWebPath != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.network(_selectedImageWebPath!,
                            fit: BoxFit.cover),
                      )
                    : const Center(
                        child: Icon(Icons.add_photo_alternate_outlined,
                            size: 40, color: Colors.grey)),
              ),
            ),
            const SizedBox(height: 16),
            _buildDropdown('Tipe Iklan', _selectedListingType, _listingTypes,
                (v) => setState(() => _selectedListingType = v)),
            const SizedBox(height: 16),
            _buildDropdown(
                'Jenis Properti',
                _selectedPropertyType,
                _propertyTypes,
                (v) => setState(() => _selectedPropertyType = v)),
            const SizedBox(height: 16),
            _buildTextField(_titleController, 'Judul Iklan'),
            const SizedBox(height: 16),
            _buildTextField(_priceController, 'Harga', type: TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField(_bedroomsController, 'Kamar Tidur',
                type: TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField(_bathroomsController, 'Kamar Mandi',
                type: TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField(_addressController, 'Alamat Properti'),
            const SizedBox(height: 16),
            _buildTextField(_squareMetersController, 'Meter Persegi',
                type: TextInputType.number),
            const SizedBox(height: 16),
            _buildTextField(_facilitiesController, 'Fasilitas', maxLines: 5),
            const SizedBox(height: 24),
            _isSubmitting
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      Expanded(
                          child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28)),
                        ),
                        child: const Text('Cancel',
                            style: TextStyle(color: AppColors.primary)),
                      )),
                      const SizedBox(width: 16),
                      Expanded(
                          child: ElevatedButton(
                        onPressed: _updateProperty,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28))),
                        child: const Text('Save',
                            style: TextStyle(color: Colors.white)),
                      )),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
