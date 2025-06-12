import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemTapped,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(context, 0, Icons.home_outlined),
              _buildNavItem(context, 1, Icons.search),
              _buildNavItem(context, 2, Icons.storefront_outlined),
              _buildNavItem(context, 3, Icons.favorite_border),
              _buildNavItem(context, 4, Icons.person_outline),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon) {
    return GestureDetector(
      onTap: () {
        onItemTapped(index);
        
        // Handle navigation based on index
        if (index == 0) {
          // Navigate to home screen
          if (ModalRoute.of(context)?.settings.name != '/') {
            Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
          }
        } else if (index == 1) {
          // Navigate to search results screen
          if (ModalRoute.of(context)?.settings.name != '/search_input') {
            Navigator.pushNamed(context, '/search_input');
          }
        } else if (index == 2) {
          // Navigate to marketplace screen
          if (ModalRoute.of(context)?.settings.name != '/marketplace') {
            Navigator.pushNamed(context, '/marketplace');
          }
        } else if (index == 3) {
          // Navigate to favorites screen
          if (ModalRoute.of(context)?.settings.name != '/favorites') {
            Navigator.pushNamed(context, '/favorites');
          }
        } else if (index == 4) {
          // Navigate to profile screen
          if (ModalRoute.of(context)?.settings.name != '/profile') {
            Navigator.pushNamed(context, '/profile');
          }
        }
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: selectedIndex == index ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Icon(
          index == 3 && selectedIndex == 3 ? Icons.favorite : icon,
          color: selectedIndex == index ? Colors.white : AppColors.secondary,
          size: 24,
        ),
      ),
    );
  }
}