class DirectoryEntryThumbnail {
  DirectoryEntryThumbnail({required this.name, required this.pixels});

  final String name;
  final List<int> pixels;
}

class DirectoryEntry {
  static const int endSize = 2;
  static const int headerLengthSize = 4;
  static const int headerReqIdSize = 4;
  static const int width = 160;
  static const int height = 120;
  static const int nameLength = 50;
  static const int rgbBytesPerImage = width * height * 3;
  static const int recordSize = nameLength + rgbBytesPerImage;
  static const int headerSize = headerReqIdSize + headerLengthSize + endSize;
  static const int size = headerSize + recordSize + endSize;

  /// Returns the expected complete file size when [partial] contains a valid
  /// data-length header, or `null` while the header cannot be parsed.
  static int? getSize(List<int> data) {
    if (data.length < headerSize) {
      return null;
    }

    return (((data[4] << 24) | (data[5] << 16) | (data[6] << 8) | data[7])) +
        headerSize;
  }

  /// Parses one complete response frame, including its 8-byte header.
  static List<DirectoryEntryThumbnail> getThumbnails(List<int> data) {
    final size = getSize(data)!;

    if (size <= 0 || data.length < size) {
      throw FormatException('Invalid DirectoryEntry format: insufficient data');
    }

    final images = <DirectoryEntryThumbnail>[];

    for (
      var offset = headerReqIdSize + headerLengthSize;
      offset + recordSize <= size;
      offset += recordSize
    ) {
      final nameBytes = data.sublist(offset, offset + nameLength);
      final rgbBytes = data.sublist(offset + nameLength, offset + recordSize);

      var name = String.fromCharCodes(nameBytes);
      final nullIndex = name.indexOf('\u0000');
      if (nullIndex >= 0) {
        name = name.substring(0, nullIndex);
      }

      images.add(DirectoryEntryThumbnail(name: name.trim(), pixels: rgbBytes));
    }

    return images;
  }
}
