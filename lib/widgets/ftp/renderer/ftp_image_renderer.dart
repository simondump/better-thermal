import 'dart:typed_data';

import 'package:flutter/widgets.dart';

abstract class FtpImageRenderer extends StatelessWidget {
  const FtpImageRenderer({super.key});

  Uint8List getImageJpeg();
}

