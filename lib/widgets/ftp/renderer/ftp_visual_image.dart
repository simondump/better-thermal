import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'ftp_image_renderer.dart';

class FtpVisualImage extends FtpImageRenderer {
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
  Uint8List getImageJpeg() {
    final decoded = img.decodeImage(image);
    if (decoded == null) {
      throw const FormatException('Unable to decode visual image');
    }

    return Uint8List.fromList(img.encodeJpg(decoded));
  }

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
