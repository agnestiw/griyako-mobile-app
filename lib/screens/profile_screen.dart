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
  Future<String> fetchUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/user'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['name']; // or data['nama'] depending on your API
    } else {
      throw Exception('Failed to load user');
    }
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/logout'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      await prefs.remove('token');

      // Navigasi ke halaman login (ganti sesuai nama halamanmu)
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else {
      final data = jsonDecode(response.body);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(data['message'] ?? 'Logout gagal')),
      );
    }
  }

  int _selectedIndex = 4; // Set to 4 for profile tab

  void onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
                _buildTransactionSection(),
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
        FutureBuilder<String>(
          future: fetchUserName(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // or Skeleton
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    snapshot.data ?? '',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '089265632514', // You can make this dynamic too
                    style: TextStyle(
                      color: AppColors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              );
            }
          },
        )
      ],
    );
  }

  Widget _buildTransactionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'My Transaction',
          style: TextStyle(
            color: AppColors.secondary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: const [
            TransactionStatusItem(
              icon: Icons.access_time,
              title: 'Booking',
              color: AppColors.primary,
            ),
            TransactionStatusItem(
              icon: Icons.check_circle,
              title: 'Completed',
              color: AppColors.primary,
            ),
            TransactionStatusItem(
              icon: Icons.cancel,
              title: 'Cancelled',
              color: AppColors.primary,
            ),
          ],
        ),
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
          onTap: () {},
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
          onTap: () {},
        ),
        const SizedBox(height: 16),
        ProfileMenuItem(
          icon: Icons.language,
          title: 'Language',
          onTap: () {},
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
