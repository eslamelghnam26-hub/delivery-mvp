import 'package:flutter/material.dart';
import '../../api.dart';
import '../../l10n.dart';
import '../../models.dart';

class NewOrderScreen extends StatefulWidget {
  final Api api;
  final Service service;
  const NewOrderScreen({super.key, required this.api, required this.service});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final _address = TextEditingController();
  final _description = TextEditingController();
  bool _busy = false;
  double _lat = -1;
  double _lng = -1;
  String? _error;

  @override
  void dispose() {
    _address.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.service.id <= 0) {
      setState(() => _error = 'Invalid service');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.api.post('/orders', {
        'service_id': widget.service.id,
        'lat': _lat,
        'lng': _lng,
        'address': _address.text.trim(),
        'description': _description.text.trim(),
      });
      if (mounted) Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Connection failed / فشل الاتصال');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(title: Text('${t.newOrder} — ${t.ar ? widget.service.nameAr : widget.service.nameEn}'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 0,
            color: const Color(0xFF2563EB),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.place, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _lat < 0 ? t.locationFetchHint : 'lat: $_lat  lng: $_lng',
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _address,
            decoration: InputDecoration(labelText: t.address, border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _description,
            maxLines: 3,
            decoration: InputDecoration(labelText: t.description, border: const OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.my_location),
                  label: Text(t.useMyLocation),
                  onPressed: () {
                    setState(() {
                      _lat = 30.0444196;
                      _lng = 31.2357116;
                    });
                  },
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _busy ? null : _submit,
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            child: _busy
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(t.sendRequest),
          ),
        ],
      ),
    );
  }
}