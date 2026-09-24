import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  PrefsService._();
  static final PrefsService instance = PrefsService._();
  SharedPreferences? _prefs;

  Future<SharedPreferences> get _p async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<bool> getDarkMode() async => (await _p).getBool('darkMode') ?? true;
  Future<void> setDarkMode(bool v) async => (await _p).setBool('darkMode', v);
  Future<String> getLanguage() async => (await _p).getString('language') ?? 'en';
  Future<void> setLanguage(String v) async => (await _p).setString('language', v);
  Future<double> getBudgetLimit() async => (await _p).getDouble('budgetLimit') ?? 2000000;
  Future<void> setBudgetLimit(double v) async => (await _p).setDouble('budgetLimit', v);
  Future<double> getSavingsTarget() async => (await _p).getDouble('savingsTarget') ?? 5000000;
  Future<void> setSavingsTarget(double v) async => (await _p).setDouble('savingsTarget', v);
  Future<double> getCurrentSavings() async => (await _p).getDouble('currentSavings') ?? 0;
  Future<void> setCurrentSavings(double v) async => (await _p).setDouble('currentSavings', v);
}
