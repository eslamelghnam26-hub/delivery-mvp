import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../api.dart';
import '../../l10n.dart';
import '../../models.dart';
import '../../widgets/order_widgets.dart';

class OrderWorkScreen extends StatefulWidget {
  final Api api;
  final int orderId;
  final bool isAvailable;
  const OrderWorkScreen({super.key, required this.api, required this.orderId, this.isAvailable = false});

  @override
  State<OrderWorkScreen> createState() => _OrderWorkScreenState();
}

class _OrderWorkScreenState extends State<OrderWorkScreen> {
  Order? _order;
  bool _loading = true;
  String? _error;
  bool _busy = false;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _refresh();
    _ticker = Timer.periodic(const Duration(seconds: 5), (_) => _refresh(silent: true));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _refresh({bool silent = false}) async {
    try {
      final list = await widget.api.getList(widget.isAvailable ? '/orders?status=available' : '/orders');
      final mine = list.firstWhere((e) => (e as Map<String, dynamic>)['id'] == widget.orderId,
          orElse: () => throw const ApiException(404, 'not found'));
      if (!mounted) return;
      setState(() {
        _order = Order.fromJson(mine as Map<String, dynamic>);
        _loading = false;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!silent && mounted) {
        setState(() {
          _loading = false;
          _error = e.message;
        });
      }
    } catch (_) {
      if (!silent && mounted) {
        setState(() {
          _loading = false;
          _error = 'Connection failed';
        });
      }
    }
  }

  Future<void> _act(String path, {Map<String, dynamic>? body, String? success}) async {
    setState(() => _busy = true);
    try {
      await widget.api.post(path, body);
      if (success != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(success)));
      }
      _refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openMaps() {
    final o = _order;
    if (o == null) return;
    launchUrl(Uri.parse('https://www.google.com/maps/search/?api=1&query=${o.lat},${o.lng}'), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final o = _order;
    return Scaffold(
      appBar: AppBar(title: Text('${t.orderNoLabel} #${o?.orderNo ?? widget.orderId}'), centerTitle: true),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : o == null
              ? Center(child: Text(_error ?? 'Error'))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(children: [Text('#${o.orderNo}', style: const TextStyle(fontWeight: FontWeight.w800)), const Spacer(), StatusBadge(status: o.status)]),
                            const SizedBox(height: 10),
                            Text(o.address ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                            if (o.description != null && o.description!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(o.description ?? '', style: TextStyle(color: Colors.grey.shade600)),
                            ],
                            const SizedBox(height: 10),
                            Row(children: [
                              const Icon(Icons.place, size: 18, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text('${o.lat}, ${o.lng}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                              const Spacer(),
                              IconButton(icon: const Icon(Icons.map), onPressed: _openMaps),
                            ]),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (o.status == 'pending')
                      FilledButton.icon(
                        onPressed: _busy ? null : () => _act('/orders/${widget.orderId}/accept', success: t.accepted),
                        icon: const Icon(Icons.check),
                        label: Text(t.accept),
                      ),
                    if (o.status == 'accepted')
                      FilledButton.icon(
                        onPressed: _busy ? null : () => _act('/orders/${widget.orderId}/status', body: {'status': 'on_the_way'}, success: t.statusUpdated),
                        icon: const Icon(Icons.directions_car),
                        label: Text('بدء الرحلة / Set in motion'),
                      ),
                    if (o.status == 'on_the_way')
                      FilledButton.icon(
                        onPressed: _busy ? null : () => _act('/orders/${widget.orderId}/status', body: {'status': 'in_service'}, success: t.statusUpdated),
                        icon: const Icon(Icons.build),
                        label: Text('بدأ الخدمة / Start service'),
                      ),
                    if (o.status == 'in_service')
                      FilledButton.icon(
                        onPressed: _busy ? null : () => _act('/orders/${widget.orderId}/status', body: {'status': 'completed'}, success: t.statusUpdated),
                        icon: const Icon(Icons.flag),
                        label: Text('إنهاء الخدمة / Complete'),
                      ),
                    if (o.status == 'pending' || o.status == 'accepted')
                      OutlinedButton.icon(
                        onPressed: _busy ? null : () => _act('/orders/${widget.orderId}/cancel', success: t.orderCanceled),
                        icon: const Icon(Icons.cancel_outlined),
                        label: Text(t.cancelOrder),
                      ),
                  ],
                ),
    );
  }
}