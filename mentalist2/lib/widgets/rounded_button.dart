import 'package:flutter/material.dart';
import '../theme/colors.dart';

class RoundedButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const RoundedButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
      ),
      onPressed: onTap,
      child: Text(label, style: const TextStyle(fontSize: 13)),
    );
  }
}
