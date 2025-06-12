import 'package:flutter/material.dart';
import '../utils/app_colors.dart'; // Assuming AppColors.border, AppColors.secondary, AppColors.grey are defined here

class MarketplaceItem extends StatelessWidget {
  final String title;
  final String price;
  final String imageUrl;
  final bool isNetworkImage; // Add this flag

  const MarketplaceItem({
    Key? key,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.isNetworkImage, // Make sure to require it in the constructor
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define a placeholder/fallback asset path for clarity
    const String fallbackAssetPath =
        'assets/logo_griyako.png'; // Ensure this asset exists and is in pubspec.yaml

    Widget imageWidget;

    if (isNetworkImage) {
      imageWidget = Image.network(
        imageUrl, // This will be the full URL
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        loadingBuilder: (BuildContext context, Widget child,
            ImageChunkEvent? loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            // Use SizedBox to constrain the CircularProgressIndicator
            width: 100,
            height: 100,
            child: Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2.0, // Optional: make the spinner smaller
              ),
            ),
          );
        },
        errorBuilder:
            (BuildContext context, Object exception, StackTrace? stackTrace) {
          print(
              'Error loading network image: $imageUrl, Exception: $exception');
          // Fallback to a default asset if network image fails
          return Image.asset(
            fallbackAssetPath,
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          );
        },
      );
    } else {
      // If not a network image, imageUrl should be an asset path (e.g., the fallbackAssetPath)
      imageWidget = Image.asset(
        imageUrl,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child:
                imageWidget, // Use the conditionally created imageWidget here
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment
                    .center, // Optional: to better align text if content varies
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines:
                        2, // Optional: prevent very long titles from breaking layout
                    overflow: TextOverflow
                        .ellipsis, // Optional: show ellipsis for overflow
                  ),
                  const SizedBox(height: 8),
                  Text(
                    price,
                    style: const TextStyle(
                      color: AppColors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
