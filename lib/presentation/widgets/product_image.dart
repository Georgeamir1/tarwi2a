import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget placeholder;
  final Widget errorWidget;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    required this.placeholder,
    required this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    if (url == null || url.isEmpty) {
      return errorWidget;
    }

    if (url.startsWith('data:image')) {
      try {
        final base64Str = url.split(',').last;
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          gaplessPlayback: true, // Prevents decoding blink on state rebuilds
          errorBuilder: (_, __, ___) => errorWidget,
        );
      } catch (_) {
        return errorWidget;
      }
    }

    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      fadeInDuration: Duration.zero,   // Instantly display when cached, no fade-in flash
      fadeOutDuration: Duration.zero,  // Instantly swap, no fade-out flash
      placeholder: (_, __) => placeholder,
      errorWidget: (_, __, ___) => errorWidget,
    );
  }
}
