import 'package:flutter/material.dart';
import 'dart:io'; // Needed for File type
import 'dart:convert'; // Needed for jsonDecode
import 'package:http/http.dart' as http; // Add http to your pubspec.yaml
import 'package:image_picker/image_picker.dart'; // Add image_picker to your pubspec.yaml
import 'package:shared_preferences/shared_preferences.dart'; // Add shared_preferences to your pubspec.yaml

// Assuming app_colors.dart is in the utils directory
// You should create this file with the content provided separately.
import '../utils/app_colors.dart';

/// EditProfileScreen allows users to view and update their profile information.
///
/// It fetches user data from a remote server, displays it, and allows
/// for updates, including profile picture changes.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Controllers for text fields
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _nickNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // For handling image picking
  final ImagePicker _picker = ImagePicker();

  // State variables
  File? _profileImageFile; // Holds the new image selected by the user
  String?
      _profileImageUrl; // Holds the existing profile image URL from the server
  bool _isLoading = true; // To show a loader while fetching data
  bool _isSaving = false; // To show a loader on the save button

  @override
  void initState() {
    super.initState();
    // Fetch the user's profile data when the screen is initialized
    _loadUserProfile();
  }

  @override
  void dispose() {
    // Dispose of the controllers to free up resources
    _fullNameController.dispose();
    _nickNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  /// Fetches user profile data from the API and populates the fields.
  Future<void> _loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Authentication token not found. Please log in again.');
      }

      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/user'), // Your API endpoint
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Populate controllers and state with fetched data
        setState(() {
          _fullNameController.text = data['name'] ?? '';
          _nickNameController.text = data['nickname'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          _addressController.text = data['address'] ?? '';
          _profileImageUrl = data['profile_photo_url'];
        });
      } else {
        throw Exception(
            'Failed to load user data. Server responded with ${response.statusCode}');
      }
    } catch (e) {
      // Show an error message if fetching fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      // Hide the loader
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Saves the updated profile data to the server.
  /// Handles both text data and the new profile image if one was selected.
  Future<void> _saveProfile() async {
    if (_isSaving) return; // Prevent multiple save requests
    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Authentication token not found.');
      }

      // Use a multipart request to handle both form data and file upload
      var request = http.MultipartRequest(
        'POST', // Or 'PUT', depending on your API
        Uri.parse(
            'http://127.0.0.1:8000/api/user/update'), // Your update endpoint
      );

      // Add headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add text fields
      request.fields['name'] = _fullNameController.text;
      // request.fields['nickname'] = _nickNameController.text;
      request.fields['email'] = _emailController.text;
      request.fields['phone'] = _phoneController.text;
      request.fields['address'] = _addressController.text;

      // Add image file if a new one was selected
      if (_profileImageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_photo', // The field name your API expects for the image
            _profileImageFile!.path,
          ),
        );
      }

      // Send the request
      final response = await request.send();

      // Check the response
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        final respStr = await response.stream.bytesToString();
        throw Exception('Failed to update profile: $respStr');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  /// Handles picking an image from the specified source (camera or gallery).
  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
          source: source, imageQuality: 80, maxWidth: 800);

      if (pickedFile != null) {
        setState(() {
          _profileImageFile = File(pickedFile.path);
        });
        Navigator.pop(context); // Close the bottom sheet
        _showImageChangedSuccess();
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to pick image. Please check permissions.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Shows a modal bottom sheet with options to change the profile picture.
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Change Profile Picture',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () => _pickImage(ImageSource.camera)),
                  _buildImageSourceOption(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () => _pickImage(ImageSource.gallery)),
                ],
              ),
              if (_profileImageFile != null || _profileImageUrl != null) ...[
                const SizedBox(height: 20),
                TextButton(
                  onPressed: _showRemovePhotoConfirmation,
                  child: const Text('Remove Current Photo',
                      style: TextStyle(color: Colors.red, fontSize: 16)),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// Displays a success message after the profile picture has been changed.
  void _showImageChangedSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Profile picture updated!'),
          backgroundColor: Colors.green),
    );
  }

  /// Shows a confirmation dialog before removing the profile picture.
  void _showRemovePhotoConfirmation() {
    Navigator.pop(context); // Close the bottom sheet first
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove Profile Picture'),
          content: const Text(
              'Are you sure you want to remove your profile picture?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                setState(() {
                  _profileImageFile = null;
                  _profileImageUrl = null; // Also clear the URL from the server
                });
                Navigator.pop(context); // Close the dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Profile picture removed!'),
                      backgroundColor: Colors.green),
                );
              },
              child: const Text('Remove', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  /// Builds an ImageProvider for the CircleAvatar, prioritizing the newly selected file.
  ImageProvider _getProfileImage() {
    if (_profileImageFile != null) {
      return FileImage(_profileImageFile!);
    }
    if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      return NetworkImage(_profileImageUrl!);
    }
    return const AssetImage('assets/placeholder.png'); // Fallback placeholder
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile',
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // Show a loader while data is being fetched
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image Section
                  Center(child: _buildProfileImage()),
                  const SizedBox(height: 40),

                  // Form Fields
                  _buildTextField(
                      label: 'Full Name', controller: _fullNameController),
                  const SizedBox(height: 20),
                  _buildTextField(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 20),
                  _buildTextField(
                      label: 'Phone Number',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 20),
                  _buildTextField(
                      label: 'Address',
                      controller: _addressController,
                      maxLines: 3),
                  const SizedBox(height: 40),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28)),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Save',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  /// Builds the profile image widget with an edit icon.
  Widget _buildProfileImage() {
    return Stack(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border:
                Border.all(color: AppColors.primary.withOpacity(0.5), width: 3),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3))
            ],
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: _getProfileImage(),
            onBackgroundImageError: (exception, stackTrace) {
              // Handle network image load errors gracefully
            },
            child: (_profileImageFile == null &&
                    (_profileImageUrl == null || _profileImageUrl!.isEmpty))
                ? Icon(Icons.person, size: 50, color: Colors.grey.shade400)
                : null,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _showImageSourceOptions,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child:
                  const Icon(Icons.camera_alt, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a UI element for an image source option (e.g., Camera, Gallery).
  Widget _buildImageSourceOption(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
                color: AppColors.lightBlue, shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primary, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  /// A helper widget to build consistently styled text fields.
  Widget _buildTextField(
      {required String label,
      required TextEditingController controller,
      TextInputType keyboardType = TextInputType.text,
      int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
