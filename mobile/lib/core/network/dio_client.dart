import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';

/// Client HTTP unique : ajoute automatiquement le header Authorization,
/// et en cas de 401 tente un refresh unique puis rejoue la requete. Si le
/// refresh echoue aussi, l'erreur remonte tel quel (SessionNotifier
/// redirige alors vers l'ecran de connexion).
class DioClient {
  DioClient(this._secureStorage, {required String baseUrl}) {
    // 90s : couvre le cas d'un cold start sur le plan gratuit Render
    // (le service s'endort apres inactivite et peut prendre jusqu'a
    // 2-3 min a se reveiller, observe en test). Trop court et la premiere
    // requete d'un utilisateur echoue systematiquement avant que le
    // backend ait fini de demarrer.
    dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 90),
      receiveTimeout: const Duration(seconds: 90),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.readAccessToken();
        if (token != null && !options.path.contains('/auth/')) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        final isUnauthorized = error.response?.statusCode == 401;
        final isRetry = error.requestOptions.extra['retried'] == true;

        if (isUnauthorized && !isRetry) {
          final refreshed = await _tryRefresh();
          if (refreshed) {
            final retryOptions = error.requestOptions..extra['retried'] = true;
            final newToken = await _secureStorage.readAccessToken();
            retryOptions.headers['Authorization'] = 'Bearer $newToken';
            try {
              final response = await dio.fetch(retryOptions);
              return handler.resolve(response);
            } catch (_) {
              // on retombe sur l'erreur d'origine si le rejeu echoue aussi
            }
          }
        }
        handler.next(error);
      },
    ));
  }

  final SecureStorageService _secureStorage;
  late final Dio dio;

  Future<bool> _tryRefresh() async {
    final refreshToken = await _secureStorage.readRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await Dio(BaseOptions(baseUrl: dio.options.baseUrl))
          .post('/api/auth/refresh', data: {'refreshToken': refreshToken});
      await _secureStorage.saveTokens(
        accessToken: response.data['accessToken'],
        refreshToken: response.data['refreshToken'],
      );
      return true;
    } catch (_) {
      await _secureStorage.clear();
      return false;
    }
  }
}
