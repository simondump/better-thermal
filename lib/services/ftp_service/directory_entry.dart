class DirectoryEntryThumbnail {
  DirectoryEntryThumbnail({required this.name, required this.pixels});

  final String name;
  final List<int> pixels;
}

class DirectoryEntry {
  static const int endSize = 2;
  static const int headSizeLength = 4;
  static const int headSizeReqId = 4;
  static const int width = 160;
  static const int height = 120;
  static const int nameLength = 50;
  static const int rgbBytesPerImage = width * height * 3;
  static const int recordSize = nameLength + rgbBytesPerImage;
  static const int headerSize = headSizeReqId + headSizeLength;
  static const int size = headerSize + recordSize + endSize;

  /// Reads the payload length in the four bytes immediately after reqId.
  /// The Android implementation delegates this to ByteUtil.bytes2int; this
  /// is the usual network (big-endian) representation.
  static int getFrameSize(List<int> data) {
    return (data[4] << 24) | (data[5] << 16) | (data[6] << 8) | data[7];
  }

  /// Parses one complete response frame, including its 8-byte header.
  static List<DirectoryEntryThumbnail> getThumbnails(List<int> data) {
    final payloadLength = getFrameSize(data);

    if (payloadLength <= 0 || data.length < headerSize + payloadLength) {
      return <DirectoryEntryThumbnail>[];
    }

    final images = <DirectoryEntryThumbnail>[];
    final payloadEnd = headerSize + payloadLength;

    for (
      var offset = headerSize;
      offset + recordSize <= payloadEnd;
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
