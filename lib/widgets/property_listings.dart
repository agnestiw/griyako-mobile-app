import 'package:flutter/material.dart';
import 'package:griyako/screens/detail_property_screen.dart';
import 'package:intl/intl.dart'; // For formatting the price
import 'dart:convert';
import 'package:http/http.dart' as http;

// Import the PropertyCard and Detail Screen
import 'property_card.dart'; 

// --- Configuration ---
// For Android emulator, use this to connect to your local machine's server
const String API_BASE_URL = 'http://127.0.0.1:8000/api';
// For iOS simulator or a physical device on the same Wi-Fi, use your machine's IP address:
// const String API_BASE_URL = 'http://192.168.1.10:8000/api'; 
const String FALLBACK_ASSET_PATH = 'assets/logo_griyako.png'; // Make sure this asset exists


class PropertyListings extends StatefulWidget {
  const PropertyListings({Key? key}) : super(key: key);

  @override
  State<PropertyListings> createState() => _PropertyListingsState();
}

class _PropertyListingsState extends State<PropertyListings> {
  // A Future to hold the state of our network request
  late Future<List<Map<String, dynamic>>> _futureProperties;

  @override
  void initState() {
    super.initState();
    // Fetch the data when the widget is first created
    _futureProperties = fetchProperties();
  }

  /// Fetches property data from the Laravel API.
  Future<List<Map<String, dynamic>>> fetchProperties() async {
    try {
      final response = await http.get(
        Uri.parse('$API_BASE_URL/properties/fetch'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // If the server returns a 200 OK response, then parse the JSON.
        final List<dynamic> data = json.decode(response.body);
        // Ensure all items in the list are of the correct type
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception with a clear message.
        throw Exception('Failed to load properties. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      // Catch any other errors, like network issues, and re-throw
      throw Exception('Failed to fetch properties: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _futureProperties,
      builder: (context, snapshot) {
        // 1. Handle the Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // 2. Handle the Error State
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'An error occurred: ${snapshot.error}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        // 3. Handle the "No Data" State
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No properties are currently available.'),
          );
        }

        // 4. Handle the Success State (Data is available)
        final properties = snapshot.data!;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(16.0), // Add some padding around the list
          child: Row(
            children: properties.map((property) {
              // --- Safely extract and process data for each card ---

              final String? imageUrl = property['image_url'] as String?;
              final bool isNetworkImage = imageUrl != null && imageUrl.isNotEmpty;
              final String heroTag = 'property_image_${property['id']}'; // Tag unik untuk animasi Hero

              // Safely format the price
              String formattedPrice = 'Price not set';
              if (property['harga'] != null) {
                try {
                  final priceValue = double.parse(property['harga'].toString());
                  formattedPrice = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(priceValue);
                } catch (e) {
                  // If parsing fails, use the raw value as a fallback
                  formattedPrice = property['harga'].toString();
                }
              }

              // ==========================================================
              // === PERUBAHAN UTAMA: Tambahkan GestureDetector di sini ===
              // ==========================================================
              return GestureDetector(
                onTap: () {
                  // Navigasi ke halaman detail saat kartu di-tap
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPropertyScreen(
                        // Kirim semua data properti ke layar detail
                        property: property, 
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 300, // Define a width for each card in the horizontal list
                  margin: const EdgeInsets.only(right: 16), // Space between cards
                  child: Hero( // Tambahkan Hero untuk animasi gambar
                    tag: heroTag,
                    child: PropertyCard(
                      // Use the '??' operator to provide default values and prevent null errors
                      imageUrl: imageUrl ?? FALLBACK_ASSET_PATH,
                      isNetworkImage: isNetworkImage,
                      title: property['title'] ?? 'No Title',
                      price: formattedPrice,
                      type: property['property_type'] ?? 'N/A',
                      size: property['square_meters'] != null ? '${property['square_meters']} m²' : 'N/A',
                      bedrooms: '${property['bedrooms'] ?? '?'} KT',
                      bathrooms: '${property['bathrooms'] ?? '?'} KM',
                      location: property['address'] ?? 'No Address Provided',
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
