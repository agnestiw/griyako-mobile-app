import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:griyako/widgets/detail_property.dart';
import '../utils/app_colors.dart';
import 'package:http/http.dart' as http;

class NearYouSection extends StatefulWidget {
  const NearYouSection({Key? key}) : super(key: key);

  @override
  State<NearYouSection> createState() => _NearYouSectionState();
}

class _NearYouSectionState extends State<NearYouSection> {
  late Future<List<dynamic>> futureProperties;

  @override
  void initState() {
    super.initState();
    futureProperties = fetchProperties();
  }

  Future<List<dynamic>> fetchProperties() async {
    final response = await http.get(
      Uri.parse(
          'http://127.0.0.1:8000/api/properties/fetch/'), // Your API endpoint
    );

    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('Decoded data: $data');
      return data;
    } else {
      print('Failed to load properties');
      throw Exception('Failed to load properties');
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: futureProperties,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Loading indicator while fetching data
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Display error message
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // If no data found
          return const Center(child: Text('No properties found'));
        } else {
          final properties = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailProperty(property: property),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(20)),
                            child: property['image_url'] != null &&
                                    property['image_url'].isNotEmpty
                                ? Image.network(
                                    property['image_url'], // <-- Corrected k   ey
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Image.asset(
                                    'assets/apart1.jpg',
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: AppColors.accent,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    property['rating']?.toString() ?? '0.0',
                                    style: const TextStyle(
                                      color: AppColors.secondary,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                property['property_type'] ?? 'Property',
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              property['title'] ?? 'No Title',
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: AppColors.secondary,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    property['address'] ?? 'No Address',
                                    style: const TextStyle(
                                      color: AppColors.secondary,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }
}
