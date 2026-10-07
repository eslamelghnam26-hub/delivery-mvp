import 'package:shared_preferences/shared_preferences.dart';

class AuthStore {
  static const _kToken = 'token';
  static const _kLang = 'lang';
  static const _kRole = 'role';
  static const _kName = 'name';
  static const _kBase = 'api_base';

  Future<void> saveSession(String token, String role, String name, String lang) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kToken, token);
    await p.setString(_kRole, role);
    await p.setString(_kName, name);
    await p.setString(_kLang, lang);
  }

  Future<void> clear() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_kToken);
    await p.remove(_kRole);
    await p.remove(_kName);
  }

  Future<String?> token() async => (await SharedPreferences.getInstance()).getString(_kToken);
  Future<String> role() async => (await SharedPreferences.getInstance()).getString(_kRole) ?? 'customer';
  Future<String> name() async => (await SharedPreferences.getInstance()).getString(_kName) ?? '';
  Future<String> lang() async => (await SharedPreferences.getInstance()).getString(_kLang) ?? 'ar';

  Future<void> setLang(String lang) async {
    await (await SharedPreferences.getInstance()).setString(_kLang, lang);
  }

  Future<void> saveBase(String base) async {
    await (await SharedPreferences.getInstance()).setString(_kBase, base);
  }

  Future<String?> base() async => (await SharedPreferences.getInstance()).getString(_kBase);
}