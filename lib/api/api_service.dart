import 'package:dio/dio.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://127.0.0.1:8000/users'));

  Future<Map<String, dynamic>?> signup(String name, String email,
      String password,int age,String gender ) async {
    try {
      final response = await _dio.post('/signup', data: {
        'name': name,
        'email': email,
        'password': password,
        'age': age,
        'gender': gender,
      });
      if (response.statusCode==200){
        print(response.data);
        return {
        'name': name,
        'email': email,
        'password': response.data['password'],
        'age': age,
        'gender': gender,
        'user_id':response.data['user_id']
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
      return response.data;
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
      String userId, String name, int age, String gender, String token) async {
    try {
      final response = await _dio.put('/profile/$userId',
          data: {
            'name': name,
            'age': age,
            'gender': gender,
          },
          options: Options(
            headers: {'Authorization': 'Bearer $token'},
          ));
      return response.data;
    } on DioException catch (e) {
      Fluttertoast.showToast(msg: "Profile update failed: ${e.message}");
      return null;
    }
  }
}
