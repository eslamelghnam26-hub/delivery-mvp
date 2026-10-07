import 'package:flutter/material.dart';
import '../api.dart';
import '../l10n.dart';
import '../models.dart';

class AuthScreen extends StatefulWidget {
  final ValueChanged<({String token, String role, String name, String lang})> onAuthed;
  final Api api;
  const AuthScreen({super.key, required this.onAuthed, required this.api});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  bool _register = false;
  bool _provider = false;
  bool _busy = false;
  bool _hidePass = true;
  String? _error;
  final String _lang = 'ar';

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
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
      dynamic res;
      if (_register) {
        res = await widget.api.post('/auth/register', {
          'name': _name.text.trim(),
          'phone': _phone.text.trim(),
          'email': _email.text.trim(),
          'password': _password.text,
          'role': _provider ? 'provider' : 'customer',
          'lang': _lang,
        });
      } else {
        res = await widget.api.post('/auth/login', {
          'phone': _phone.text.trim(),
          'password': _password.text,
        });
      }
      final map = res as Map<String, dynamic>;
      final token = map['token'] as String;
      final user = User.fromJson(map['user'] as Map<String, dynamic>);
      widget.onAuthed((
        token: token,
        role: user.role,
        name: user.name,
        lang: user.lang,
      ));
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'تعذر الاتصال بالخادم / Connection failed');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      height: 96,
                      alignment: Alignment.center,
                      child: Image.asset('assets/icon/logo_transparent.png', height: 96),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.appName,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, color: const Color(0xFF2563EB)),
                    ),
                    const SizedBox(height: 6),
                    Text(t.tagline, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(height: 24),
                    SegmentedButton<bool>(
                      segments: [
                        ButtonSegment(value: false, label: Text(t.iAmCustomer)),
                        ButtonSegment(value: true, label: Text(t.iAmProvider)),
                      ],
                      selected: {_provider},
                      onSelectionChanged: (s) => setState(() => _provider = s.first),
                    ),
                    const SizedBox(height: 16),
                    if (_register) ...[
                      TextFormField(
                        controller: _name,
                        decoration: InputDecoration(labelText: t.name, border: const OutlineInputBorder()),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 12),
                    ],
                    TextFormField(
                      controller: _phone,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: _register ? t.phone : '${t.phone} / email',
                        border: const OutlineInputBorder(),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    if (_register) ...[
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(labelText: 'Email (اختياري)', border: const OutlineInputBorder()),
                      ),
                    ],
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: _hidePass,
                      decoration: InputDecoration(
                        labelText: t.password,
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(_hidePass ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _hidePass = !_hidePass),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 6) ? 'Min 6 chars' : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 18),
                    FilledButton(
                      onPressed: _busy ? null : _submit,
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: _busy
                          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(_register ? t.register : t.login),
                    ),
                    const SizedBox(height: 10),
                    TextButton(
                      onPressed: _busy ? null : () => setState(() => _register = !_register),
                      child: Text(_register ? t.haveAccount : t.noAccount),
                    ),
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