import 'package:better_thermal/components/alert.dart';
import 'package:better_thermal/services/ftp_service/directory_entry.dart';
import 'package:better_thermal/services/ftp_service/ftp_service.dart';
import 'package:flutter/material.dart';

import 'ftp_image_details.dart';
import 'ftp_image_preview.dart';

class FtpScreen extends StatefulWidget {
  final FtpService ftpService;

  const FtpScreen({super.key, required this.ftpService});

  @override
  State<FtpScreen> createState() => _FtpScreenState();
}

class _FtpScreenState extends State<FtpScreen> {
  static const int _pageSize = 8;

  late final Map<int, List<DirectoryEntryThumbnail>> _cachedPages = {};

  bool _isErrored = false;
  bool _isLoading = false;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadPage(_currentPage);
  }

  void _loadPage(int page) {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    widget.ftpService
        .listImages(page, _pageSize)
        .then((entries) {
          setState(() {
            _currentPage = page;
            _cachedPages[page] = entries;
            _isLoading = false;
            _isErrored = false;
          });
        })
        .catchError((error) {
          setState(() {
            _isLoading = false;
            _isErrored = true;
          });
        });
  }

  void _goToNextPage() {
    if (_cachedPages[_currentPage] == null ||
        _cachedPages[_currentPage]!.length == _pageSize) {
      int nextPage = _currentPage + 1;

      if (_cachedPages.containsKey(nextPage)) {
        setState(() {
          _currentPage = nextPage;
        });
      } else {
        _loadPage(nextPage);
      }
    }
  }

  void _goToPreviousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  void _refreshCurrentPage() {
    _loadPage(_currentPage);
  }

  @override
  Widget build(BuildContext context) {
    if (_cachedPages.isEmpty && !_isLoading) {
      return Padding(
        padding: EdgeInsetsGeometry.all(8),
        child: Column(
          mainAxisAlignment: .end,
          spacing: 8,
          children: [
            if (_isErrored)
              const Alert(
                type: AlertType.danger,
                message: 'Failed to load images. Please try again.',
              ),
            if (_isLoading)
              const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _refreshCurrentPage,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      );
    }

    List<DirectoryEntryThumbnail> currentPageEntries =
        _cachedPages[_currentPage] ?? [];

    bool isFirstPage = _currentPage == 0;
    bool isLastPage = currentPageEntries.length < _pageSize;
    bool hasNextPage = currentPageEntries.length == _pageSize;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsetsGeometry.all(8),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const rows = 4;
                  const columns = 2;
                  const crossAxisSpacing = 4.0;
                  const mainAxisSpacing = 8.0;

                  final itemWidth =
                      (constraints.maxWidth -
                          crossAxisSpacing * (columns - 1)) /
                      columns;

                  final itemHeight =
                      (constraints.maxHeight - mainAxisSpacing * (rows - 1)) /
                      rows;

                  return GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currentPageEntries.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      crossAxisSpacing: crossAxisSpacing,
                      mainAxisSpacing: mainAxisSpacing,
                      childAspectRatio: itemWidth / itemHeight,
                    ),
                    itemBuilder: (context, index) {
                      return FtpImagePreview(
                        entry: currentPageEntries[index],
                        width: DirectoryEntry.width,
                        height: DirectoryEntry.height,
                        onSelect: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => FtpImageDetails(
                                ftpService: widget.ftpService,
                                fileName: currentPageEntries[index].name,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
          SizedBox(
            height: 64,
            child: _isLoading
                ? Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 12,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : _refreshCurrentPage,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                      ElevatedButton.icon(
                        onPressed: isFirstPage || _isLoading
                            ? null
                            : _goToPreviousPage,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Previous'),
                      ),
                      ElevatedButton.icon(
                        onPressed: (isLastPage || !hasNextPage || _isLoading)
                            ? null
                            : _goToNextPage,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Next'),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
