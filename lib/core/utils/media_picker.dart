import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

/// Small wrapper around image_picker and file_picker with consistent
/// return types and MIME detection.
class PickedMedia {
  const PickedMedia({
    required this.path,
    required this.name,
    required this.size,
    this.mimeType,
  });

  final String path;
  final String name;
  final int size;
  final String? mimeType;

  String get sizeLabel {
    if (size < 1024) return '${size}B';
    if (size < 1024 * 1024) {
      return '${(size / 1024).toStringAsFixed(1)}KB';
    }
    return '${(size / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

class MediaPicker {
  MediaPicker._();

  static final ImagePicker _imagePicker = ImagePicker();

  /// Pick an image from gallery (or camera when [fromCamera] is true).
  static Future<PickedMedia?> pickImage({
    bool fromCamera = false,
  }) async {
    final XFile? file = await _imagePicker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 88,
      maxWidth: 2000,
    );
    if (file == null) return null;

    final size = await file.length();
    return PickedMedia(
      path: file.path,
      name: file.name,
      size: size,
      mimeType: lookupMimeType(file.path),
    );
  }

  /// Pick a single file, optionally restricted to a list of extensions.
  static Future<PickedMedia?> pickFile({
    List<String>? allowedExtensions,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: allowedExtensions == null
          ? FileType.any
          : FileType.custom,
      allowedExtensions: allowedExtensions,
      withData: false,
    );
    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    if (file.path == null) return null;

    return PickedMedia(
      path: file.path!,
      name: file.name,
      size: file.size,
      mimeType: lookupMimeType(file.path!) ??
          (allowedExtensions != null && allowedExtensions.isNotEmpty
              ? 'application/${allowedExtensions.first}'
              : null),
    );
  }
}