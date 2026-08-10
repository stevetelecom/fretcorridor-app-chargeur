import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/notifications/fcm_service.dart';
import '../../../core/storage/secure_storage_service.dart';
import '../data/auth_api.dart';
import '../data/models/user_profile.dart';

final secureStorageProvider = Provider((ref) => SecureStorageService());

final dioClientProvider = Provider((ref) {
  final storage = ref.watch(secureStorageProvider);
  // 10.0.2.2 = alias localhost depuis l'emulateur Android. A remplacer par
  // l'URL reelle du backend en production (flavor/variable d'env).
  return DioClient(storage, baseUrl: 'http://10.0.2.2:8080').dio;
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
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(authApiProvider).register(
          accountType: accountType,
          firstName: firstName,
          lastName: lastName,
          phoneNumber: phoneNumber,
          pin: pin,
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
