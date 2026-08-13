import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/notifications/fcm_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../data/auth_api.dart';
import '../data/models/user_profile.dart';

final secureStorageProvider = Provider((ref) => SecureStorageService());

// URL du backend injectee au build via --dart-define=API_BASE_URL=...
// (voir CI mobile-ci.yml). Fallback sur l'IP locale de dev si absent,
// pratique pour `flutter run` sans argument pendant le developpement -
// mais TOUJOURS fournie explicitement en CI/release, jamais cette valeur
// par defaut qui casse a chaque changement de reseau local.
const _apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://fretcorridor-app-chargeur.onrender.com',
);

final dioClientProvider = Provider((ref) {
  final storage = ref.watch(secureStorageProvider);
  return DioClient(storage, baseUrl: _apiBaseUrl).dio;
});

final authApiProvider = Provider((ref) {
  final dio = ref.watch(dioClientProvider);
  final storage = ref.watch(secureStorageProvider);
  return AuthApi(dio, storage);
});

final fcmServiceProvider = Provider((ref) => FcmService(ref.watch(dioClientProvider)));

class SessionNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async => null;

  Future<void> register({
    required String accountType,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required String pin,
    String? companyName,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(authApiProvider).register(
          accountType: accountType,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          pin: pin,
          companyName: companyName,
        ));
    if (state.hasValue && state.value != null) {
      // Ne bloque jamais l'inscription - voir FcmService.registerToken.
      unawaited(ref.read(fcmServiceProvider).registerToken());
    }
  }

  Future<void> login({required String phoneNumber, required String pin}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(authApiProvider).login(phoneNumber: phoneNumber, pin: pin));
    if (state.hasValue && state.value != null) {
      unawaited(ref.read(fcmServiceProvider).registerToken());
    }
  }

  Future<void> logout() async {
    await ref.read(authApiProvider).logout();
    state = const AsyncData(null);
  }
}

final sessionProvider = AsyncNotifierProvider<SessionNotifier, UserProfile?>(SessionNotifier.new);
