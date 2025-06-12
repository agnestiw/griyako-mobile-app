import 'dart:convert';
import 'dart:io'; // Import for Platform class
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import '../widgets/favorite_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({Key? key}) : super(key: key);

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // State variables for managing screen data
  bool _isLoading = true;
  List<Map<String, dynamic>> _favoriteItems = [];

  int _selectedIndex = 3; // For BottomNavBar

  // --- API Configuration ---
  // Chooses the correct localhost address based on the platform (Android emulator vs. others)
  String get _baseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api/'; // Android emulator's address for host machine's localhost
    }
    return 'http://127.0.0.1:8000/api/'; // For iOS, web, and desktop
  }

  // --- Lifecycle & Data Fetching ---

  @override
  void initState() {
    super.initState();
    // Fetch data from the server when the screen is first loaded
    _fetchFavorites();
  }

  /// Fetches the list of favorite properties from the Laravel backend.
  Future<void> _fetchFavorites() async {
    // Ensure we aren't already fetching
    if (!_isLoading) setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Authentication token not found.');
      return;
    }

    final url = Uri.parse('${_baseUrl}favorites');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _favoriteItems = List<Map<String, dynamic>>.from(data);
        });
      } else {
        _showErrorSnackBar(
            'Failed to load favorites: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showErrorSnackBar(
          'An error occurred. Make sure your local server is running and accessible.');
    } finally {
      // Hide loading indicator regardless of outcome
      setState(() => _isLoading = false);
    }
  }

  /// Deletes a single favorite item and provides optimistic UI updates.
  Future<void> _deleteFavorite(int id) async {
    // Find the item and its index for potential restoration on failure
    final int itemIndex = _favoriteItems.indexWhere((item) => item['id'] == id);
    if (itemIndex == -1) return; // Item not found in the list

    final itemToRemove = _favoriteItems[itemIndex];

    // Optimistically remove the item from the UI
    setState(() {
      _favoriteItems.removeAt(itemIndex);
    });

    // Retrieve the auth token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      _showErrorSnackBar('Authentication token not found.');
      // Restore the item if auth fails before the request
      setState(() {
        _favoriteItems.insert(itemIndex, itemToRemove);
      });
      return;
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
    final url = Uri.parse('${_baseUrl}favorites/$id/delete');

    try {
      final response = await http.delete(url, headers: headers);

      // A successful deletion returns 200 or 204 (No Content)
      if (response.statusCode != 200 && response.statusCode != 204) {
        // If the delete failed on the server, restore the item and show an error
        _showErrorSnackBar('Failed to delete item. Please try again.');
        setState(() {
          _favoriteItems.insert(itemIndex, itemToRemove);
        });
      } else {
        // Show a success message only if the deletion was confirmed by the server
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Item deleted successfully.'),
            backgroundColor: Colors.green,
          ));
        }
      }
    } catch (e) {
      // Restore the item on any exception during the HTTP request
      _showErrorSnackBar('An error occurred while deleting the item.');
      setState(() {
        _favoriteItems.insert(itemIndex, itemToRemove);
      });
    }
  }

  // --- UI Building ---

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
              const SizedBox(height: 24), // Adjusted spacing
              Expanded(
                child: _buildContent(), // Dynamic content area
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  /// Builds the main content area based on the current state (loading, empty, or has data).
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_favoriteItems.isEmpty) {
      return const Center(
        child: Text(
          'You have no favorite items yet.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _fetchFavorites,
      child: ListView.builder(
        itemCount: _favoriteItems.length,
        itemBuilder: (context, index) {
          final item = _favoriteItems[index];

          // Building each list item with a delete button
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Using Expanded to ensure FavoriteItem takes available space
                Expanded(
                  child: FavoriteItem(
                    // Safely access data with fallback values
                    title: item['title'] ?? 'No Title',
                    location: item['address'] ?? 'No Address',
                    price: item['harga']?.toString() ?? 'N/A',
                    imageUrl: item['image_url'] ??
                        'assets/placeholder.png', // Ensure you have a placeholder
                    bedrooms: item['bedrooms']?.toString() ?? '?',
                    bathrooms: item['bathrooms']?.toString() ?? '?',
                    type: item['property_type'] ?? 'N/A',
                    rating: 'N/A', // Adjust if you have this data
                  ),
                ),
                const SizedBox(width: 8),
                // Delete button for each item
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  onPressed: () => _deleteFavorite(item['id'] as int),
                  tooltip: 'Delete Favorite',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Helper Methods ---

  /// Shows a red SnackBar with an error message.
  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
