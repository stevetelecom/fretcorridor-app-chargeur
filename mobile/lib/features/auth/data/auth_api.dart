import 'package:dio/dio.dart';
import '../../../core/storage/secure_storage_service.dart';
import 'models/user_profile.dart';

class AuthApi {
  AuthApi(this._dio, this._secureStorage);

  final Dio _dio;
  final SecureStorageService _secureStorage;

  Future<UserProfile> register({
    required String accountType,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String pin,
    // Requis uniquement pour accountType == 'ENTREPRISE' (raison sociale,
    // cf. CDC UC-IDA-02 flux nominal etape 1). Null pour un particulier.
    String? companyName,
  }) async {
    final response = await _dio.post(
      '/api/auth/register',
      data: {
        'accountType': accountType,
        'firstName': firstName,
        'lastName': lastName,
        'phoneNumber': phoneNumber,
        'pin': pin,
        'companyName': ?companyName,
      },
    );
    return _persistAndReturnProfile(response.data);
  }

  Future<UserProfile> login({
    required String phoneNumber,
    required String pin,
  }) async {
    final response = await _dio.post(
      '/api/auth/login',
      data: {'phoneNumber': phoneNumber, 'pin': pin},
    );
    return _persistAndReturnProfile(response.data);
  }

  Future<void> logout() async {
    final refreshToken = await _secureStorage.readRefreshToken();
    if (refreshToken != null) {
      try {
        await _dio.post(
          '/api/auth/logout',
          data: {'refreshToken': refreshToken},
        );
      } catch (_) {
        // la deconnexion locale doit reussir meme si l'appel reseau echoue
      }
    }
    await _secureStorage.clear();
  }

  Future<UserProfile> _persistAndReturnProfile(
    Map<String, dynamic> data,
  ) async {
    await _secureStorage.saveTokens(
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
    );
    return UserProfile.fromJson(data['user']);
  }
}
