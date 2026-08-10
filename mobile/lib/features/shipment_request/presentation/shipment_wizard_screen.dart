import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/common/api_exception.dart';
import 'package:dio/dio.dart';
import '../providers/shipment_providers.dart';
import 'steps/step_where.dart';
import 'steps/step_what_how_much.dart';
import 'steps/step_when_how_who.dart';
import 'steps/step_recap.dart';

/// Assistant de publication d'une demande (UC-MKT-01). Le brouillon est lu/
/// ecrit via shipmentDraftProvider - chaque etape modifie une tranche du
/// meme etat partage, persiste automatiquement (voir ShipmentDraftNotifier).
class ShipmentWizardScreen extends ConsumerStatefulWidget {
  const ShipmentWizardScreen({super.key});

  @override
  ConsumerState<ShipmentWizardScreen> createState() => _ShipmentWizardScreenState();
}

class _ShipmentWizardScreenState extends ConsumerState<ShipmentWizardScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _stepTitles = ['Où', 'Quoi', 'Quand', 'Récap'];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _publish() async {
    await ref.read(shipmentSubmissionProvider.notifier).submit();
    if (!mounted) return;

    final result = ref.read(shipmentSubmissionProvider);
    result.whenOrNull(
      data: (data) {
        if (data != null) {
          AppToast.success('Demande publiée avec succès');
          context.go('/home');
        }
      },
      error: (error, _) => AppToast.error(_readableError(error)),
    );
  }

  String _readableError(Object error) {
    if (error is DraftIncompleteException) {
      return 'Certains champs obligatoires sont manquants. Revenez en arrière.';
    }
    if (error is DioException && error.response?.data is Map) {
      final message = error.response!.data['message'];
      if (message is String) return message;
    }
    return 'Erreur lors de la publication. Réessayez.';
  }

  @override
  Widget build(BuildContext context) {
    final submission = ref.watch(shipmentSubmissionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouvelle demande'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: (_currentPage + 1) / _stepTitles.length,
            backgroundColor: Colors.grey.shade200,
            color: AppColors.primary,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Étape ${_currentPage + 1}/${_stepTitles.length} — ${_stepTitles[_currentPage]}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // navigation via boutons uniquement
              onPageChanged: (index) => setState(() => _currentPage = index),
              children: const [
                StepWhere(),
                StepWhatHowMuch(),
                StepWhenHowWho(),
                StepRecap(),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _goToPage(_currentPage - 1),
                        child: const Text('Précédent'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton(
                      onPressed: submission.isLoading
                          ? null
                          : () {
                              if (_currentPage < _stepTitles.length - 1) {
                                _goToPage(_currentPage + 1);
                              } else {
                                _publish();
                              }
                            },
                      child: submission.isLoading
                          ? const SizedBox(
                              height: 20, width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(_currentPage < _stepTitles.length - 1 ? 'Suivant' : 'Publier la demande'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
