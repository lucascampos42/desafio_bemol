import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProductTitleAndCategoryWidget extends StatelessWidget {
  final String title;

  const ProductTitleAndCategoryWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          key: const Key('product_detail_title'),
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            height: 1.0,
            letterSpacing: 0.0,
            color: Color(0xFF000000),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
