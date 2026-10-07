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
import 'order_work_screen.dart';

class ProviderHomeScreen extends StatefulWidget {
  final Api api;
  final AuthStore store;
  final LocaleController lang;
  final Future<void> Function() onLogout;
  final String? forcedRole;
  const ProviderHomeScreen({
    super.key,
    required this.api,
    required this.store,
    required this.lang,
    required this.onLogout,
    this.forcedRole,
  });

  @override
  State<ProviderHomeScreen> createState() => _ProviderHomeScreenState();
}

class _ProviderHomeScreenState extends State<ProviderHomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          _AvailableTab(api: widget.api, lang: widget.lang),
          _JobsTab(api: widget.api, lang: widget.lang),
          ProfileScreen(api: widget.api, store: widget.store, lang: widget.lang, onLogout: widget.onLogout, role: 'provider', canToggleOnline: true),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.inbox_outlined), label: t.availableOrders),
          NavigationDestination(icon: const Icon(Icons.work_outline), label: t.myJobs),
          NavigationDestination(icon: const Icon(Icons.person_outline), label: t.profile),
        ],
      ),
    );
  }
}

class _AvailableTab extends StatefulWidget {
  final Api api;
  final LocaleController lang;
  const _AvailableTab({required this.api, required this.lang});

  @override
  State<_AvailableTab> createState() => _AvailableTabState();
}

class _AvailableTabState extends State<_AvailableTab> {
  List<Order> _orders = [];
  bool _loading = true;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _refresh();
    _ticker = Timer.periodic(const Duration(seconds: 4), (_) => _refresh(silent: true));
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _refresh({bool silent = false}) async {
    try {
      final list = await widget.api.getList('/orders?status=available');
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
        title: Text(t.availableOrders),
        centerTitle: true,
        actions: [LanguageButton(controller: widget.lang, api: widget.api)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('لا توجد طلبات متاحة حالياً / No available orders', style: TextStyle(color: Colors.grey)))
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
                              builder: (_) => OrderWorkScreen(api: widget.api, orderId: o.id, isAvailable: true),
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

class _JobsTab extends StatefulWidget {
  final Api api;
  final LocaleController lang;
  const _JobsTab({required this.api, required this.lang});

  @override
  State<_JobsTab> createState() => _JobsTabState();
}

class _JobsTabState extends State<_JobsTab> {
  List<Order> _orders = [];
  bool _loading = true;
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
        title: Text(t.myJobs),
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
                      final active = o.status == 'accepted' || o.status == 'on_the_way' || o.status == 'in_service';
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: OrderCard(
                          order: o,
                          onTap: () async {
                            await Navigator.of(context).push(MaterialPageRoute(
                              builder: (_) => OrderWorkScreen(api: widget.api, orderId: o.id, isAvailable: !active && o.status == 'pending'),
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