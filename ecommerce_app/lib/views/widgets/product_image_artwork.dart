import 'package:ecommerce_app/core/theme/app_style.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:flutter/material.dart';

class ProductImageArtwork extends StatelessWidget {
  const ProductImageArtwork({
    super.key,
    required this.product,
    this.fit = BoxFit.cover,
    this.iconSize = 72,
    this.borderRadius,
  });

  final ProductModel product;
  final BoxFit fit;
  final double iconSize;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final content = product.imgUrl.trim().isNotEmpty
        ? Image.network(
            product.imgUrl,
            fit: fit,
            errorBuilder: (context, error, stackTrace) =>
                _FallbackProductImage(iconSize: iconSize),
          )
        : _FallbackProductImage(iconSize: iconSize);

    if (borderRadius == null) {
      return content;
    }

    return ClipRRect(
      borderRadius: borderRadius!,
      child: content,
    );
  }
}

class _FallbackProductImage extends StatelessWidget {
  const _FallbackProductImage({required this.iconSize});

  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppStyle.primaryColor,
            Color(0xFF14B8A6),
            AppStyle.secondaryColor,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.shopping_bag_rounded,
          size: iconSize,
          color: Colors.white,
        ),
      ),
    );
  }
}
