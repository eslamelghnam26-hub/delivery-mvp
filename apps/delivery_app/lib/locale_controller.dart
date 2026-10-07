import 'package:flutter/foundation.dart';
import 'auth_store.dart';

class LocaleController extends ChangeNotifier {
  LocaleController(this._store);
  final AuthStore _store;
  String code = 'ar';

  Future<void> load() async {
    code = await _store.lang();
    notifyListeners();
  }

  void set(String c) {
    if (code == c) return;
    code = c;
    _store.setLang(c);
    notifyListeners();
  }
}