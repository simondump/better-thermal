import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

enum DeviceStatus { connecting, connected, disconnected, error }

class LiveStreamService {
  final int _maxFrameTimestamps = 10;

  final StreamController<DeviceStatus> _statusController =
      StreamController<DeviceStatus>.broadcast();

  final StreamController<Uint8List> _frameController =
      StreamController<Uint8List>.broadcast();

  final StreamController<double> _fpsController =
      StreamController<double>.broadcast();

  Stream<DeviceStatus> get statusStream => _statusController.stream;

  Stream<Uint8List> get frameStream => _frameController.stream;

  Stream<double> get fpsConnector => _fpsController.stream;

  final String host;
  final int port;
  final int frameWidth;
  final int frameHeight;
  late final int bytesPerFrame;

  Socket? _socket;

  final List<int> _frameBuffer = <int>[];
  final List<int> _frameTimestamps = <int>[];
  late final Uint8List _latestFrameBytes;

  DeviceStatus _status = DeviceStatus.disconnected;

  DeviceStatus get status => _status;

  LiveStreamService({
    required this.frameWidth,
    required this.frameHeight,
    required this.host,
    required this.port,
  }) {
    bytesPerFrame = frameWidth * frameHeight * 3;
    _latestFrameBytes = Uint8List(frameWidth * frameHeight * 4);
  }

  void connect() {
    if (_status != DeviceStatus.connected &&
        _status != DeviceStatus.connecting) {
      _updateStatus(DeviceStatus.connecting);
      _nextFrame();
    }
  }

  void disconnect() {
    _socket?.destroy();
    _socket = null;
    _frameBuffer.removeRange(0, _frameBuffer.length);
    _updateStatus(DeviceStatus.disconnected);
  }

  Future<void> _nextFrame() async {
    try {
      _socket?.destroy();
      _socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 3),
      );

      _updateStatus(DeviceStatus.connected);

      _socket!.listen(
        _handleSocketData,
        onDone: _handleSocketDone,
        onError: _handleSocketError,
        cancelOnError: true,
      );
    } catch (error) {
      _updateStatus(DeviceStatus.error);
    }
  }

  void _handleSocketDone() {
    _socket?.destroy();
    _socket = null;
  }

  void _handleSocketError(Object error) {
    _socket?.destroy();
    _socket = null;

    _updateStatus(DeviceStatus.error);
  }

  void _handleSocketData(Uint8List chunk) {
    _frameBuffer.addAll(chunk);

    if (_frameBuffer.length < bytesPerFrame) {
      return;
    }

    // Frame collected
    _frameTimestamps.add(DateTime.now().millisecondsSinceEpoch);
    if (_frameTimestamps.length > _maxFrameTimestamps) {
      _frameTimestamps.removeAt(0);
    }

    // Calculate Average FPS based on the time difference between each frames
    if (_frameTimestamps.length >= 2) {
      var diffs = <double>[];
      for (var i = 1; i < _frameTimestamps.length; i++) {
        diffs.add((_frameTimestamps[i] - _frameTimestamps[i - 1]).toDouble());
      }

      final avgDiff = diffs.reduce((a, b) => a + b) / diffs.length;
      final fps = (1000.0 / avgDiff);
      _fpsController.add(fps);
    }

    final rgbFrame = Uint8List.fromList(_frameBuffer.sublist(0, bytesPerFrame));

    _frameBuffer.removeRange(0, bytesPerFrame);
    _decodeAndPublishFrame(rgbFrame);
    _nextFrame();
  }

  void _decodeAndPublishFrame(Uint8List rgbFrame) {
    final rgbaFrame = _latestFrameBytes;

    int rgbIndex = 0;
    int rgbaIndex = 0;
    while (rgbIndex < rgbFrame.length) {
      rgbaFrame[rgbaIndex++] = rgbFrame[rgbIndex++];
      rgbaFrame[rgbaIndex++] = rgbFrame[rgbIndex++];
      rgbaFrame[rgbaIndex++] = rgbFrame[rgbIndex++];
      rgbaFrame[rgbaIndex++] = 255;
    }

    _frameController.add(rgbaFrame);
  }

  void _updateStatus(DeviceStatus status) {
    _status = status;
    _statusController.add(status);
  }
}
