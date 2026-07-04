import 'package:file_saver/file_saver.dart';

MimeType getMimeType(String extension) {
  switch (extension) {
    case 'pdf':
      return MimeType.pdf;
    case 'jpg':
    case 'jpeg':
      return MimeType.jpeg;
    case 'png':
      return MimeType.png;
    case 'gif':
      return MimeType.gif;
    case 'webp':
      return MimeType.webp;
    case 'txt':
      return MimeType.text;
    case 'xml':
      return MimeType.xml;
    case 'json':
      return MimeType.json;
    case 'zip':
      return MimeType.zip;
    default:
      return MimeType.other;
  }
}
