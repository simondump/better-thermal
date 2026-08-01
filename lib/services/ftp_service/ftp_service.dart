import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:better_thermal/services/ftp_service/directory_entry_file.dart';

import 'directory_entry.dart';

String buildListDirectoryCmd(int page, int count) {
  // (Request ID, Directory, Page index, Page count)
  return '#getPhotoDir(0,0,$page,$count)\r\n';
}

String buildGetPhotoFileCmd(String value) {
  // (Request ID, File Name)
  return '#getPhotofile(0,$value)\r\n';
}

class FtpService {
  String host;
  int port;

  FtpService({required this.host, required this.port});

  Future<T> _fetch<T>(
    String command,
    int? Function(Uint8List) getSize,
    T Function(Uint8List) getResponse,
  ) async {
    final socket = await Socket.connect(host, port);
    final completer = Completer<T>();
    final buffer = <int>[];
    int? size;

    socket.listen(
      (data) {
        buffer.addAll(data);
        size ??= getSize(Uint8List.fromList(buffer));

        if (size != null && buffer.length == size && !completer.isCompleted) {
          try {
            completer.complete(getResponse(Uint8List.fromList(buffer)));
          } catch (error, stackTrace) {
            completer.completeError(error, stackTrace);
          }

          socket.destroy();
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

    socket.write(command);
    await socket.flush();

    return completer.future;
  }

  Future<List<DirectoryEntryThumbnail>> listImages(int page, int count) async {
    return _fetch<List<DirectoryEntryThumbnail>>(
      buildListDirectoryCmd(page, count),
      DirectoryEntry.getSize,
      DirectoryEntry.getThumbnails,
    );
  }

  Future<DirectoryEntryFile> getImage(String name) async {
    return _fetch<DirectoryEntryFile>(
      buildGetPhotoFileCmd(name),
      DirectoryEntryFile.getSize,
      (data) => DirectoryEntryFile(data),
    );
  }
}
