import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/favorite_item.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _selectedIndex = 3; // Set to 3 for favorites tab
  bool _selectAll = false;

  void onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Favourite',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildSelectAllRow(),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: const [
                    FavoriteItem(
                      title: 'Benson Apartment',
                      location: 'Jl. Mayjend Jonosewojo, Surabaya',
                      bedrooms: '3',
                      bathrooms: '2',
                      price: 'Rp 3,2 JT/bulan',
                      imageUrl: 'assets/hotel2.jpg',
                      rating: '4.9',
                      type: 'Apartment',
                    ),
                    SizedBox(height: 16),
                    FavoriteItem(
                      title: 'DoubleTree',
                      location: 'Jl. Tunjungan, Genteng, Surabaya',
                      bedrooms: '2',
                      bathrooms: '2',
                      price: 'Rp 2,3 JT/malam',
                      imageUrl: 'assets/hotel1.jpg',
                      rating: '4.88',
                      type: 'Hotel',
                    ),
                    SizedBox(height: 16),
                    FavoriteItem(
                      title: 'The GreenLake',
                      location: 'Jl. Lidah Kulon, Lakarsantri, Surabaya',
                      bedrooms: '4',
                      bathrooms: '2',
                      price: 'Rp 4,5 M',
                      imageUrl: 'assets/home3.jpg',
                      squareMeters: '163 m² - 204 m²',
                      type: 'Rumah Baru',
                    ),
                    SizedBox(height: 16),
                    FavoriteItem(
                      title: 'Royal House',
                      location: 'Jl. Lontar, Sambikerep, Surabaya',
                      bedrooms: '7',
                      bathrooms: '5',
                      price: 'Rp 12,6 M',
                      imageUrl: 'assets/home4.png',
                      squareMeters: '200 m² - 420 m²',
                      type: 'Rumah Second',
                    ),
                    SizedBox(height: 16),
                    FavoriteItem(
                      title: 'Kos Bu Warna',
                      location: '',
                      bedrooms: '',
                      bathrooms: '',
                      price: '',
                      imageUrl: 'assets/kos1.jpg',
                      squareMeters: '15 m²',
                      type: 'Kos Putri',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: onNavItemTapped,
      ),
    );
  }

  Widget _buildSelectAllRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: _selectAll,
                onChanged: (value) {
                  setState(() {
                    _selectAll = value ?? false;
                  });
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                activeColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Select all',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(
            Icons.delete_outline,
            color: AppColors.primary,
            size: 24,
          ),
          onPressed: () {},
        ),
      ],
    );
  }
}