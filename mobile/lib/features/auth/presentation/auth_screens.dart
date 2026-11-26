import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../app/theme/app_colors.dart';
import '../../../app/theme/app_tokens.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/errors/failure_messages.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/widgets.dart';
import 'session_controller.dart';

/// Écrans de connexion et d'inscription, partagés par toute l'application.
/// Volontairement minimalistes : le module E1 (profil patient) les enrichira.

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(sessionControllerProvider.notifier).login(_email.text, _password.text);
    } on AppFailure catch (f) {
      if (mounted) setState(() => _error = failureMessage(AppLocalizations.of(context), f));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _AuthScaffold(
      title: l.authLoginTitle,
      subtitle: l.authLoginSubtitle,
      form: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _EmailField(controller: _email),
            const SizedBox(height: AppSpace.x4),
            _PasswordField(controller: _password, onSubmitted: _submit),
            if (_error != null) ...[
              const SizedBox(height: AppSpace.x4),
              InlineNotice(tone: NoticeTone.danger, message: _error!),
            ],
            const SizedBox(height: AppSpace.x6),
            AppButton(label: l.authLoginAction, loading: _busy, onPressed: _submit),
            const SizedBox(height: AppSpace.x3),
            AppButton(
              label: '${l.authNoAccount} ${l.authCreateAccount}',
              variant: AppButtonVariant.ghost,
              onPressed: _busy ? null : () => context.go('/register'),
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(sessionControllerProvider.notifier).register(_name.text, _email.text, _password.text);
    } on AppFailure catch (f) {
      if (mounted) setState(() => _error = failureMessage(AppLocalizations.of(context), f));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return _AuthScaffold(
      title: l.authRegisterTitle,
      subtitle: l.authRegisterSubtitle,
      form: Form(
        key: _form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.name],
              maxLength: 120,
              decoration: InputDecoration(
                labelText: l.authFullName,
                prefixIcon: const Icon(PhosphorIconsLight.user),
                counterText: '',
              ),
              validator: (v) => (v == null || v.trim().length < 2) ? l.authFieldRequired : null,
            ),
            const SizedBox(height: AppSpace.x4),
            _EmailField(controller: _email),
            const SizedBox(height: AppSpace.x4),
            _PasswordField(controller: _password, onSubmitted: _submit, checkLength: true),
            if (_error != null) ...[
              const SizedBox(height: AppSpace.x4),
              InlineNotice(tone: NoticeTone.danger, message: _error!),
            ],
            const SizedBox(height: AppSpace.x6),
            AppButton(label: l.authRegisterAction, loading: _busy, onPressed: _submit),
            const SizedBox(height: AppSpace.x3),
            AppButton(
              label: '${l.authHaveAccount} ${l.authLoginAction}',
              variant: AppButtonVariant.ghost,
              onPressed: _busy ? null : () => context.go('/login'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthScaffold extends StatelessWidget {
  const _AuthScaffold({required this.title, required this.subtitle, required this.form});

  final String title;
  final String subtitle;
  final Widget form;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: AppSpace.x8),
            child: ContentFrame(
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: c.dangerTint,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                        ),
                        child: Icon(PhosphorIconsFill.firstAidKit, color: c.danger, size: 28),
                      ),
                    ),
                    const SizedBox(height: AppSpace.x6),
                    Text(title, style: context.text.displayMedium),
                    const SizedBox(height: AppSpace.x2),
                    Text(subtitle, style: context.text.bodyMedium),
                    const SizedBox(height: AppSpace.x8),
                    form,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmailField extends StatelessWidget {
  const _EmailField({required this.controller});

  final TextEditingController controller;

  static final _pattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autofillHints: const [AutofillHints.email],
      autocorrect: false,
      decoration: InputDecoration(labelText: l.authEmail, prefixIcon: const Icon(PhosphorIconsLight.envelopeSimple)),
      validator: (v) {
        final value = v?.trim() ?? '';
        if (value.isEmpty) return l.authFieldRequired;
        return _pattern.hasMatch(value) ? null : l.authEmailInvalid;
      },
    );
  }
}

class _PasswordField extends StatefulWidget {
  const _PasswordField({required this.controller, required this.onSubmitted, this.checkLength = false});

  final TextEditingController controller;
  final VoidCallback onSubmitted;
  final bool checkLength;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return TextFormField(
      controller: widget.controller,
      obscureText: _hidden,
      textInputAction: TextInputAction.done,
      autofillHints: [widget.checkLength ? AutofillHints.newPassword : AutofillHints.password],
      onFieldSubmitted: (_) => widget.onSubmitted(),
      decoration: InputDecoration(
        labelText: l.authPassword,
        prefixIcon: const Icon(PhosphorIconsLight.lockSimple),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _hidden = !_hidden),
          icon: Icon(_hidden ? PhosphorIconsLight.eye : PhosphorIconsLight.eyeSlash),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return l.authFieldRequired;
        if (widget.checkLength && v.length < 8) return l.authPasswordTooShort;
        return null;
      },
    );
  }
}
