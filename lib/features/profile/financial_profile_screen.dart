import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../home/home_page.dart';
import 'financial_profile_provider.dart';

class FinancialProfileScreen extends StatefulWidget {
  const FinancialProfileScreen({super.key, this.editing = false});

  final bool editing;

  @override
  State<FinancialProfileScreen> createState() => _FinancialProfileScreenState();
}

class _FinancialProfileScreenState extends State<FinancialProfileScreen> {
  static const _financialFocusOptions = [
    'Organizar gastos',
    'Economizar',
    'Quitar dívidas',
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late String _financialFocus;
  late bool _remindersEnabled;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<FinancialProfileProvider>();
    _nameController = TextEditingController(text: profile.name);
    _financialFocus = profile.financialFocus;
    _remindersEnabled = profile.remindersEnabled;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await context.read<FinancialProfileProvider>().save(
        name: _nameController.text,
        financialFocus: _financialFocus,
        remindersEnabled: _remindersEnabled,
      );
      if (!mounted) return;
      if (widget.editing) {
        Navigator.of(context).pop();
      } else {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      }
    } on Exception {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'Não foi possível salvar seu perfil. Tente novamente.',
              ),
            ),
          );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.editing
          ? AppBar(title: const Text('Perfil financeiro'))
          : null,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.account_circle_outlined,
                    color: Color(0xFF4CAF58),
                    size: 64,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.editing ? 'Seu perfil financeiro' : 'Vamos começar',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF193B20),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Personalize sua experiência no SaldoZen.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge
                        ?.copyWith(color: const Color(0xFF718071)),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    key: const Key('profile-name'),
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Como podemos chamar você?',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Informe seu nome.'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    key: const Key('profile-financial-focus'),
                    initialValue: _financialFocus,
                    decoration: const InputDecoration(
                      labelText: 'Seu foco financeiro',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      for (final option in _financialFocusOptions)
                        DropdownMenuItem(value: option, child: Text(option)),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _financialFocus = value);
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Receber lembretes financeiros'),
                    value: _remindersEnabled,
                    activeTrackColor: const Color(0xFF4CAF58),
                    onChanged: (value) =>
                        setState(() => _remindersEnabled = value),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF58),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _saving
                          ? 'Salvando...'
                          : widget.editing
                          ? 'Salvar perfil'
                          : 'Continuar',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
