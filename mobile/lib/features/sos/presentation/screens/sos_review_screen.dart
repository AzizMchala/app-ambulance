import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../core/constants/emergency_numbers.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/failure_messages.dart';
import '../../../../core/services/dialer.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/sos_draft.dart';
import '../../domain/usecases/build_sos_draft.dart';
import '../../domain/usecases/get_sos_location.dart';
import '../controllers/sos_location_controller.dart';
import '../controllers/sos_submission_controller.dart';
import '../providers/sos_providers.dart';
import '../sos_paths.dart';
import '../widgets/location_status_card.dart';
import '../widgets/sos_status_style.dart';

/// Vérification avant envoi : localisation, adresse facultative ou obligatoire, confirmation explicite.
class SosReviewScreen extends ConsumerStatefulWidget {
  const SosReviewScreen({super.key});

  @override
  ConsumerState<SosReviewScreen> createState() => _SosReviewScreenState();
}

class _SosReviewScreenState extends ConsumerState<SosReviewScreen> {
  final _address = TextEditingController();
  final _addressFocus = FocusNode();
  bool _acceptStale = false;
  SosDraftIssue? _issue;

  @override
  void initState() {
    super.initState();
    // Le patient prépare une alerte : c'est le bon moment pour demander l'autorisation GPS.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sosLocationControllerProvider.notifier).prepareForSending();
    });
  }

  @override
  void dispose() {
    _address.dispose();
    _addressFocus.dispose();
    super.dispose();
  }

  SosLocationReading? get _reading {
    final s = ref.read(sosLocationControllerProvider);
    return s is LocationReady ? s.reading : null;
  }

  Future<void> _send() async {
    final l = AppLocalizations.of(context);
    final submission = ref.read(sosSubmissionControllerProvider.notifier);
    final result = ref.read(buildSosDraftProvider)(
      clientRequestId: submission.clientRequestId,
      reading: _reading,
      acceptStale: _acceptStale,
      address: _address.text,
    );
    switch (result) {
      case SosDraftInvalid(:final issue):
        setState(() => _issue = issue);
        _addressFocus.requestFocus();
        return;
      case SosDraftReady(:final draft):
        setState(() => _issue = null);
        final confirmed = await AppFeedback.confirm(
          context,
          title: l.confirmTitle,
          body: l.confirmBody,
          confirmLabel: l.confirmSend,
          cancelLabel: l.commonCancel,
          danger: true,
          content: _DraftSummary(draft: draft),
        );
        if (confirmed && mounted) await submission.submit(draft);
    }
  }

  String? _issueText(AppLocalizations l) => switch (_issue) {
    SosDraftIssue.addressRequired => l.reviewAddressRequired,
    SosDraftIssue.addressTooShort => l.reviewAddressTooShort,
    SosDraftIssue.addressTooLong => null,
    null => null,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final location = ref.watch(sosLocationControllerProvider);
    final locationCtrl = ref.read(sosLocationControllerProvider.notifier);
    final submission = ref.watch(sosSubmissionControllerProvider);

    ref.listen(sosSubmissionControllerProvider, (_, next) {
      if (next is SubmissionSucceeded) context.pushReplacement(SosPaths.detail(next.request.id, justSent: true));
    });

    final reading = location is LocationReady ? location.reading : null;
    final usableCoordinates = reading != null && (!reading.isStale || _acceptStale);
    final locating = location is LocationChecking || location is LocationAcquiring;
    final sending = submission is SubmissionSending || submission is SubmissionSucceeded;

    return Scaffold(
      appBar: AppBar(title: Text(l.reviewTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: AppSpace.x8),
          children: [
            ContentFrame(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.reviewIntro, style: context.text.bodyMedium),
                  const SizedBox(height: AppSpace.x5),
                  LocationStatusCard(
                    state: location,
                    onRetry: locationCtrl.refresh,
                    onAllow: () => locationCtrl.refresh(askPermission: true),
                    onOpenSettings: locationCtrl.openSettings,
                    mapHeight: 200,
                  ),
                  if (reading != null && reading.isStale) ...[
                    const SizedBox(height: AppSpace.x3),
                    AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpace.x2, vertical: AppSpace.x1),
                      child: CheckboxListTile(
                        value: _acceptStale,
                        onChanged: sending ? null : (v) => setState(() => _acceptStale = v ?? false),
                        title: Text(l.reviewUseStale, style: context.text.bodyLarge),
                        controlAffinity: ListTileControlAffinity.leading,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.lg)),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpace.x5),
                  TextField(
                    controller: _address,
                    focusNode: _addressFocus,
                    enabled: !sending,
                    maxLength: BuildSosDraft.maxAddressLength,
                    minLines: 1,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) {
                      if (_issue != null) setState(() => _issue = null);
                    },
                    decoration: InputDecoration(
                      labelText: l.reviewAddressLabel,
                      hintText: usableCoordinates ? l.reviewAddressHintGps : l.reviewAddressHintRequired,
                      errorText: _issueText(l),
                      prefixIcon: const Icon(PhosphorIconsLight.mapPinLine),
                    ),
                  ),
                  if (!usableCoordinates && !locating) ...[
                    const SizedBox(height: AppSpace.x2),
                    InlineNotice(tone: NoticeTone.warning, message: l.reviewNoCoordinates),
                  ],
                  if (submission is SubmissionFailed) ...[
                    const SizedBox(height: AppSpace.x4),
                    _SendFailure(failure: submission.failure),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: AppSpace.x3),
        child: ContentFrame(
          padding: const EdgeInsets.fromLTRB(AppSpace.gutter, AppSpace.x3, AppSpace.gutter, 0),
          child: ListenableBuilder(
            listenable: _address,
            builder: (context, _) => AppButton(
              label: sending ? l.reviewSending : l.reviewSend,
              icon: PhosphorIconsFill.siren,
              variant: AppButtonVariant.danger,
              loading: sending,
              // Pendant la recherche GPS, l'envoi reste possible dès qu'une adresse est saisie.
              onPressed: locating && _address.text.trim().isEmpty ? null : _send,
            ),
          ),
        ),
      ),
    );
  }
}

/// Récapitulatif dans la boîte de confirmation : exactement ce qui part au serveur.
class _DraftSummary extends StatelessWidget {
  const _DraftSummary({required this.draft});

  final SosDraft draft;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final loc = draft.location;
    return Container(
      padding: const EdgeInsets.all(AppSpace.x4),
      decoration: BoxDecoration(color: context.colors.canvas, borderRadius: BorderRadius.circular(AppRadius.md)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(loc.source!.icon, size: 18, color: context.colors.inkSoft),
              const SizedBox(width: AppSpace.x2),
              Expanded(child: Text(loc.source!.label(l), style: context.text.titleSmall)),
            ],
          ),
          if (loc.hasCoordinates) ...[
            const SizedBox(height: AppSpace.x2),
            Text(Formatters.coordinates(loc.latitude!, loc.longitude!), style: context.text.bodyMedium),
            if (loc.accuracyMeters != null)
              Text(l.locationAccuracy(loc.accuracyMeters!.round()), style: context.text.bodySmall),
          ],
          if (loc.hasAddress) ...[
            const SizedBox(height: AppSpace.x2),
            Text(loc.address!, style: context.text.bodyMedium),
          ],
        ],
      ),
    );
  }
}

class _SendFailure extends ConsumerWidget {
  const _SendFailure({required this.failure});

  final AppFailure failure;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final activeId = failure.code == 'SOS_ALREADY_ACTIVE' && failure is ApiFailure
        ? ((failure as ApiFailure).details['activeRequestId'] as num?)?.toInt()
        : null;
    final offline = failure is NetworkFailure || failure is ServerFailure;

    return InlineNotice(
      tone: NoticeTone.danger,
      title: activeId == null ? l.sendFailedTitle : null,
      message: offline
          ? '${failureMessage(l, failure)} ${l.sendFailedNetworkHint(EmergencyNumbers.samu)}'
          : failureMessage(l, failure),
      action: Wrap(
        spacing: AppSpace.x2,
        runSpacing: AppSpace.x2,
        children: [
          if (activeId != null)
            AppButton(
              label: l.sendViewActive,
              compact: true,
              expand: false,
              variant: AppButtonVariant.secondary,
              onPressed: () {
                ref.invalidate(latestSosProvider);
                context.pushReplacement(SosPaths.detail(activeId));
              },
            ),
          if (offline)
            AppButton(
              label: l.homeCall(EmergencyNumbers.samu),
              icon: PhosphorIconsLight.phoneCall,
              compact: true,
              expand: false,
              variant: AppButtonVariant.secondary,
              onPressed: () => openDialer(EmergencyNumbers.samu),
            ),
        ],
      ),
    );
  }
}
