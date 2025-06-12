import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// You can run this code directly in a Flutter app by setting
// DetailProperty(property: yourPropertyData) as the home of MaterialApp.

// Mock Data for demonstration purposes.
const Map<String, dynamic> mockPropertyData = {
  'title': 'Modern Luxury Villa',
  'address': '123 Ocean Drive, Sunny Isles, FL',
  'harga': '\$2,500,000',
  'bedrooms': 4,
  'bathrooms': 5,
  'area': 3200, // in sqft
  'description':
      'A stunning and spacious modern villa with breathtaking ocean views. This property features a private pool, state-of-the-art kitchen, and a beautiful open-concept living area. Perfect for families or as a high-end vacation rental.',
  'image_url':
      'https://images.unsplash.com/photo-1580587771525-78b9dba3b914?q=80&w=2000&auto=format&fit=crop',
};

class DetailProperty extends StatelessWidget {
  final Map<String, dynamic> property;

  const DetailProperty({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    // Set status bar icons to be light to contrast with the dark image
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      body: Stack(
        children: [
          // The main content scrolls behind the app bar
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildFeaturesRow(),
                      const SizedBox(height: 24),
                      const Divider(color: Colors.black26),
                      const SizedBox(height: 16),
                      _buildDescription(),
                      const SizedBox(
                          height: 100), // Space for the bottom button
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Positioned Floating Action Button at the bottom
          _buildBottomCta(),
        ],
      ),
    );
  }

  /// Builds the collapsing app bar with the property image.
  SliverAppBar _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300.0,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      iconTheme: const IconThemeData(
          color: Colors.white), // Back button color on image
      systemOverlayStyle: SystemUiOverlayStyle.light, // Status bar icons
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag:
              'property_image_${property['title']}', // Unique tag for Hero animation
          child: Image.network(
            property['image_url'] ??
                'https://placehold.co/600x400/000000/FFFFFF?text=Property',
            fit: BoxFit.cover,
            // Add a decorative scrim to make status bar icons more visible
            color: Colors.black.withOpacity(0.4),
            colorBlendMode: BlendMode.darken,
          ),
        ),
      ),
      // Custom leading back button for better aesthetics
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(50),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
      ),
    );
  }

  /// Builds the main title and address section.
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          property['title'] ?? 'No Title',
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on, color: Colors.black45, size: 16),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                property['address'] ?? 'No Address',
                style: const TextStyle(fontSize: 16, color: Colors.black54),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the row of key features with icons.
  Widget _buildFeaturesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildFeatureIcon(
            Icons.king_bed, '${property['bedrooms'] ?? '-'} Beds'),
        _buildFeatureIcon(
            Icons.bathtub, '${property['bathrooms'] ?? '-'} Baths'),
        _buildFeatureIcon(Icons.area_chart, '${property['area'] ?? '-'} sqft'),
      ],
    );
  }

  /// Helper widget for creating a feature item with an icon and text.
  Widget _buildFeatureIcon(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF3498DB), size: 28),
        const SizedBox(height: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Builds the description section.
  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About this property',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          property['facilities'] ?? 'No description available.',
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.5, // Improves readability
          ),
        ),
      ],
    );
  }

  /// Builds the persistent bottom CTA button area.
  Widget _buildBottomCta() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Price',
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                Text(
                  property['harga'] ?? 'N/A',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () {
                // Handle contact action
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3498DB),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              child:
                  const Text('Hubungi Penjual', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
