import 'package:flutter/material.dart';
import '../theme/colors.dart';

enum ServiceStatus { good, upcoming, urgent }

class StatusChip extends StatelessWidget {
  final ServiceStatus status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _fg,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Color get _bg => switch (status) {
        ServiceStatus.good => kGoodStatusBg,
        ServiceStatus.upcoming => kTertiaryContainer,
        ServiceStatus.urgent => kError,
      };

  Color get _fg => switch (status) {
        ServiceStatus.good => kGoodStatus,
        ServiceStatus.upcoming => kTertiaryFixed,
        ServiceStatus.urgent => kOnError,
      };

  String get _label => switch (status) {
        ServiceStatus.good => 'PRÓXIMO',
        ServiceStatus.upcoming => 'URGENTE',
        ServiceStatus.urgent => 'VENCIDO',
      };
}
