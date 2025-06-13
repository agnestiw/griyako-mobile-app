import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:griyako/screens/detail_property_screen.dart';
import 'package:griyako/widgets/bottom_nav_bar.dart';
import 'package:http/http.dart' as http;

// --- Mock AppColors for demonstration ---
class AppColors {
  static const Color primary = Colors.blue; // Changed for better visibility
  static const Color border = Colors.grey;
}

// --- Data model for a property ---
class Property {
  final String? title;
  final String? address;

  Property({this.title, this.address});

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      title: json['title'],
      address: json['address'],
    );
  }
}

// --- Detail Screen for a Single Property ---


class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  // --- CHANGE 1: Use a List of Maps instead of a custom Property class ---
  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;
  String _message = 'Search for properties by name or location';
  Timer? _debounce;

    // Tracks the selected index for the BottomNavBar.
  int _selectedIndex = 1;

  Future<void> _searchProperties(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isLoading = false;
        _results = [];
        _message = 'Search for properties by name or location';
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final url =
          Uri.parse('http://127.0.0.1:8000/api/properties/search?q=$query');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          // --- CHANGE 2: Directly cast the API data to the results list ---
          // This ensures all fields (id, price, etc.) are preserved for the detail screen.
          _results = List<Map<String, dynamic>>.from(data);
          _message = _results.isEmpty ? 'No results found.' : '';
        });
      } else {
        setState(() {
          _message = 'Failed to load data. Server error.';
          _results = [];
        });
      }
    } catch (e) {
      print('Connection error: $e');
      setState(() {
        _message = 'Failed to connect to the server.';
        _results = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        _searchProperties(_searchController.text.trim());
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Properties'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search by name or location',
                prefixIcon: const Icon(Icons.search),
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
            const SizedBox(height: 24),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isNotEmpty
                      ? ListView.builder(
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            // The 'property' variable is now a Map
                            final property = _results[index];
                            return Hero(
                              // --- CHANGE 3: Added Hero widget to match DetailScreen ---
                              // This assumes your search result includes an 'id'.
                              tag: 'property_image_${property['id']}',
                              child: Card(
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
                                  // --- CHANGE 4: Access data using map keys ---
                                  title: Text(
                                    property['title'] ?? 'No Title Provided',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    property['address'] ??
                                        'No Address Provided',
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                    horizontal: 16.0,
                                  ),
                                  onTap: () {
                                    // Navigation now passes the complete map
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => DetailPropertyScreen(
                                            property: property),
                                      ),
                                    );
                                  },
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
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }
}