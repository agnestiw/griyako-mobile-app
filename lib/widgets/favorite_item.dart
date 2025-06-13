import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class FavoriteItem extends StatelessWidget {
  final String title;
  final String location;
  final String bedrooms;
  final String bathrooms;
  final String price;
  final String imageUrl;
  final String? rating;
  final String? squareMeters;
  final String type;

  const FavoriteItem({
    Key? key,
    required this.title,
    required this.location,
    required this.bedrooms,
    required this.bathrooms,
    required this.price,
    required this.imageUrl,
    this.rating,
    this.squareMeters,
    required this.type,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: (imageUrl != null && imageUrl.isNotEmpty)
                    ? Image.network(
                        imageUrl,
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Image load error: $error');
                          return const Center(child: Icon(Icons.broken_image));
                        },
                      )
                    : const Center(child: Icon(Icons.broken_image)),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                ),
              ),
              if (rating != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFEEA651),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating!,
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
              if (squareMeters != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      squareMeters!,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    type,
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
                  title,
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (location.isNotEmpty) const SizedBox(height: 8),
                if (location.isNotEmpty)
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.secondary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                if (bedrooms.isNotEmpty && bathrooms.isNotEmpty)
                  const SizedBox(height: 12),
                if (bedrooms.isNotEmpty && bathrooms.isNotEmpty)
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
                          fontSize: 14,
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
                          fontSize: 14,
                        ),
                      ),
                      if (price.isNotEmpty) const Spacer(),
                      if (price.isNotEmpty)
                        Text(
                          price,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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
