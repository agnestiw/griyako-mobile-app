import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'location_item.dart';

class TopLocationsSection extends StatelessWidget {
  const TopLocationsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Top Locations',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'explore',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              LocationItem(
                name: 'Surabaya', 
                imageUrl: 'assets/tugu_pahlawan.jpg'
              ),
              LocationItem(
                name: 'Jakarta', 
                imageUrl: 'assets/monas.jpg'
              ),
              LocationItem(
                name: 'Bali', 
                imageUrl: 'assets/bali.webp'
              ),
            ],
          ),
        ),
      ],
    );
  }
}