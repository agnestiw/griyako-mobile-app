import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http; // <-- 1. Import http package
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart'; // <-- 2. Import for jsonEncode

// --- CONVERTED TO STATEFULWIDGET ---
class DetailPropertyScreen extends StatefulWidget {
  // Properti untuk menampung data dari item yang di-tap
  final Map<String, dynamic> property;

  const DetailPropertyScreen({Key? key, required this.property})
      : super(key: key);

  @override
  State<DetailPropertyScreen> createState() => _DetailPropertyScreenState();
}

class _DetailPropertyScreenState extends State<DetailPropertyScreen> {
  // --- STATE MANAGEMENT FOR FAVORITE ---
  late bool _isFavorited;
  late int _propertyId;

  @override
  void initState() {
    super.initState();
    // Initialize state from the property data passed to the widget.
    // **IMPORTANT**: You must pass 'is_favorited' (boolean) and 'id' (int) in your property map.
    _isFavorited = widget.property['is_favorited'] ?? false;
    _propertyId = widget.property['id'];
  }

  // --- API CALL FUNCTION TO TOGGLE FAVORITE ---
  Future<void> _toggleFavorite() async {
    // **TODO**: Replace with your actual API URL and Authentication logic
    const String apiUrl = 'http://127.0.0.1:8000/api/favorites/store';
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('token');

    if (authToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Anda belum login.')));
      return;
    }

    // Optimistically update the UI for instant feedback
    setState(() {
      _isFavorited = !_isFavorited;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'property_models_id': _propertyId,
        }),
      );

      // --- LANGKAH 2: TAMBAHKAN LOGIKA DEBUGGING DI SINI ---
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        // Update state with the actual status from the server to ensure consistency
        setState(() {
          // Pastikan key 'status' ada di dalam 'data'
          if (responseData['data'] != null &&
              responseData['data']['status'] != null) {
            _isFavorited = responseData['data']['status'];
          }
        });

        // Show feedback to the user
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message']),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // JIKA STATUS BUKAN 200, CETAK INFO ERROR UNTUK DEBUG
        // Ini adalah bagian terpenting untuk debugging Anda
        if (kDebugMode) {
          print('Gagal! Kode Status: ${response.statusCode}');
          print('Pesan Error dari Server: ${response.body}');
        }

        // Revert state karena gagal
        setState(() {
          _isFavorited = !_isFavorited;
        });

        // Berikan pesan yang lebih spesifik jika memungkinkan
        String errorMessage = 'Gagal memperbarui favorit.';
        if (response.statusCode == 401) {
          errorMessage = 'Sesi Anda telah berakhir. Silakan login kembali.';
        } else if (response.statusCode == 422) {
          errorMessage = 'Data yang dikirim tidak valid. Cek log untuk detail.';
        } else if (response.statusCode == 404) {
          errorMessage = 'Endpoint API tidak ditemukan. Cek URL.';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    } catch (e) {
      // JIKA TERJADI ERROR JARINGAN (misal, salah IP, tidak ada internet)
      // Cetak error-nya untuk debug
      if (kDebugMode) {
        print('Terjadi kesalahan jaringan: $e');
      }

      // Revert state karena gagal
      setState(() {
        _isFavorited = !_isFavorited;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat terhubung ke server.')),
        );
      }
    }
  }

  // Helper untuk membuat baris ikon dan teks yang dapat digunakan kembali
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blueGrey, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // --- Data extraction is now inside the build method of the State ---
    final property = widget.property; // Access property via widget.property
    final String? imageUrl = property['image_url'] as String?;
    final bool isNetworkImage = imageUrl != null && imageUrl.isNotEmpty;
    const String fallbackAssetPath = 'assets/logo_griyako.png';

    String formattedPrice = 'Harga tidak tersedia';
    if (property['harga'] != null) {
      try {
        final priceValue = double.parse(property['harga'].toString());
        formattedPrice = NumberFormat.currency(
                locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
            .format(priceValue);
      } catch (e) {
        formattedPrice = property['harga'].toString();
      }
    }

    final String title = property['title'] ?? 'Tanpa Judul';
    final String address = property['address'] ?? 'Alamat tidak tersedia';
    final String propertyType = property['property_type'] ?? 'N/A';
    final String size = property['square_meters'] != null
        ? '${property['square_meters']} m²'
        : 'N/A';
    final String bedrooms = property['bedrooms']?.toString() ?? '?';
    final String bathrooms = property['bathrooms']?.toString() ?? '?';
    final String description =
        property['description'] ?? 'Tidak ada deskripsi.';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(
            color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        // --- ADDED ACTIONS FOR THE FAVORITE BUTTON ---
        actions: [
          IconButton(
            onPressed: _toggleFavorite, // Call the API function on press
            icon: Icon(
              _isFavorited
                  ? Icons.favorite
                  : Icons.favorite_border, // Conditional icon
              color: Colors.red,
              size: 28,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'property_image_${property['id']}',
              child: isNetworkImage
                  ? Image.network(
                      imageUrl,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        fallbackAssetPath,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(
                      fallbackAssetPath,
                      width: double.infinity,
                      height: 250,
                      fit: BoxFit.cover,
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formattedPrice,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  _buildDetailRow(
                      Icons.location_on_outlined, 'Alamat', address),
                  _buildDetailRow(
                      Icons.home_work_outlined, 'Tipe Properti', propertyType),
                  _buildDetailRow(
                      Icons.square_foot_outlined, 'Luas Bangunan', size),
                  _buildDetailRow(
                      Icons.king_bed_outlined, 'Kamar Tidur', '$bedrooms KT'),
                  _buildDetailRow(
                      Icons.bathtub_outlined, 'Kamar Mandi', '$bathrooms KM'),
                  const SizedBox(height: 16),
                  const Divider(),
                  const Text(
                    'Deskripsi',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          onPressed: () {
            // Logika untuk menghubungi penjual (misal: membuka WhatsApp)
          },
          icon: const Icon(Icons.call, color: Colors.white),
          label: const Text('Hubungi Penjual',
              style: TextStyle(color: Colors.white)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 15),
            textStyle:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
