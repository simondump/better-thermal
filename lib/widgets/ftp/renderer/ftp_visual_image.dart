import 'dart:typed_data';

import 'package:flutter/material.dart';

class FtpVisualImage extends StatelessWidget {
  const FtpVisualImage({
    super.key,
    required this.image,
    required this.width,
    required this.height,
  });

  final Uint8List image;
  final int width;
  final int height;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: width / height,
      child: ClipRRect(
        borderRadius: BorderRadiusGeometry.circular(4),
        child: Image.memory(
          image,
          fit: BoxFit.contain,
          errorBuilder: (_, error, stackTrace) =>
              const Center(child: Icon(Icons.broken_image, size: 48)),
        ),
      ),
    );
  }
}
