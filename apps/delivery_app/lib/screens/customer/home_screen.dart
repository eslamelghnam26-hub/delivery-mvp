import 'dart:async';
import 'package:flutter/material.dart';
import '../../api.dart';
import '../../auth_store.dart';
import '../../l10n.dart';
import '../../locale_controller.dart';
import '../../models.dart';
import '../../widgets/language_button.dart';
import '../../widgets/order_widgets.dart';
import '../profile_screen.dart';
import 'new_order_screen.dart';
import 'order_detail_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  final Api api;
  final AuthStore store;
  final LocaleController lang;
  final Future<void> Function() onLogout;
  const CustomerHomeScreen({super.key, required this.api, required this.store, required this.lang, required this.onLogout});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _tab = 0;

  late final List<Widget> _tabs = [
    _ServicesTab(api: widget.api, lang: widget.lang),
    _OrdersTab(api: widget.api, lang: widget.lang),
    ProfileScreen(api: widget.api, store: widget.store, lang: widget.lang, onLogout: widget.onLogout, role: 'customer'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    return Scaffold(
      body: _tabs[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_outlined), selectedIcon: const Icon(Icons.home), label: t.home),
          NavigationDestination(icon: const Icon(Icons.history), label: t.myOrders),
          NavigationDestination(icon: const Icon(Icons.person_outline), label: t.profile),
        ],
      ),
    );
  }
}

class _ServicesTab extends StatefulWidget {
  final Api api;
  final LocaleController lang;
  const _ServicesTab({required this.api, required this.lang});

  @override
  State<_ServicesTab> createState() => _ServicesTabState();
}

class _ServicesTabState extends State<_ServicesTab> {
  late Future<List<Service>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Service>> _load() async {
    final list = await widget.api.getList('/services');
    return list.map((e) => Service.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.appName),
        centerTitle: true,
        actions: [LanguageButton(controller: widget.lang, api: widget.api)],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Service>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cloud_off, size: 40),
                    const SizedBox(height: 8),
                    Text(snap.error.toString()),
                    const SizedBox(height: 8),
                    FilledButton(onPressed: _refresh, child: const Text('Retry')),
                  ],
                ),
              );
            }
            final services = snap.data ?? [];
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: services.length + 1,
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Card(
                    elevation: 0,
                    color: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          const Icon(Icons.bolt, color: Colors.white, size: 28),
                          const SizedBox(width: 12),
                          Expanded(child: Text(t.tagline, style: const TextStyle(color: Colors.white, fontSize: 14))),
                        ],
                      ),
                    ),
                  );
                }
                final s = services[i - 1];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: const Color(0xFF2563EB).withValues(alpha: .1), child: const Icon(Icons.build, color: Color(0xFF2563EB))),
                    title: Text(t.ar ? s.nameAr : s.nameEn),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () async {
                      final created = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(builder: (_) => NewOrderScreen(api: widget.api, service: s)),
                      );
                      if (created == true && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.orderCreated)));
                      }
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _OrdersTab extends StatefulWidget {
  final Api api;
  final LocaleController lang;
  const _OrdersTab({required this.api, required this.lang});

  @override
  State<_OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<_OrdersTab> {
  List<Order> _orders = [];
  bool _loading = true;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _refresh();
    _ticker = Timer.periodic(const Duration(seconds: 6), (_) => _refresh(silent: true));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _refresh({bool silent = false}) async {
    try {
      final list = await widget.api.getList('/orders');
      if (!mounted) return;
      setState(() {
        _orders = list.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
        _loading = false;
      });
    } catch (_) {
      if (!silent && mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.myOrders),
        centerTitle: true,
        actions: [LanguageButton(controller: widget.lang, api: widget.api)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(child: Text(t.noOrdersYet, style: const TextStyle(color: Colors.grey)))
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (context, i) {
                      final o = _orders[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: OrderCard(
                          order: o,
                          onTap: () async {
                            await Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => OrderDetailScreen(api: widget.api, orderId: o.id),
                            ));
                            _refresh(silent: true);
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}