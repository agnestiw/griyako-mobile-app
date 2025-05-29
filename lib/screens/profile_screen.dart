import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/transaction_status_item.dart';
import '../widgets/profile_menu_item.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Hana Alfira Prabowo',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              '089265632514',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
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
          onTap: () {},
        )
      ],
    );
  }
}