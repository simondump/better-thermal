import 'package:cross_file/cross_file.dart';
import 'package:better_thermal/services/ftp_service/directory_entry_file.dart';
import 'package:better_thermal/services/ftp_service/ftp_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'renderer/ftp_custom_image.dart';
import 'renderer/ftp_image_renderer.dart';
import 'renderer/ftp_thermal_image.dart';
import 'renderer/ftp_visual_image.dart';

enum _ImageMode { thermal, visual, custom }

class FtpImageDetails extends StatefulWidget {
  const FtpImageDetails({
    super.key,
    required this.ftpService,
    required this.fileName,
  });

  final FtpService ftpService;
  final String fileName;

  @override
  State<FtpImageDetails> createState() => _FtpImageDetailsState();
}

class _FtpImageDetailsState extends State<FtpImageDetails> {
  late Future<DirectoryEntryFile> _imageFuture;
  var _mode = _ImageMode.thermal;
  var _isSharing = false;

  @override
  void initState() {
    super.initState();
    _imageFuture = widget.ftpService.getImage(widget.fileName);
  }

  void _retry() {
    setState(() {
      _imageFuture = widget.ftpService.getImage(widget.fileName);
    });
  }

  FtpImageRenderer _buildRepresentation(DirectoryEntryFile imageFile) {
    return switch (_mode) {
      _ImageMode.thermal => FtpThermalImage(
        image: imageFile.thermalImage,
        width: imageFile.width,
        height: imageFile.height,
      ),
      _ImageMode.visual => FtpVisualImage(
        image: imageFile.visualImage,
        width: imageFile.width,
        height: imageFile.height,
      ),
      _ImageMode.custom => FtpCustomImage(
        samples: imageFile.samples,
        width: imageFile.width,
        height: imageFile.height,
      ),
    };
  }

  Future<void> _shareImage(FtpImageRenderer representation) async {
    if (!mounted) return;

    setState(() {
      _isSharing = true;
    });

    try {
      final jpegBytes = representation.getImageJpeg();
      final timestamp = DateFormat('yyyyMMddHHmmss').format(DateTime.now());
      final file = XFile.fromData(
        jpegBytes,
        name: '$timestamp.jpg',
        mimeType: 'image/jpeg',
      );

      await SharePlus.instance.share(
        ShareParams(files: [file], subject: 'Thermal camera image'),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export image: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.fileName)),
      body: FutureBuilder<DirectoryEntryFile>(
        future: _imageFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.broken_image, size: 48),
                  const SizedBox(height: 12),
                  const Text('Failed to load image details.'),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _retry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final imageFile = snapshot.data!;
          final representation = _buildRepresentation(imageFile);
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: .start,
              spacing: 2,
              children: [
                Column(
                  spacing: 1,
                  children: [
                    _MetadataRow(label: 'File name', value: imageFile.fileName),
                    _MetadataRow(
                      label: 'Dimensions',
                      value: '${imageFile.width} × ${imageFile.height}',
                    ),
                    _MetadataRow(
                      label: 'Created',
                      value: imageFile.createdTime.toLocal().toString(),
                    ),
                    _MetadataRow(label: 'Model', value: imageFile.modelText),
                    _MetadataRow(
                      label: 'Humidity',
                      value: imageFile.humidityText,
                    ),
                    _MetadataRow(
                      label: 'Temperature',
                      value: imageFile.temperatureText,
                    ),
                    _MetadataRow(
                      label: 'Emissivity',
                      value: imageFile.emissivityText,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                representation,
                Expanded(
                  child: Column(
                    crossAxisAlignment: .stretch,
                    mainAxisAlignment: .end,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isSharing
                            ? null
                            : () => _shareImage(representation),
                        icon: const Icon(Icons.ios_share),
                        label: Text(_isSharing ? 'Exporting…' : 'Export image'),
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<_ImageMode>(
                        segments: const [
                          ButtonSegment(
                            value: _ImageMode.thermal,
                            label: Text('Thermal'),
                          ),
                          ButtonSegment(
                            value: _ImageMode.visual,
                            label: Text('Visual'),
                          ),
                          ButtonSegment(
                            value: _ImageMode.custom,
                            label: Text('Custom'),
                          ),
                        ],
                        selected: {_mode},
                        onSelectionChanged: (selection) {
                          setState(() {
                            _mode = selection.first;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  const _MetadataRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: Theme.of(context).textTheme.titleSmall),
        ),
        Expanded(child: Text(value.isEmpty ? '—' : value)),
      ],
    );
  }
}
