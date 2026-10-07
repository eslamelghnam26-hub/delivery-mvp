import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../api.dart';
import '../../l10n.dart';
import '../../models.dart';
import '../../widgets/order_widgets.dart';

const _orderFlow = ['pending', 'accepted', 'on_the_way', 'in_service', 'completed'];

class OrderDetailScreen extends StatefulWidget {
  final Api api;
  final int orderId;
  const OrderDetailScreen({super.key, required this.api, required this.orderId});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Order? _order;
  Map<String, dynamic>? _location;
  bool _loading = true;
  String? _error;
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
      final order = await _fetchOrder();
      Map<String, dynamic>? loc;
      if (order.providerId != null) {
        try {
          loc = await widget.api.get('/locations/${order.providerId}');
        } catch (_) {
          loc = null;
        }
      }
      if (!mounted) return;
      setState(() {
        _order = order;
        _location = loc;
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

  Future<Order> _fetchOrder() async {
    final all = await widget.api.getList('/orders');
    final mine = all.firstWhere((e) => (e as Map<String, dynamic>)['id'] == widget.orderId,
        orElse: () => throw const ApiException(404, 'not found'));
    return Order.fromJson(mine as Map<String, dynamic>);
  }

  Future<void> _cancel() async {
    try {
      await widget.api.post('/orders/${widget.orderId}/cancel');
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order canceled / تم الإلغاء')));
      _refresh();
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cancel failed')));
    }
  }

  Future<void> _rate() async {
    final t = AppStrings.of(context);
    int stars = 5;
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(t.rateProvider),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) => IconButton(
              icon: Icon(Icons.star, color: i < stars ? Colors.amber : Colors.grey.shade300, size: 34),
              onPressed: () => setDialogState(() => stars = i + 1),
            )),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, stars),
              child: const Text('OK'),
            ),
          ],
        ),
      ),
    );
    if (stars > 0) {
      try {
        await widget.api.post('/orders/${widget.orderId}/rate', {'stars': stars});
        _refresh();
      } catch (_) {}
    }
  }

  void _openMaps() {
    final o = _order;
    if (o == null) return;
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${o.lat},${o.lng}');
    launchUrl(uri, mode: LaunchMode.externalApplication);
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
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(children: [Text('#${o.orderNo}', style: const TextStyle(fontWeight: FontWeight.w800)), const Spacer(), StatusBadge(status: o.status)]),
                            const SizedBox(height: 12),
                            Text(o.address ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                            if (o.description != null && o.description!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(o.description ?? '', style: TextStyle(color: Colors.grey.shade600)),
                            ],
                            const SizedBox(height: 10),
                            Text(o.serviceId.toString(), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Timeline(status: o.status),
                    const SizedBox(height: 16),
                    if (_location != null)
                      Card(
                        elevation: 0,
                        color: const Color(0xFFeff6ff),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        child: ListTile(
                          leading: const Icon(Icons.near_me, color: Color(0xFF2563EB)),
                          title: Text(t.providerLiveLocation),
                          subtitle: Text('lat: ${_location!['lat']}  lng: ${_location!['lng']}'),
                          trailing: IconButton(icon: const Icon(Icons.map), onPressed: _openMaps),
                        ),
                      ),
                    const SizedBox(height: 16),
                    if (o.status == 'pending')
                      OutlinedButton.icon(
                        icon: const Icon(Icons.cancel),
                        label: Text(t.cancelOrder),
                        onPressed: _cancel,
                      ),
                    if (o.status == 'completed' && o.customerRating == null)
                      FilledButton.icon(icon: const Icon(Icons.star), label: Text(t.rateOrder), onPressed: _rate),
                  ],
                ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final String status;
  const _Timeline({required this.status});

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final currentIndex = _orderFlow.indexOf(status);
    final shown = status == 'canceled' || status == 'rejected'
        ? _orderFlow.sublist(0, currentIndex < 0 ? 0 : currentIndex)
        : _orderFlow;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: List.generate(shown.length, (i) {
            final done = i <= currentIndex;
            final valid = currentIndex >= 0;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(children: [
                  Icon(done && valid ? Icons.check_circle : Icons.circle_outlined, color: done && valid ? const Color(0xFF16a34a) : Colors.grey.shade300),
                  if (i < shown.length - 1) Container(width: 2, height: 28, color: done && valid ? const Color(0xFF16a34a) : Colors.grey.shade200),
                ]),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(OrderUi.label(t, shown[i]), style: TextStyle(fontWeight: done && valid ? FontWeight.w700 : FontWeight.w400, color: done && valid ? Colors.black87 : Colors.grey)),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}