import 'package:ecommerce_app/core/theme/app_style.dart';
import 'package:ecommerce_app/models/product_model.dart';
import 'package:ecommerce_app/views/widgets/product_image_artwork.dart';
import 'package:flutter/material.dart';

class ProductCarouselCard extends StatelessWidget {
  const ProductCarouselCard({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppStyle.surfaceColor,
        borderRadius: BorderRadius.circular(AppStyle.radiusLarge),
        boxShadow: AppStyle.softShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppStyle.radiusLarge),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ProductImageArtwork(product: product),
            DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x050F172A),
                    Color(0x300F172A),
                    Color(0xD90F172A),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppStyle.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: AppStyle.spacingXs,
                    runSpacing: AppStyle.spacingXs,
                    children: product.categories
                        .map(
                          (category) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppStyle.spacingSm,
                              vertical: AppStyle.spacingXs,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              category.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const Spacer(),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppStyle.spacingXs),
                  Text(
                    product.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.86),
                    ),
                  ),
                  const SizedBox(height: AppStyle.spacingMd),
                  Text(
                    _formatPrice(product.price),
                    style: textTheme.displayMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    final fixedValue = price.toStringAsFixed(2).replaceAll('.', ',');
    return 'R\$ $fixedValue';
  }
}
