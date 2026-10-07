import 'package:flutter/material.dart';
import '../l10n.dart';
import '../models.dart';

class OrderUi {
  static String label(AppStrings t, String status) {
    switch (status) {
      case 'pending':
        return t.pending;
      case 'accepted':
        return t.accepted;
      case 'on_the_way':
        return t.onTheWay;
      case 'in_service':
        return t.inService;
      case 'completed':
        return t.completed;
      case 'rejected':
        return t.rejected;
      case 'canceled':
        return t.canceled;
    }
    return status;
  }

  static Color color(String status) {
    switch (status) {
      case 'pending':
        return const Color(0xFFd97706);
      case 'accepted':
        return const Color(0xFF2563eb);
      case 'on_the_way':
        return const Color(0xFF0891b2);
      case 'in_service':
        return const Color(0xFF7c3aed);
      case 'completed':
        return const Color(0xFF16a34a);
      case 'rejected':
        return const Color(0xFFb91c1c);
      case 'canceled':
        return const Color(0xFF64748b);
    }
    return const Color(0xFF64748b);
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: OrderUi.color(status).withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        OrderUi.label(t, status),
        style: TextStyle(color: OrderUi.color(status), fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;
  const OrderCard({super.key, required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: Colors.grey.shade200)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('#${order.orderNo}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  StatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(order.address ?? t.noOrdersYet, style: const TextStyle(fontSize: 13)),
              if (order.description != null && order.description!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(order.description!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}