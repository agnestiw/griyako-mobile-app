import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/transaction_status_item.dart';
import '../widgets/profile_menu_item.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // This future will now hold both the name and the phone number.
  late Future<Map<String, String>> _userData;

  @override
  void initState() {
    super.initState();
    // Initialize the future in initState to prevent it from being called
    // on every rebuild.
    _userData = fetchUserData();
  }

  // Updated function to fetch both user name and phone number.
  // It now returns a Map.
  Future<Map<String, String>> fetchUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Make sure you have a token before making the request.
    if (token == null) {
      throw Exception('Authentication token not found.');
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
      // IMPORTANT: Adjust the keys ('name', 'phone') to match the actual keys
      // in your API response.
      return {
        'name': data['name'] ?? 'No Name',
        'phone': data['phone'] ?? 'No Phone Number', // e.g., data['no_telp']
      };
    } else {
      // Handle different error status codes if needed.
      throw Exception('Failed to load user data');
    }
  }

  Future<void> updateProfile({
    required String name,
    required String email,
    required String
        phone, // Pastikan Anda mendapatkan value dari text controller
    required String address,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Buat body untuk request
    final body = {
      'name': name,
      'email': email,
      'phone': phone, // Pastikan key di sini adalah 'phone'
      'address': address,
    };

    // =========================================================
    // ==> TAMBAHKAN PRINT DI SINI UNTUK DEBUGGING <==
    print('Data yang akan dikirim ke server: ${jsonEncode(body)}');
    // =========================================================

    final response = await http.post(
      // atau http.put
      Uri.parse(
          'http://127.0.0.1:8000/api/user/update'), // Pastikan URL update Anda benar
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    // Periksa juga response dari server
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      // Berhasil
    } else {
      // Gagal
    }
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    // Show a confirmation dialog before logging out.
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (confirmLogout != true) {
      return;
    }

    // Continue with logout if confirmed
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        await prefs.remove('token');
        if (mounted) {
          // Navigate to the login page and remove all previous routes.
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        }
      } else {
        final data = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Logout failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  int _selectedIndex = 4; // Set to 4 for profile tab

  void onNavItemTapped(int index) {
    // This function will handle navigation from the bottom bar.
    // You would typically use a Navigator to push the new screen.
    // For this example, we just update the state.
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      // Example of navigation logic
      switch (index) {
        case 0:
          // Navigator.pushReplacementNamed(context, '/home');
          break;
        case 1:
          // Navigator.pushReplacementNamed(context, '/marketplace');
          break;
        case 2:
          // Navigator.pushReplacementNamed(context, '/favorites');
          break;
        case 3:
          // Navigator.pushReplacementNamed(context, '/messages');
          break;
        case 4:
          // Already on profile screen
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                const Text(
                  'Profile',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildProfileHeader(),
                const SizedBox(height: 32),
                _buildAccountSection(),
                const SizedBox(height: 32),
                _buildSettingSection(),
                const SizedBox(height: 32),
                _buildPromoSection(),
                const SizedBox(height: 32),
                _buildAboutSection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: onNavItemTapped,
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            image: const DecorationImage(
              image: AssetImage('assets/profile.jpg'),
              fit: BoxFit.cover,
            ),
            border: Border.all(
              color: Colors.white,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        // The FutureBuilder now uses the _userData future initialized in initState.
        FutureBuilder<Map<String, String>>(
          future: _userData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(color: AppColors.primary);
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.hasData) {
              // Data is available, build the column with user info.
              final userData = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userData['name'] ?? 'Guest', // Display name from map
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userData['phone'] ?? 'N/A', // Display phone from map
                    style: const TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            } else {
              // Handle the case where there is no data.
              return const Text('No user data found.');
            }
          },
        )
      ],
    );
  }

  Widget _buildAccountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account & Information',
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ProfileMenuItem(
          icon: Icons.person_outline,
          title: 'Edit Profile',
          onTap: () {
            Navigator.pushNamed(context, '/edit_profile');
          },
        ),
        const SizedBox(height: 16),
        ProfileMenuItem(
          icon: Icons.home_outlined,
          title: 'My Property',
          onTap: () {
            Navigator.pushNamed(context, '/marketplace');
          },
        ),
      ],
    );
  }

  Widget _buildSettingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Setting',
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ProfileMenuItem(
          icon: Icons.notifications_none,
          title: 'Notification',
          onTap: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
        const SizedBox(height: 16),
        ProfileMenuItem(
          icon: Icons.language,
          title: 'Language',
          onTap: () {
            Navigator.pushNamed(context, '/languages');
          },
        ),
      ],
    );
  }

  Widget _buildPromoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Promo',
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ProfileMenuItem(
          icon: Icons.discount_outlined,
          title: 'My Voucher',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About',
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ProfileMenuItem(
          icon: Icons.privacy_tip,
          title: 'Privacy Policy',
          onTap: () {},
        ),
        const SizedBox(height: 16),
        ProfileMenuItem(
          icon: Icons.verified_user,
          title: 'Terms & Condition',
          onTap: () {},
        ),
        const SizedBox(height: 16),
        ProfileMenuItem(
          icon: Icons.phone,
          title: 'Contact Us',
          onTap: () {},
        ),
        const SizedBox(height: 16),
        ProfileMenuItem(
          icon: Icons.logout,
          title: 'Logout',
          iconColor: AppColors.danger,
          textColor: AppColors.danger,
          onTap: () => logout(context),
        )
      ],
    );
  }
}
