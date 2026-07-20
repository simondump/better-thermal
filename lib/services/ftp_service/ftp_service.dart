import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'directory_entry.dart';

String buildListDirectoryCmd(int page, int count) {
  // (Request ID, Directory, Page index, Page count)
  return '#getPhotoDir(0,0,$page,$count)\r\n';
}

class FtpService {
  String host;
  int port;

  FtpService({required this.host, required this.port});

  Future<Socket> _connect() async {
    return Socket.connect(host, port);
  }

  Future<List<DirectoryEntryThumbnail>> listImages(int page, int count) async {
    final socket = await _connect();
    final completer = Completer<List<DirectoryEntryThumbnail>>();
    final buffer = <int>[];

    socket.listen(
      (data) {
        buffer.addAll(data);

        if (buffer.length >= DirectoryEntry.headerSize) {
          // Wait until we have the full frame
          final payloadLength = DirectoryEntry.getFrameSize(buffer);
          final frameLength = DirectoryEntry.headerSize + payloadLength;
          if (buffer.length < frameLength) {
            return;
          }

          final frame = Uint8List.fromList(buffer.sublist(0, frameLength));
          buffer.removeRange(0, frameLength);

          if (!completer.isCompleted) {
            try {
              completer.complete(DirectoryEntry.getThumbnails(frame));
            } catch (error, stackTrace) {
              completer.completeError(error, stackTrace);
            }

            socket.destroy();
          }
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!completer.isCompleted) {
          completer.completeError(error, stackTrace);
        }
        socket.destroy();
      },
      onDone: () {
        if (!completer.isCompleted) {
          completer.completeError(
            StateError('Socket closed before a complete response was received'),
          );
        }
      },
      cancelOnError: true,
    );

    socket.write(buildListDirectoryCmd(page, count));
    await socket.flush();

    return completer.future;
  }
}
