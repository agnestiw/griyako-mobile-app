import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// --- Mock AppColors for demonstration ---
// Replace with your actual AppColors file.
class AppColors {
  static const Color primary = Colors.blue;
  static const Color secondary = Colors.black;
  static const Color border = Colors.grey;
  static const Color grey = Colors.grey;
}

// --- Data model for a property ---
// This defines the structure for the property data we expect from the API.
class Property {
  final String? title;
  final String? address;

  Property({this.title, this.address});

  // Factory constructor to create a Property from a JSON object.
  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      title: json['title'],
      address: json['address'],
    );
  }
}

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({Key? key}) : super(key: key);

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Property> _results = [];
  bool _isLoading = false;
  String _message = 'Search for properties by name or location';
  Timer? _debounce;
  int _selectedIndex = 1; // Set to 1 for search tab

  // --- API Call ---
  // Fetches properties from the server based on the search query.
  Future<void> _searchProperties(String query) async {
    // If the query is empty, reset the state.
    if (query.isEmpty) {
      setState(() {
        _isLoading = false;
        _results = [];
        _message = 'Search for properties by name or location';
      });
      return;
    }

    // Set loading state to true to show a progress indicator.
    setState(() {
      _isLoading = true;
    });

    try {
      // Replace with your actual API endpoint.
      final url =
          Uri.parse('http://127.0.0.1:8000/api/properties/search?q=$query');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          // Map the JSON data to a list of Property objects.
          _results = data.map((json) => Property.fromJson(json)).toList();
          _message = _results.isEmpty ? 'No results found.' : '';
        });
      } else {
        // Handle server errors.
        setState(() {
          _message = 'Failed to load data. Server error.';
          _results = [];
        });
      }
    } catch (e) {
      // Handle connection errors.
      print('Connection error: $e');
      setState(() {
        _message = 'Failed to connect to the server.';
        _results = [];
      });
    } finally {
      // Always set loading to false after the operation.
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      // Debouncing logic to prevent excessive API calls while typing.
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        _searchProperties(_searchController.text.trim());
      });
    });
  }

  @override
  void dispose() {
    // Clean up the controller and timer when the widget is disposed.
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Add navigation logic here if needed, e.g., using a PageController.
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
                'Search',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              // --- Functional Search Bar ---
              _buildFunctionalSearchBar(),
              const SizedBox(height: 24),
              // --- Dynamic Results Area ---
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _results.isNotEmpty
                        ? ListView.builder(
                            itemCount: _results.length,
                            itemBuilder: (context, index) {
                              final property = _results[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 16.0),
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.home_work_outlined,
                                    color: AppColors.primary,
                                  ),
                                  title: Text(
                                    property.title ?? 'No Title Provided',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    property.address ?? 'No Address Provided',
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal: 16.0,
                                  ),
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text(
                              _message,
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ),
              ),
            ],
          ),
        ),
      ),
      // --- Bottom Navigation Bar ---
      // NOTE: The 'BottomNavBar' widget is not defined in this file.
      // You will need to import or create it for this to work.
      // bottomNavigationBar: BottomNavBar(
      //   selectedIndex: _selectedIndex,
      //   onItemTapped: onNavItemTapped,
      // ),
    );
  }

  // --- New Functional Search Bar Widget ---
  Widget _buildFunctionalSearchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Search by Address, City, or Property',
              prefixIcon: const Icon(Icons.search, color: AppColors.secondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide:
                    BorderSide(color: AppColors.border.withOpacity(0.5)),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Icon(
              Icons.tune,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
