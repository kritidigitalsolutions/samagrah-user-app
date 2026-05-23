import 'dart:io';
import 'package:dio/dio.dart';
import 'package:samagrah/res/app_urls.dart';

class ProfileApi {
  /// 🔥 Single Dio instance
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  /// 🔥 Update Profile API
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required String name,
    required String email,
    required String address,
    File? imageFile,
    required String token,
  }) async {
    try {
      /// 📦 Form Data
      final formData = FormData.fromMap({
        "name": name,
        "email": email,
        "address": address,

        /// 🖼 Image (optional)
        if (imageFile != null)
          "profileImage": await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last,
          ),
      });

      /// 🚀 API Call
      final response = await _dio.patch(
        "${AppUrls.editProfile}/$userId", // 🔁 change endpoint
        data: formData,
        options: Options(
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "multipart/form-data",
          },
        ),
      );

      return response.data;
    } on DioException catch (e) {
      ;

      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? "Server error");
      } else {
        throw Exception("No internet connection");
      }
    } catch (e) {
      throw Exception("Something went wrong");
    }
  }
}
