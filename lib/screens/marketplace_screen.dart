import 'package:flutter/material.dart';
import 'package:griyako/screens/edit_property_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../utils/app_colors.dart'; // Ensure this path is correct
import '../widgets/bottom_nav_bar.dart'; // Ensure this path is correct
import '../widgets/marketplace_item.dart'; // Ensure this path is correct

// For Android emulator, use this to connect to your local machine's server
const String API_BASE_URL = 'http://127.0.0.1:8000/api';
// For iOS simulator or a physical device on the same Wi-Fi, use your machine's IP address:
// const String API_BASE_URL = 'http://192.168.1.10:8000/api';

const String FALLBACK_ASSET_PATH =
    'assets/logo_griyako.png'; // Ensure this asset is in pubspec.yaml

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  int _selectedIndex = 2; // Corresponds to the marketplace tab
  late Future<List<Map<String, dynamic>>> _propertiesFuture;

  Future<void> deleteProperty(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse('$API_BASE_URL/properties/$id');

    print('Calling DELETE $url');
    print('Using token: $token');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print('Delete response: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Properti berhasil dihapus')),
        );
        _refreshProperties();
      } else {
        print('Delete failed: ${response.statusCode} - ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus properti (${response.statusCode})')),
        );
      }
    } catch (e) {
      print('Error deleting property: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Terjadi kesalahan saat menghapus properti')),
      );
    }
  }


  @override
  void initState() {
    super.initState();
    _propertiesFuture = fetchProperties();
  }

  void onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Here you would typically use a Navigator to switch screens
      // e.g., if (index == 0) Navigator.pushReplacementNamed(context, '/home');
    });
  }

  // Fetches the ID of the currently authenticated user
  Future<int> getAuthenticatedUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Authentication token not found.');
    }

    final response = await http.get(
      Uri.parse('$API_BASE_URL/user'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['id'] != null) {
        return data['id'];
      } else {
        throw Exception('User ID not found in API response.');
      }
    } else {
      throw Exception(
          'Failed to fetch user ID. Status: ${response.statusCode}');
    }
  }

  // Fetches the list of properties from the API
  Future<List<Map<String, dynamic>>> fetchProperties() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Authentication token not found.');
      }

      // Step 1: Get authenticated user ID
      final userResponse = await http.get(
        Uri.parse('$API_BASE_URL/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (userResponse.statusCode != 200) {
        throw Exception('Failed to fetch user data');
      }

      final userData = json.decode(userResponse.body);
      final int userId = userData['id'];

      // Step 2: Fetch all properties
      final propertyResponse = await http.get(
        Uri.parse('$API_BASE_URL/properties/fetch'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (propertyResponse.statusCode != 200) {
        throw Exception('Failed to load properties');
      }

      final List data = json.decode(propertyResponse.body);

      // Step 3: Filter properties by user_id
      final filtered = data
          .where((property) =>
              property['user_id'] != null && property['user_id'] == userId)
          .toList()
          .cast<Map<String, dynamic>>();

      return filtered;
    } catch (e) {
      print('Error in fetchProperties: $e');
      rethrow;
    }
  }


  // Refreshes the properties list
  Future<void> _refreshProperties() async {
    setState(() {
      _propertiesFuture = fetchProperties();
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
                'Marketplace',
                style: TextStyle(
                  // color: AppColors.secondary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 24),
              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: _propertiesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('An error occurred: ${snapshot.error}'),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _refreshProperties,
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.home_outlined,
                                size: 80, color: Colors.grey),
                            const SizedBox(height: 20),
                            const Text(
                              'No properties found.',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _refreshProperties,
                              child: const Text('Refresh'),
                            ),
                          ],
                        ),
                      );
                    }

                    final properties = snapshot.data!;
                    return RefreshIndicator(
                      onRefresh: _refreshProperties,
                      child: ListView.separated(
                        itemCount: properties.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final property = properties[index];

                          // 1. Get the full URL from the 'image_url' field provided by your Laravel API.
                          final String? imageUrl =
                              property['image_url'] as String?;

                          // 2. Determine if it's a network image. This boolean is the key.
                          final bool isNetworkImage =
                              imageUrl != null && imageUrl.isNotEmpty;

                          // -- FOR DEBUGGING --
                          // You can add this print statement to see what's happening for each item.
                          // Check your console (Run tab in VS Code / Logcat in Android Studio) for the output.
                          print(
                              "Building item '${property['title']}': isNetworkImage = $isNetworkImage, URL = $imageUrl");
                          // -----------------

                          // 3. Create the MarketplaceItem widget.
                          return Stack(
                            children: [
                              // Card properti
                              MarketplaceItem(
                                title: property['title'] ?? 'No Title',
                                price: property['harga']?.toString() ?? 'Rp -',
                                imageUrl: imageUrl ?? FALLBACK_ASSET_PATH,
                                isNetworkImage: isNetworkImage,
                              ),

                              // Tombol titik 3 vertikal di kanan tengah
                              Positioned(
                                right: 8,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_horiz), // ikon titik 3 vertikal
                                      onSelected: (value) {
                                        if (value == 'edit') {
                                            Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => EditMarketplaceScreen(property: property),
                                            ),
                                          ).then((updated) {
                                            if (updated == true) _refreshProperties();
                                          });
                                        } else if (value == 'delete') {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: const Text('Konfirmasi'),
                                                content: const Text('Apakah kamu yakin ingin menghapus properti ini?'),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator.pop(context),
                                                    child: const Text('Batal'),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      deleteProperty(property['id']); // 👉 Panggil delete
                                                    },
                                                    child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result =
              await Navigator.pushNamed(context, '/form_marketplace');
          if (result == true) {
            _refreshProperties();
          }
        },
        // backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Create Offer',
          style: TextStyle(color: Colors.white),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: onNavItemTapped,
      ),
    );
  }

  // A placeholder for your search bar widget
  Widget _buildSearchBar() {
    return Container(
        // Your search bar implementation
        );
  }
}
