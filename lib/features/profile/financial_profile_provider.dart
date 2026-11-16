import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FinancialProfileProvider extends ChangeNotifier {
  static const _nameKey = 'saldozen.profile.name';
  static const _focusKey = 'saldozen.profile.focus';
  static const _remindersKey = 'saldozen.profile.reminders';

  String _name = '';
  String _financialFocus = 'Organizar gastos';
  bool _remindersEnabled = true;

  String get name => _name;
  String get financialFocus => _financialFocus;
  bool get remindersEnabled => _remindersEnabled;
  bool get hasProfile => _name.isNotEmpty;

  Future<void> load() async {
    final preferences = await SharedPreferences.getInstance();
    _name = preferences.getString(_nameKey)?.trim() ?? '';
    _financialFocus = preferences.getString(_focusKey) ?? 'Organizar gastos';
    _remindersEnabled = preferences.getBool(_remindersKey) ?? true;
    notifyListeners();
  }

  Future<void> save({
    required String name,
    required String financialFocus,
    required bool remindersEnabled,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final savedName = await preferences.setString(_nameKey, name.trim());
    final savedFocus = await preferences.setString(_focusKey, financialFocus);
    final savedReminders = await preferences.setBool(
      _remindersKey,
      remindersEnabled,
    );
    if (!savedName || !savedFocus || !savedReminders) {
      throw Exception('Não foi possível salvar as preferências do perfil.');
    }

    _name = name.trim();
    _financialFocus = financialFocus;
    _remindersEnabled = remindersEnabled;
    notifyListeners();
  }
}
