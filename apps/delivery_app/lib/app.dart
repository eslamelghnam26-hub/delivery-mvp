import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'api.dart';
import 'auth_store.dart';
import 'locale_controller.dart';
import 'screens/auth_screen.dart';
import 'screens/customer/home_screen.dart' as customer;
import 'screens/provider/home_screen.dart' as provider;

class App extends StatelessWidget {
  final String? forcedRole;
  const App({super.key, this.forcedRole});

  @override
  Widget build(BuildContext context) => AppBootstrap(forcedRole: forcedRole);
}

class AppBootstrap extends StatefulWidget {
  final String? forcedRole;
  const AppBootstrap({super.key, this.forcedRole});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  final AuthStore _store = AuthStore();
  late Future<String?> _tokenFuture;
  late final LocaleController _lang;

  @override
  void initState() {
    super.initState();
    _tokenFuture = _store.token();
    _lang = LocaleController(_store)..load();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _tokenFuture,
      builder: (context, tokSnap) {
        return ListenableBuilder(
          listenable: _lang,
          builder: (context, _) {
            return MaterialApp(
              title: 'Khadamaty',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2563EB)),
                useMaterial3: true,
              ),
              locale: Locale(_lang.code),
              supportedLocales: const [Locale('ar'), Locale('en'), Locale('fr'), Locale('es')],
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: Root(
                token: tokSnap.data,
                forcedRole: widget.forcedRole,
                lang: _lang,
              ),
            );
          },
        );
      },
    );
  }
}

class Root extends StatefulWidget {
  final String? token;
  final String? forcedRole;
  final LocaleController lang;
  const Root({super.key, this.token, this.forcedRole, required this.lang});

  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  late final AuthStore _store = AuthStore();
  String? _token;
  String _role = 'customer';
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _token = widget.token;
    _init();
  }

  Future<void> _init() async {
    final t = await _store.token();
    String r;
    if (widget.forcedRole != null) {
      r = widget.forcedRole!;
    } else {
      r = await _store.role();
    }
    if (mounted) {
      setState(() {
        _token = t;
        _role = r;
        _ready = true;
      });
    }
  }

  Future<void> _onAuthed(({String token, String role, String name, String lang}) s) async {
    await _store.saveSession(s.token, s.role, s.name, s.lang);
    widget.lang.set(s.lang);
    if (mounted) {
      setState(() {
        _token = s.token;
        _role = widget.forcedRole ?? s.role;
      });
    }
  }

  Future<void> _onLogout() async {
    await _store.clear();
    if (mounted) {
      setState(() => _token = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final api = Api();
    if (_token == null) {
      return AuthScreen(onAuthed: _onAuthed, api: api);
    }
    api.setToken(_token);
    if (_role == 'provider') {
      return provider.ProviderHomeScreen(
        key: ValueKey('provider-$_token'),
        api: api,
        store: _store,
        onLogout: _onLogout,
        forcedRole: widget.forcedRole,
        lang: widget.lang,
      );
    }
    return customer.CustomerHomeScreen(
      key: ValueKey('customer-$_token'),
      api: api,
      store: _store,
      onLogout: _onLogout,
      lang: widget.lang,
    );
  }
}