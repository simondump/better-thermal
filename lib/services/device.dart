import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

enum ConnectionStatus { connecting, connected, error }

class DeviceService {
  final String host;
  final int port;
  final int frameWidth;
  final int frameHeight;
  late final int bytesPerFrame;

  final void Function(ConnectionStatus) onStatusChanged;
  final void Function(Uint8List) onFrameReceived;

  Socket? _socket;
  Timer? _reconnectTimer;

  final List<int> _pendingBytes = <int>[];
  late final Uint8List _latestFrameBytes;

  ConnectionStatus _status = ConnectionStatus.connecting;

  ConnectionStatus get status => _status;

  DeviceService({
    required this.frameWidth,
    required this.frameHeight,
    required this.host,
    required this.port,
    required this.onStatusChanged,
    required this.onFrameReceived,
  }) {
    bytesPerFrame = frameWidth * frameHeight * 3;
    _latestFrameBytes = Uint8List(frameWidth * frameHeight * 4);
    _nextFrame();
  }

  Future<void> _nextFrame() async {
    _reconnectTimer?.cancel();

    _updateStatus(ConnectionStatus.connecting);

    try {
      _socket?.destroy();
      _socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 3),
      );

      _updateStatus(ConnectionStatus.connected);

      _socket!.listen(
        _handleSocketData,
        onDone: _handleSocketDone,
        onError: _handleSocketError,
        cancelOnError: true,
      );
    } catch (error) {
      _updateStatus(ConnectionStatus.error);
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 2), _nextFrame);
  }

  void _handleSocketDone() {
    _socket?.destroy();
    _socket = null;
  }

  void _handleSocketError(Object error) {
    _socket?.destroy();
    _socket = null;

    _updateStatus(ConnectionStatus.error);
    _scheduleReconnect();
  }

  void _handleSocketData(Uint8List chunk) {
    _pendingBytes.addAll(chunk);

    while (_pendingBytes.length >= bytesPerFrame) {
      final rgbFrame = Uint8List.fromList(
        _pendingBytes.sublist(0, bytesPerFrame),
      );

      _pendingBytes.removeRange(0, bytesPerFrame);
      _decodeAndPublishFrame(rgbFrame);
      _nextFrame();
    }
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

    onFrameReceived(rgbaFrame);
  }

  void _updateStatus(ConnectionStatus status) {
    _status = status;
    onStatusChanged(status);
  }

  void dispose() {
    _reconnectTimer?.cancel();
    _socket?.destroy();
  }
}
