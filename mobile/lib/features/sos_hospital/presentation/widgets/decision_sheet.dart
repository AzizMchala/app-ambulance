import 'package:flutter/material.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_tokens.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/hospital_sos.dart';
import 'hospital_decision_style.dart';

/// Feuille de décision : message au patient (obligatoire pour un refus) puis confirmation explicite.
/// Renvoie le message saisi, ou `null` si l'équipe annule.
Future<String?> showDecisionSheet(BuildContext context, HospitalDecision decision) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => _DecisionSheet(decision: decision),
  );
}

class _DecisionSheet extends StatefulWidget {
  const _DecisionSheet({required this.decision});

  final HospitalDecision decision;

  @override
  State<_DecisionSheet> createState() => _DecisionSheetState();
}

class _DecisionSheetState extends State<_DecisionSheet> {
  final _message = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  void _confirm() {
    final l = AppLocalizations.of(context);
    if (widget.decision.requiresMessage && _message.text.trim().isEmpty) {
      setState(() => _error = l.hospitalMessageRequired);
      return;
    }
    Navigator.of(context).pop(_message.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final d = widget.decision;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpace.x6, 0, AppSpace.x6, AppSpace.x6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(header: true, child: Text(d.sheetTitle(l), style: context.text.headlineSmall)),
            const SizedBox(height: AppSpace.x2),
            Text(l.hospitalSheetBody, style: context.text.bodyMedium),
            const SizedBox(height: AppSpace.x5),
            TextField(
              controller: _message,
              autofocus: d.requiresMessage,
              minLines: 2,
              maxLines: 4,
              maxLength: 500,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              decoration: InputDecoration(
                labelText: l.hospitalMessageLabel,
                hintText: d.requiresMessage ? l.hospitalMessageHintRequired : l.hospitalMessageHintOptional,
                hintMaxLines: 2,
                errorText: _error,
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: AppSpace.x4),
            AppButton(label: d.label(l), icon: d.icon, variant: d.buttonVariant, onPressed: _confirm),
            const SizedBox(height: AppSpace.x2),
            AppButton(
              label: l.commonCancel,
              variant: AppButtonVariant.secondary,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}
