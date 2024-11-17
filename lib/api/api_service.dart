import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000/users'));

  Future<Map<String, dynamic>?> signup(String name, String email,
      String password, int age, String gender) async {
    try {
      final response = await _dio.post('/signup', data: {
        'name': name,
        'email': email,
        'password': password,
        'age': age,
        'gender': gender,
      });
      if (response.statusCode == 200) {
        print(response.data);
        return {
          'name': name,
          'email': email,
          'password': response.data['password'],
          'age': age,
          'gender': gender,
          'user_id': response.data['user_id']
        };
      }
    } on DioException catch (e) {
      // Fluttertoast.showToast(msg: "Signup failed: ${e.response?.data['error'] ?? e.message}");
      return null;
    }
  }

  Future<Map<String, dynamic>?> signin(String email, String password) async {
    try {
      final response = await _dio.post('/signin', data: {
        'email': email,
        'password': password,
      });
      if (response.statusCode == 200) {
        final accessToken = response.data['access_token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);
        return {
          'name': response.data['name'],
          'email': email,
          'password': response.data['password'],
          'age': response.data['age'],
          'gender': response.data['gender'],
          'user_id': response.data['user_id']
        };
      }
    } on DioException catch (e) {
      Fluttertoast.showToast(
          msg: "Signin failed: ${e.response?.data['error'] ?? e.message}");
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchUserProfile(
      String userId, String token) async {
    try {
      final response = await _dio.get('/profile/$userId',
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ));
      return response.data;
    } on DioException catch (e) {
      Fluttertoast.showToast(msg: "Failed to fetch profile: ${e.message}");
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateUserProfile(
      String userId, String name, int age, String gender, String email) async {
    try {
      final response = await _dio.put(
        '/update/$userId',
        data: {
          'email': email,
          'name': name,
          'age': age,
          'gender': gender,
        },
      );
      if (response.statusCode == 200) {
        return {
          'name': name,
          'email': email,
          'age': age,
          'gender': gender,
        };
      }
    } on DioException catch (e) {
      Fluttertoast.showToast(msg: "Profile update failed: ${e.message}");
      return null;
    }
  }

  // Fetch Access Token from SharedPreferences
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<Map<String, dynamic>?> getUserChats(String userId) async {
    try {
      final response = await _dio.post('/chats/$userId');
      if (response.statusCode == 200) {
        return {"messages": response.data['messages']};
      }
    } on DioException catch (e) {
      Fluttertoast.showToast(msg: "Failed to fetch chats: ${e.message}");
      return null;
    }
  }
   Future<String?> analyzeImage(XFile imageFile) async {
    try {
      MultipartFile multipartFile;

      // Use `XFile`'s `readAsBytes` method directly for both mobile and web.
      multipartFile = MultipartFile.fromBytes(
        await imageFile.readAsBytes(),
        filename: imageFile.name,
      );

      FormData formData = FormData.fromMap({
        "file": multipartFile,
      });

      Response response = await _dio.post(
        "/analyze-image",
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );

      if (response.statusCode == 200) {
        return response.data["result"];
      } else {
        throw Exception("Failed to analyze image. Status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      if (e.response != null) {
        return e.response?.data["detail"] ?? "Unknown error";
      } else {
        return "Error: ${e.message}";
      }
    }
  }
}
