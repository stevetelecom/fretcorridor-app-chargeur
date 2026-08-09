import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/session_provider.dart';
import '../data/models/payment.dart';
import '../data/payment_api.dart';

final paymentApiProvider = Provider((ref) => PaymentApi(ref.watch(dioClientProvider)));

class PaymentNotifier extends AsyncNotifier<Payment?> {
  @override
  Future<Payment?> build() async => null;

  Future<void> pay(String shipmentRequestId, String offerId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
        () => ref.read(paymentApiProvider).initiate(shipmentRequestId, offerId));
  }

  void reset() => state = const AsyncData(null);
}

final paymentProvider = AsyncNotifierProvider<PaymentNotifier, Payment?>(PaymentNotifier.new);
