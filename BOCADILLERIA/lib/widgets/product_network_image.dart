import 'package:flutter/material.dart';

/// Imagen de producto compatible con Flutter Web (evita fallos CORS en localhost).
class ProductNetworkImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ProductNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return errorWidget ??
          const ColoredBox(
            color: Color(0xFFE5E7EB),
            child: Icon(Icons.fastfood_rounded, color: Colors.grey),
          );
    }

    return Image.network(
      imageUrl,
      key: ValueKey(imageUrl),
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ??
            const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFF97316),
                ),
              ),
            );
      },
      errorBuilder: (context, error, stackTrace) =>
          errorWidget ??
          const ColoredBox(
            color: Color(0xFFE5E7EB),
            child: Icon(Icons.broken_image, color: Colors.grey),
          ),
    );
  }
}
