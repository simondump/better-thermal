import 'package:better_thermal/components/alert.dart';
import 'package:better_thermal/services/ftp_service/directory_entry.dart';
import 'package:better_thermal/services/ftp_service/ftp_service.dart';
import 'package:better_thermal/styles/themes.dart';
import 'package:flutter/material.dart';

import 'ftp_image_preview.dart';

class FtpScreen extends StatefulWidget {
  final FtpService ftpService;

  const FtpScreen({super.key, required this.ftpService});

  @override
  State<FtpScreen> createState() => _FtpScreenState();
}

class _FtpScreenState extends State<FtpScreen> {
  static const int _pageSize = 10;
  late final List<DirectoryEntryThumbnail> _entries = [];
  late ScrollController _scrollController;

  bool _isLoading = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadMore();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMore() {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    widget.ftpService
        .listImages(_currentPage, _pageSize)
        .then((entries) {
          setState(() {
            _entries.addAll(entries);
            _currentPage++;
            _isLoading = false;
          });
        })
        .catchError((error) {
          setState(() {
            _isLoading = false;
          });
        });
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_entries.isEmpty && !_isLoading) {
      return SafeArea(
        child: Alert(type: .success, message: 'No images found.'),
      );
    }

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: GridView(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
              ),
              children: _entries
                  .map(
                    (entry) => FtpImagePreview(
                      entry: entry,
                      width: DirectoryEntry.width,
                      height: DirectoryEntry.height,
                    ),
                  )
                  .toList(),
            ),
          ),
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(24),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: context.theme.colors.primary,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
