import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nmail_core/l10n/generated/app_localizations.dart';
import 'package:path/path.dart' as p;

/// Format file size in human-readable format
String formatFileSize(int bytes, AppLocalizations l) {
  final format = NumberFormat('0.0', l.localeName);
  if (bytes < 1024) {
    return l.fileSizeBytes('$bytes');
  } else if (bytes < 1024 * 1024) {
    return l.fileSizeKilobytes(format.format(bytes / 1024));
  } else if (bytes < 1024 * 1024 * 1024) {
    return l.fileSizeMegabytes(format.format(bytes / (1024 * 1024)));
  } else {
    return l.fileSizeGigabytes(format.format(bytes / (1024 * 1024 * 1024)));
  }
}

/// Check if a file is an image based on its extension
bool isImageFile(String filename) {
  final extension = p.extension(filename).toLowerCase();
  return [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.webp',
    '.ico',
  ].contains(extension);
}

/// Check if a file is a PDF based on its extension
bool isPdfFile(String filename) {
  final extension = p.extension(filename).toLowerCase();
  return extension == '.pdf';
}

/// Get the appropriate icon for an attachment based on its file extension
IconData getAttachmentIcon(String filename) {
  final extension = p.extension(filename).toLowerCase();

  // Images
  if ([
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
    '.bmp',
    '.webp',
    '.svg',
    '.ico',
  ].contains(extension)) {
    return Icons.image;
  }

  // PDF
  if (extension == '.pdf') {
    return Icons.picture_as_pdf;
  }

  // Documents
  if (['.doc', '.docx', '.txt', '.rtf', '.odt', '.pages'].contains(extension)) {
    return Icons.description;
  }

  // Spreadsheets
  if (['.xls', '.xlsx', '.csv', '.ods', '.numbers'].contains(extension)) {
    return Icons.table_chart;
  }

  // Presentations
  if (['.ppt', '.pptx', '.odp', '.key'].contains(extension)) {
    return Icons.slideshow;
  }

  // Archives
  if (['.zip', '.rar', '.7z', '.tar', '.gz', '.bz2'].contains(extension)) {
    return Icons.folder_zip;
  }

  // Audio
  if ([
    '.mp3',
    '.wav',
    '.ogg',
    '.flac',
    '.aac',
    '.m4a',
    '.wma',
  ].contains(extension)) {
    return Icons.audio_file;
  }

  // Video
  if ([
    '.mp4',
    '.avi',
    '.mkv',
    '.mov',
    '.wmv',
    '.flv',
    '.webm',
  ].contains(extension)) {
    return Icons.video_file;
  }

  // Code
  if ([
    '.js',
    '.ts',
    '.py',
    '.java',
    '.c',
    '.cpp',
    '.h',
    '.hpp',
    '.cs',
    '.php',
    '.rb',
    '.go',
    '.rs',
    '.swift',
    '.kt',
    '.dart',
    '.html',
    '.css',
    '.json',
    '.xml',
    '.yaml',
    '.yml',
  ].contains(extension)) {
    return Icons.code;
  }

  // Default attachment icon
  return Icons.attach_file;
}
