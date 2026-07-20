import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:better_thermal/services/ftp_service/directory_entry.dart';
import 'package:better_thermal/styles/themes.dart';
import 'package:flutter/material.dart';

class FtpImagePreview extends StatefulWidget {
  final DirectoryEntryThumbnail entry;
  final int width;
  final int height;

  const FtpImagePreview({
    super.key,
    required this.entry,
    required this.width,
    required this.height,
  });

  @override
  State<FtpImagePreview> createState() => _FtpImagePreviewState();
}

class _FtpImagePreviewState extends State<FtpImagePreview> {
  ui.Image? _image;
  Object? _error;

  var _loading = true;
  var _loadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(covariant FtpImagePreview oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entry != widget.entry) {
      _image?.dispose();
      _image = null;
      _error = null;
      _loading = true;
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    final generation = ++_loadGeneration;

    try {
      final image = await _decodeRgbImage(widget.entry.pixels);
      if (!mounted || generation != _loadGeneration) {
        image.dispose();
        return;
      }

      setState(() {
        _image = image;
        _loading = false;
      });
    } catch (error) {
      if (!mounted || generation != _loadGeneration) {
        return;
      }

      setState(() {
        _error = error;
        _loading = false;
      });
    }
  }

  Future<ui.Image> _decodeRgbImage(List<int> pixels) {
    final expectedLength = widget.width * widget.height * 3;

    if (pixels.length != expectedLength) {
      throw ArgumentError.value(
        pixels.length,
        'pixels.length',
        'Expected $expectedLength RGB bytes.',
      );
    }

    final rgbaPixels = Uint8List(widget.width * widget.height * 4);
    for (
      var rgbOffset = 0, rgbaOffset = 0;
      rgbOffset < pixels.length;
      rgbOffset += 3, rgbaOffset += 4
    ) {
      rgbaPixels[rgbaOffset] = pixels[rgbOffset];
      rgbaPixels[rgbaOffset + 1] = pixels[rgbOffset + 1];
      rgbaPixels[rgbaOffset + 2] = pixels[rgbOffset + 2];
      rgbaPixels[rgbaOffset + 3] = 255;
    }

    final imageCompleter = Completer<ui.Image>();

    ui.decodeImageFromPixels(
      rgbaPixels,
      widget.width,
      widget.height,
      ui.PixelFormat.rgba8888,
      imageCompleter.complete,
    );

    return imageCompleter.future;
  }

  @override
  void dispose() {
    _loadGeneration++;
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 0,
      children: [
        SizedBox(
          width: double.maxFinite,
          child: Padding(padding: EdgeInsets.all(4), child: _buildImage()),
        ),
        Text(
          widget.entry.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: context.theme.colors.onBackground,
            fontSize: 12,
            fontWeight: .bold,
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return const Center(child: Icon(Icons.broken_image));
    }

    return RawImage(image: _image, fit: BoxFit.contain);
  }
}
