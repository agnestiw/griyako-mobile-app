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
  Set<int> _selectedItemIds = {}; // To track IDs of selected items for deletion

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
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Authentication token not found.');
      return;
    }

    // UPDATED: Endpoint changed to /favorites
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
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        _showErrorSnackBar(
            'Failed to load favorites: ${response.reasonPhrase}');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar(
          'An error occurred. Make sure your local server is running and accessible.');
    }
  }

  /// Deletes the selected favorite items by sending an individual DELETE request for each.
  Future<void> _deleteSelectedFavorites() async {
    if (_selectedItemIds.isEmpty) return; // Nothing to delete

    // TODO: Replace with your actual auth token retrieval logic
    const String? authToken =
        '1|YOUR_BEARER_TOKEN'; // Replace with your actual token
    if (authToken == null) {
      _showErrorSnackBar('Authentication token not found.');
      return;
    }

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $authToken',
    };

    // Show a loading indicator on the delete button
    setState(() => _isLoading = true);

    // Create a list of futures, one for each delete request
    final List<Future<http.Response>> deleteFutures = _selectedItemIds
        .map((id) => http.delete(Uri.parse('${_baseUrl}favorites/$id'),
            headers: headers))
        .toList();

    try {
      // Execute all delete requests concurrently
      final responses = await Future.wait(deleteFutures);

      // Check if all requests were successful
      final allSucceeded = responses
          .every((res) => res.statusCode == 200 || res.statusCode == 204);

      if (allSucceeded) {
        // If all deletions succeeded, update the UI locally
        setState(() {
          _favoriteItems
              .removeWhere((item) => _selectedItemIds.contains(item['id']));
          _selectedItemIds.clear();
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Selected items deleted successfully.'),
          backgroundColor: Colors.green,
        ));
      } else {
        // If some failed, show a generic error and refetch the list to sync with the server's state
        _showErrorSnackBar('Some items could not be deleted. Refreshing list.');
        await _fetchFavorites(); // Re-fetch to get the source of truth
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred while deleting items.');
    } finally {
      // Hide loading indicator regardless of outcome
      setState(() => _isLoading = false);
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
              const SizedBox(height: 16),
              _buildSelectAllRow(), // The "Select All" and delete button row
              const SizedBox(height: 16),
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
    if (_isLoading && _favoriteItems.isEmpty) {
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
          final isSelected = _selectedItemIds.contains(item['id']);

          // Building each list item with a checkbox
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _selectedItemIds.add(item['id'] as int);
                        } else {
                          _selectedItemIds.remove(item['id'] as int);
                        }
                      });
                    },
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4)),
                    activeColor: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 8),
                // Using Expanded to ensure FavoriteItem takes remaining space
                Expanded(
                  child: FavoriteItem(
                    // Safely access data with fallback values
                    title: item['title'] ?? 'No Title',
                    location: item['address'] ?? 'No Address',
                    price: item['harga']?.toString() ?? 'N/A',
                    imageUrl: item['image_url'] ??
                        'assets/placeholder.png', // Ensure you have a placeholder
                    // Pass other properties as needed...
                    bedrooms: item['bedrooms']?.toString() ?? '?',
                    bathrooms: item['bathrooms']?.toString() ?? '?',
                    type: item['property_type'] ?? 'N/A',
                    rating: 'N/A', // Adjust if you have this data
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds the top row with "Select all" checkbox and delete button.
  Widget _buildSelectAllRow() {
    final bool allSelected = _favoriteItems.isNotEmpty &&
        _selectedItemIds.length == _favoriteItems.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: allSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedItemIds = _favoriteItems
                          .map((item) => item['id'] as int)
                          .toSet();
                    } else {
                      _selectedItemIds.clear();
                    }
                  });
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4)),
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
        _isLoading && _selectedItemIds.isNotEmpty
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.primary,
                ))
            : IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.primary,
                  size: 24,
                ),
                onPressed: _selectedItemIds.isEmpty
                    ? null
                    : _deleteSelectedFavorites, // Disable if nothing is selected
              ),
      ],
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
