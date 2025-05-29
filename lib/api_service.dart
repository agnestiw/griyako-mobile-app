import 'dart:convert';
import 'package:http/http.dart' as http;
import 'login_response.dart';
import 'register_response.dart';

class ApiService {
  static const String baseUrl =
      'http://127.0.0.1:8000';

  static Future<LoginResponse> loginUser(String email, String password) async {
    final String apiUrl = '$baseUrl/api/login';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 401) {
        final Map<String, dynamic> data;

        try {
          data = jsonDecode(response.body);
        } catch (e) {
          throw Exception('Gagal menguraikan respon JSON dari server.');
        }

        // Cek apakah ada pesan error dari Laravel (meskipun status 401)
        if (data.containsKey('message') && response.statusCode != 200) {
          final errorDetails =
              data['errors'] != null ? data['errors'].toString() : '';
          throw Exception('Login gagal: ${data['message']}\n$errorDetails');
        }

        try {
          return LoginResponse.fromJson(data);
        } catch (e) {
          throw Exception('Gagal memproses data login: ${e.toString()}');
        }
      } else {
        throw Exception('Gagal login: Server error (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  static Future<RegisterResponse> registerUser({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final String apiUrl = '$baseUrl/api/register';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': confirmPassword,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 422) {
        final Map<String, dynamic> data;

        try {
          data = jsonDecode(response.body);
        } catch (e) {
          throw Exception('Gagal menguraikan respon JSON dari server.');
        }

        if (response.statusCode == 422) {
          final errorMessage = data['message'] ?? 'Validasi gagal.';
          String errorDetails = '';

          if (data['errors'] != null && data['errors'] is Map) {
            data['errors'].forEach((key, value) {
              if (value is List) {
                for (var msg in value) {
                  errorDetails += '- $msg\n';
                }
              } else {
                errorDetails += '- $value\n';
              }
            });
          }

          throw Exception('Pendaftaran gagal: $errorMessage\n$errorDetails');
        }

        try {
          return RegisterResponse.fromJson(data);
        } catch (e) {
          throw Exception('Gagal memproses data pendaftaran: ${e.toString()}');
        }
      } else {
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          final errorMessage =
              errorData['message'] ?? 'Terjadi kesalahan pada server.';
          final errorDetails =
              errorData['errors'] != null ? errorData['errors'].toString() : '';

          throw Exception(
            'Gagal mendaftar: ${response.statusCode}\n$errorMessage\n$errorDetails',
          );
        } catch (e) {
          throw Exception(
            'Gagal mendaftar: Server error (${response.statusCode}). Tidak dapat menguraikan detail kesalahan.',
          );
        }
      }
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }
}
