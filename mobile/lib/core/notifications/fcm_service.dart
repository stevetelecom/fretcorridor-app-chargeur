import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import '../widgets/app_toast.dart';

/// Enregistre le token FCM de l'appareil aupres du backend et affiche un
/// toast quand une notification arrive alors que l'app est au premier plan
/// (sinon, au premier plan, FCM n'affiche PAS de notification systeme -
/// comportement natif Android, pas un bug ; on compense avec un toast pour
/// que le chargeur voie quand meme le changement de statut).
class FcmService {
  FcmService(this._dio);

  final Dio _dio;

  /// A appeler juste apres un login/register reussi. Demande la permission
  /// (obligatoire depuis Android 13, no-op silencieux avant) puis envoie le
  /// token au backend. N'importe quelle erreur ici reste silencieuse pour
  /// l'utilisateur - une notification manquante n'est jamais bloquante pour
  /// utiliser l'app (meme principe fail-soft que cote backend).
  Future<void> registerToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();

      final token = await messaging.getToken();
      if (token != null) {
        await _sendTokenToBackend(token);
      }

      // Le token peut changer a tout moment (reinstallation, restauration
      // d'un backup, etc.) - on reecoute pour rester synchronise.
      messaging.onTokenRefresh.listen(_sendTokenToBackend);
    } catch (_) {
      // Volontairement silencieux - voir javadoc de la classe.
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      await _dio.post('/api/me/device-token', data: {'fcmToken': token});
    } catch (_) {
      // idem : jamais bloquant.
    }
  }

  /// A appeler une seule fois au demarrage de l'app (avant runApp), pour
  /// afficher un toast quand une notification arrive pendant que l'app est
  /// ouverte.
  static void listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final body = message.notification?.body;
      if (body != null) {
        AppToast.success(body);
      }
    });
  }
}


