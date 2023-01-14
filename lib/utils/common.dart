import 'package:android_mate/adb_fs/main.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

import 'package:mime/mime.dart';


IconData leadIcon(FsType fsType, String fsPath) {
  final itype = fsType;
  final ftype = getFileTypeIcon(fsPath);
  switch (itype) {
    case FsType.folder:
      return FluentIcons.folder;
    case FsType.link:
      return FluentIcons.file_symlink;
    default:
      return ftype;
  }
}

IconData getFileTypeIcon(String filePath) {
  final mimeType = getExtension(filePath);

  if (mimeType == null) {
    return FluentIcons.page_solid;
  }
  if (mimeType == 'text/plain') {
    return FluentIcons.text_document;
  } else if (mimeType == 'application/pdf') {
    return FluentIcons.pdf;
  } else if (mimeType == 'application/vnd.android.package-archive') {
    return FluentIcons.app_icon_default;
  } else if (mimeType == 'application/zip' ||
      mimeType == 'application/x-rar-compressed' ||
      mimeType == 'application/octet-stream') {
    return FluentIcons.archive;
  } else if (mimeType.startsWith('audio/') ||
      mimeType.startsWith('application/x-mpegurl')) {
    return FluentIcons.music_in_collection;
  } else if (mimeType.startsWith('video/')) {
    return FluentIcons.my_movies_t_v;
  } else if (mimeType == 'image/gif') {
    return FluentIcons.gif;
  } else if (mimeType.startsWith('image/')) {
    return FluentIcons.photo2;
  } else {
    return FluentIcons.page_solid;
  }
}

String? getExtension(String path) {
  final mimeType = lookupMimeType(path);
  return mimeType;
}

String dateToMdyHma(DateTime date) {
  DateFormat formatter = DateFormat('MM/dd/yyyy hh:mm a');
  String formattedDate = formatter.format(date);
  return formattedDate;
}



extension ContextUtils on BuildContext {
  double get shortestSide {
    return MediaQuery.of(this).size.shortestSide;
  }

  double get screenWidth {
    return MediaQuery.of(this).size.width;
  }

  double get screenHeight {
    return MediaQuery.of(this).size.height;
  }

  double get screenAspect {
    return MediaQuery.of(this).size.aspectRatio;
  }

  double get longestSide {
    return MediaQuery.of(this).size.longestSide;
  }

  // ColorScheme get colorScheme {
  //   return Theme.of(this).colorScheme;
  // }

  ThemeData get themeData {
    return FluentTheme.of(this);
  }

  Typography get textTheme {
    return FluentTheme.of(this).typography;
  }

  IconThemeData get iconTheme {
    return FluentTheme.of(this).iconTheme;
  }

  void showSnackBar({
    required String message,
    Color? backgroundColor,
    Color? textColor,
    Color? iconColor,
    String iconName = 'info_circle',
  }) {
    showSnackbar(
      this,
      Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? themeData.snackbarTheme.decoration?.color,
        ),
        child: Row(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SizedBox(
                    width: screenWidth * .7,
                    child: Text(
                      message,
                      style: textTheme.body?.copyWith(color: textColor),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showErrorSnackBar({required String message}) {
    showSnackBar(
      message: message,
      iconColor: CupertinoColors.destructiveRed,
      textColor: CupertinoColors.destructiveRed,
      iconName: 'exclamation_triangle',
    );
  }

  void copyToClipboard({required String message, String label = "Text"}) {
    Clipboard.setData(
      ClipboardData(
        text: message,
      ),
    ).then(
      (_) {
        showSnackBar(
          message: "$label copied to clipboard",
        );
      },
    );
  }
}
