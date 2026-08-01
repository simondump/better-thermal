import 'package:better_thermal/services/ftp_service/directory_entry_file.dart';
import 'package:better_thermal/services/ftp_service/ftp_service.dart';
import 'package:flutter/material.dart';
import 'renderer/ftp_custom_image.dart';
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

  Widget _buildRepresentation(DirectoryEntryFile imageFile) {
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
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
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
              _buildRepresentation(imageFile),
              const SizedBox(height: 24),
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
            ],
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? '—' : value)),
        ],
      ),
    );
  }
}
