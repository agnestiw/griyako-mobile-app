import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class PropertyCard extends StatelessWidget {
  // 1. UPDATE THE CONSTRUCTOR PARAMETERS
  // We change 'image' to 'imageUrl' and add 'isNetworkImage'
  final String imageUrl;
  final bool isNetworkImage;
  final String type;
  final String size;
  final String price;
  final String bedrooms;
  final String bathrooms;
  final String location;
  final String title;

  const PropertyCard({
    Key? key,
    required this.imageUrl, // Changed from 'image'
    required this.isNetworkImage, // Added
    required this.type,
    required this.size,
    required this.price,
    required this.bedrooms,
    required this.bathrooms,
    required this.location,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 2. ADD THE LOGIC TO CHOOSE THE CORRECT IMAGE WIDGET
    Widget imageWidget;
    if (isNetworkImage) {
      // If it's a network image, use Image.network
      imageWidget = Image.network(
        imageUrl,
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const SizedBox(
            height: 120,
            child: Center(child: CircularProgressIndicator()),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // Display a placeholder icon if the network image fails
          return const SizedBox(
            height: 120,
            child: Icon(Icons.broken_image_outlined, color: AppColors.grey, size: 40),
          );
        },
      );
    } else {
      // Otherwise, use Image.asset for local fallback images
      imageWidget = Image.asset(
        imageUrl, // Now this will be a local asset path like 'assets/logo_griyako.png'
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            // 3. USE THE NEW imageWidget HERE
            // This will be either the network image or the asset image
            child: imageWidget,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                // I noticed 'size' and 'title' had the same style.
                // You can combine them or keep them separate as you prefer.
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                   maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  price,
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
                      Icons.bed_outlined,
                      color: AppColors.secondary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      bedrooms,
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.bathtub_outlined,
                      color: AppColors.secondary,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      bathrooms,
                      style: const TextStyle(
                        color: AppColors.secondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
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
                        location,
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
    );
  }
}