import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class LocationHeader extends StatelessWidget {
  const LocationHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Icon(
            Icons.location_on,
            color: Color(0xFF234F68),
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: const [
              Text(
                'Surabaya, Indonesia',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.secondary,
                size: 20,
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(
            Icons.notifications_none_outlined,
            color: AppColors.secondary,
            size: 24,
          ),
          onPressed: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
        IconButton(
          icon: const Icon(
            Icons.chat_bubble_outline,
            color: AppColors.secondary,
            size: 24,
          ),
          onPressed: () {},
        ),
      ],
    );
  }
}