import 'dart:typed_data';

/// One eight-byte thermal sample from SeekData.
class ThermalSample {
  const ThermalSample({required this.celsius, required this.raw});

  final double celsius;
  final int raw;
}

/// Reverse-engineered, cleaned up Dart port of the Thermal-Link DataParser_ImgFile class.
class DirectoryEntryFile {
  static const int requestIdSize = 4;
  static const int dataLengthSize = 4;
  static const int envelopeSize = requestIdSize + dataLengthSize;
  static const int endSize = 2;
  static const int fileNameSize = 50;
  static const int seekSampleSize = 8;
  static const int voiceLengthSize = 4;

  late final Uint8List data;
  late final String fileName;
  late final int size;
  late final int width;
  late final int height;

  late final List<ThermalSample> samples;

  late final Uint8List visualImage; // Bitmap-encoded visual image
  late final Uint8List thermalImage; // Bitmap-encoded thermal image
  late final Uint8List seekData;
  late final Uint8List messageData;
  late final Uint8List reservedData;
  late final Uint8List menu;
  late final Uint8List colorScaleState;
  late final Uint8List imageState;
  late final Uint8List customTemperatureMenuState;
  late final Uint8List qrCode;
  late final Uint8List hardwareVersion;
  late final Uint8List softwareVersion;
  late final Uint8List model;
  late final Uint8List emissivity;
  late final Uint8List createdTimeBytes;
  late final Uint8List manual;
  late final Uint8List humidity;
  late final Uint8List temperature;
  late final Uint8List resolution;
  late final Uint8List voiceMark;
  late final Uint8List voiceData;

  late final int markMode;
  late final int viewMode;
  late final int colorIndex;
  late final int colorScale;
  late final int thermalOffsetX;
  late final int thermalOffsetY;
  late final String modelText;
  late final String resolutionText;
  late final String emissivityText;
  late final DateTime createdTime;

  DirectoryEntryFile(Uint8List input) {
    size = getSize(input)!;

    if (!_assertEnvelope(input) || !_parseFile(input)) {
      throw FormatException('Invalid DirectoryEntryFile format');
    }
  }

  /// Returns the expected complete file size when [partial] contains a valid
  /// data-length header, or `null` while the header cannot be parsed.
  static int? getSize(Uint8List partial) {
    if (partial.length < requestIdSize + dataLengthSize) return null;

    final dataLength = _u32be(partial, requestIdSize);
    if (dataLength < fileNameSize) return null;

    return dataLength + requestIdSize + dataLengthSize + endSize;
  }

  /// Returns `true` if the input has the expected envelope and end bytes.
  bool _assertEnvelope(Uint8List input) {
    if (input.length != size) {
      return false;
    }

    // The packet must end with 0D 0A.
    final endOffset = size - endSize;
    if (input[endOffset] != 0x0D || input[endOffset + 1] != 0x0A) {
      return false;
    }

    return true;
  }

  /// Returns `true` if the file was successfully parsed.
  bool _parseFile(Uint8List input) {
    try {
      fileName = _text(_slice(input, envelopeSize, fileNameSize));

      final dataStart = envelopeSize + fileNameSize;
      final dataEnd = size - endSize;
      data = _slice(input, dataStart, dataEnd - dataStart);

      final voiceLength = _u32be(data, data.length - voiceLengthSize);
      final voiceStart = data.length - voiceLengthSize - voiceLength;
      voiceData = _slice(data, voiceStart, voiceLength);

      var suffixEnd = voiceStart;
      suffixEnd = _parseMainBodyBackwards(data, suffixEnd);

      if (width == 0 || height == 0) {
        return false;
      }

      final imageLengthOffset = suffixEnd - width * height * seekSampleSize - 4;
      final visualLength = _u32be(data, imageLengthOffset);
      final visualStart = imageLengthOffset - visualLength;

      visualImage = _slice(data, visualStart, visualLength);
      thermalImage = _slice(data, 0, visualStart);

      return true;
    } on RangeError {
      return false;
    } on FormatException {
      return false;
    }
  }

  /// Parses the main body of the file backwards, starting from [end].
  int _parseMainBodyBackwards(Uint8List data, int end) {
    Uint8List take(int size) {
      end -= size;
      return _slice(data, end, size);
    }

    voiceMark = take(0); // Don't know what that's for
    resolution = take(10);
    resolutionText = _text(resolution);
    final resolutionParts = resolutionText.split('x');
    if (resolutionParts.length != 2) {
      throw const FormatException('Invalid resolution');
    }

    width = int.parse(resolutionParts[0]);
    height = int.parse(resolutionParts[1]);
    temperature = take(10);
    humidity = take(10);
    manual = take(10);

    createdTimeBytes = take(8);
    createdTime = DateTime.fromMillisecondsSinceEpoch(
      _u64be(createdTimeBytes) - 28800000,
      isUtc: true,
    );

    emissivity = take(10);
    emissivityText = _text(emissivity);

    model = take(10);
    modelText = _text(model);

    // Somehow hard-coded in the original app
    if (modelText == 'UTi260E') {
      width = 256;
      height = 192;
    }

    softwareVersion = take(10);
    hardwareVersion = take(10);
    qrCode = take(1970);
    customTemperatureMenuState = take(336);
    imageState = take(40);
    colorScaleState = take(132);

    menu = take(16);
    markMode = _u32le(menu, 0);
    viewMode = _u32le(menu, 4);
    colorIndex = _u32le(menu, 8);
    colorScale = _u32le(menu, 12);

    reservedData = take(1000);
    thermalOffsetX = _u32be(reservedData, 12);
    thermalOffsetY = _u32be(reservedData, 16);

    messageData = take(476);

    final seekStart = end - width * height * seekSampleSize;

    seekData = _slice(data, seekStart, width * height * seekSampleSize);
    samples = <ThermalSample>[
      for (var offset = 0; offset < seekData.length; offset += seekSampleSize)
        ThermalSample(
          celsius: ByteData.sublistView(
            seekData,
            offset,
            offset + 4,
          ).getFloat32(0, Endian.big),
          raw: ByteData.sublistView(
            seekData,
            offset + 6,
            offset + seekSampleSize,
          ).getUint16(0, Endian.big),
        ),
    ];

    return end;
  }

  static Uint8List _slice(Uint8List bytes, int start, int length) {
    if (start < 0 || length < 0 || (start + length) > bytes.length) {
      throw RangeError('Invalid img-file slice: $start + $length');
    }

    return Uint8List.sublistView(bytes, start, start + length);
  }

  static int _u32le(Uint8List bytes, int offset) => ByteData.sublistView(
    bytes,
    offset,
    offset + 4,
  ).getUint32(0, Endian.little);

  static int _u32be(Uint8List bytes, int offset) =>
      ByteData.sublistView(bytes, offset, offset + 4).getUint32(0, Endian.big);

  static int _u64be(Uint8List bytes) =>
      ByteData.sublistView(bytes).getUint64(0, Endian.big);

  static String _text(Uint8List bytes) =>
      String.fromCharCodes(bytes.takeWhile((int value) => value != 0));
}
