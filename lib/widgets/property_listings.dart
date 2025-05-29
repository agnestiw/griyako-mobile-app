import 'package:flutter/material.dart';
import 'property_card.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

class PropertyListings extends StatefulWidget {
  const PropertyListings({Key? key}) : super(key: key);

  @override
  _PropertyListingsState createState() => _PropertyListingsState();
}

class _PropertyListingsState extends State<PropertyListings> {
  late Future<List<Map<String, dynamic>>> futureProperties;

  Future<List<Map<String, dynamic>>> fetchProperties() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/properties/fetch/'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Gagal memuat properti');
    }
  }

  @override
  void initState() {
    super.initState();
    futureProperties = fetchProperties();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: futureProperties,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Text('Terjadi kesalahan: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text('Tidak ada properti tersedia');
        }

        final properties = snapshot.data!;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: properties.map((property) {
              return Container(
                width: 300,
                margin: const EdgeInsets.only(right: 16),
                child: PropertyCard(
                  image: property['photo'] ?? 'assets/logo_griyako.png',
                  type: property['property_type'] ?? '',
                  size: property['square_meters'] ?? '',
                  title: property['title'] ?? '',
                  price: 'Rp ?', // Tambahkan kolom harga kalau ada
                  bedrooms: '${property['bedrooms'] ?? ''} KT',
                  bathrooms: '${property['bathrooms'] ?? ''} KM',
                  location: property['address'] ?? '',
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
