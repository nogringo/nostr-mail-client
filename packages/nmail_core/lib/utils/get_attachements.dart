import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

/// Format file size in human-readable format
String formatFileSize(int bytes) {
  if (bytes < 1024) {
    return '$bytes B';
  } else if (bytes < 1024 * 1024) {
    final kb = (bytes / 1024).toStringAsFixed(1);
    return '$kb KB';
  } else if (bytes < 1024 * 1024 * 1024) {
    final mb = (bytes / (1024 * 1024)).toStringAsFixed(1);
    return '$mb MB';
  } else {
    final gb = (bytes / (1024 * 1024 * 1024)).toStringAsFixed(1);
    return '$gb GB';
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
