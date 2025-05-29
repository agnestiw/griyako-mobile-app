import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/location_header.dart';
import '../widgets/search_bar.dart';
import '../widgets/category_tabs.dart';
import '../widgets/property_listings.dart';
import '../widgets/top_locations_section.dart';
import '../widgets/near_you_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Set to 0 for home tab

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
              children: const [
                SizedBox(height: 8),
                LocationHeader(),
                SizedBox(height: 16),
                CustomSearchBar(),
                SizedBox(height: 24),
                CategoryTabs(),
                SizedBox(height: 16),
                PropertyListings(),
                SizedBox(height: 24),
                TopLocationsSection(),
                SizedBox(height: 24),
                NearYouSection(),
                SizedBox(height: 24),
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
}