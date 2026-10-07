import 'package:flutter/material.dart';
import '../api.dart';
import '../auth_store.dart';
import '../l10n.dart';
import '../locale_controller.dart';
import '../widgets/language_button.dart';

class ProfileScreen extends StatefulWidget {
  final Api api;
  final AuthStore store;
  final LocaleController lang;
  final Future<void> Function() onLogout;
  final String role;
  final bool canToggleOnline;
  const ProfileScreen({
    super.key,
    required this.api,
    required this.store,
    required this.lang,
    required this.onLogout,
    required this.role,
    this.canToggleOnline = false,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _busy = false;
  bool _online = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {}

  String _label(String code, AppStrings t) => switch (code) {
        'ar' => t.arabic,
        'fr' => t.french,
        'es' => t.spanish,
        _ => t.english,
      };

  Future<void> _toggleOnline(bool value) async {
    setState(() {
      _busy = true;
      _online = value;
    });
    try {
      await widget.api.post('/provider/status', {'is_online': value ? 1 : 0});
    } catch (_) {
      if (mounted) {
        setState(() => _online = !value);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update status')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _logout() async {
    try {
      await widget.api.post('/auth/logout');
    } catch (_) {}
    await widget.onLogout();
  }

  void _pickLang(String code) {
    widget.lang.set(code);
    widget.api.put('/profile', {'lang': code});
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.profile), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person)),
            title: Text(widget.role == 'provider' ? 'Provider' : 'Customer'),
            subtitle: Text('${widget.role} account'),
          ),
          if (widget.canToggleOnline)
            SwitchListTile(
              title: Text(_online ? t.goAvailable : t.goOffline),
              subtitle: Text(_online ? 'Online / متاح' : 'Offline / غير متاح'),
              value: _online,
              onChanged: _busy ? null : _toggleOnline,
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(t.language),
            subtitle: Text(_label(widget.lang.code, t)),
          ),
          for (final (code, _) in kLanguages)
            ListTile(
              dense: true,
              contentPadding: const EdgeInsets.only(left: 40, right: 16),
              leading: Icon(
                code == widget.lang.code ? Icons.check_circle : Icons.circle_outlined,
                color: code == widget.lang.code ? const Color(0xFF2563EB) : Colors.grey,
              ),
              title: Text(_label(code, t)),
              onTap: () => _pickLang(code),
            ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(t.logout),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}