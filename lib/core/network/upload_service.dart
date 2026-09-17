import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../errors/api_exception.dart';
import 'api_client.dart';

class UploadService {
  UploadService._();
  static final UploadService instance = UploadService._();

  final ApiClient _client = ApiClient.instance;

  Future<Map<String, dynamic>> uploadFile({
    required String path,
    required String fieldName,
    required String filePath,
    required String fileName,
    String? mimeType,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final multipart = await MultipartFile.fromFile(
        filePath,
        filename: fileName,
        contentType: mimeType != null && mimeType.isNotEmpty
            ? MediaType.parse(mimeType)
            : null,
      );

      final formData = FormData.fromMap({fieldName: multipart});

      final res = await _client.upload<Map<String, dynamic>>(
        path,
        formData: formData,
        onSendProgress: onSendProgress,
      );
      return res;
    } on DioException catch (e) {
      throw ApiException.from(e.error ?? e);
    }
  }

  Future<void> deleteResource(String path) async {
    await _client.delete<dynamic>(path);
  }
}