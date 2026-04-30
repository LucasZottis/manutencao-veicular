import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../controller/dashboard_controller.dart';
import '../data/dashboard_repository.dart';
import '../../garagem/data/veiculo_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      body: SafeArea(
        child: Consumer<DashboardController>(
          builder: (context, ctrl, _) {
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _Header(ctrl: ctrl)),
                if (ctrl.loading)
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(color: kPrimary),
                    ),
                  )
                else if (ctrl.proximos.isEmpty)
                  SliverFillRemaining(
                    child: _EmptyState(),
                  )
                else ...[
                  SliverToBoxAdapter(
                    child: _SectionTitle(count: ctrl.proximos.length),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ProximoServicoCard(item: ctrl.proximos[i]),
                        ),
                        childCount: ctrl.proximos.length,
                      ),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final DashboardController ctrl;
  const _Header({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.dashboard_outlined, color: kPrimary, size: 24),
              const SizedBox(width: 10),
              Text(
                'DASHBOARD',
                style: const TextStyle(
                  color: kOnPrimaryFixed,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _VeiculoFilter(ctrl: ctrl),
        ],
      ),
    );
  }
}

class _VeiculoFilter extends StatelessWidget {
  final DashboardController ctrl;
  const _VeiculoFilter({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final veiculos = ctrl.veiculos;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _showPicker(context, veiculos, ctrl),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: kSurfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      ctrl.filtroVeiculoId == null
                          ? 'Todos os Veículos'
                          : veiculos
                                  .where((v) => v.id == ctrl.filtroVeiculoId)
                                  .firstOrNull
                                  ?.apelido ??
                              'Todos os Veículos',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const Icon(Icons.keyboard_arrow_down,
                      color: kOnSurfaceVariant),
                ],
              ),
            ),
          ),
        ),
        if (ctrl.filtroVeiculoId != null) ...[
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => ctrl.setFiltroVeiculo(null),
            style: TextButton.styleFrom(foregroundColor: kOnSurfaceVariant),
            child: const Text('LIMPAR FILTROS',
                style: TextStyle(fontSize: 11, letterSpacing: 0.5)),
          ),
        ],
      ],
    );
  }

  void _showPicker(
      BuildContext context, List<Veiculo> veiculos, DashboardController ctrl) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          ListTile(
            title: const Text('Todos os Veículos'),
            leading: const Icon(Icons.garage_outlined),
            onTap: () {
              ctrl.setFiltroVeiculo(null);
              Navigator.pop(ctx);
            },
          ),
          ...veiculos.map(
            (v) => ListTile(
              title: Text(v.apelido),
              leading: const Icon(Icons.directions_car_outlined),
              onTap: () {
                ctrl.setFiltroVeiculo(v.id);
                Navigator.pop(ctx);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final int count;
  const _SectionTitle({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 16, 12),
      child: Row(
        children: [
          Text(
            'PRÓXIMOS SERVIÇOS',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: kSurfaceContainerHighest,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Text(
              '$count PENDENTES',
              style: const TextStyle(
                color: kOnSurfaceVariant,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProximoServicoCard extends StatelessWidget {
  final ProximoServico item;
  const _ProximoServicoCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final status = item.status;
    final accentColor = switch (status) {
      ServiceStatusLevel.urgent => kError,
      ServiceStatusLevel.upcoming => kTertiaryFixed,
      ServiceStatusLevel.good => kGoodStatus,
    };

    final chipLabel = switch (status) {
      ServiceStatusLevel.urgent => 'VENCIDO',
      ServiceStatusLevel.upcoming => 'URGENTE',
      ServiceStatusLevel.good => 'PRÓXIMO',
    };

    final chipBg = switch (status) {
      ServiceStatusLevel.urgent => kError.withOpacity(0.12),
      ServiceStatusLevel.upcoming => kTertiaryContainer.withOpacity(0.15),
      ServiceStatusLevel.good => kGoodStatusBg,
    };

    final kmAbs = item.kmRestante.abs().toInt();
    final kmLabel = item.kmRestante <= 0
        ? '$kmAbs KM ATRASO'
        : '$kmAbs KM RESTANTES';

    return Container(
      decoration: BoxDecoration(
        color: kSurfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: accentColor, width: 4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: chipBg,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    chipLabel,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _fmtKm(kmAbs),
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      item.kmRestante <= 0 ? 'KM ATRASO' : 'KM RESTANTES',
                      style: const TextStyle(
                        color: kOnSurfaceVariant,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.servico.label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              item.veiculo.apelido,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (status == ServiceStatusLevel.urgent) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: kError.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: kError, size: 16),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Serviço crítico recomendado imediatamente.',
                        style: TextStyle(
                          color: kError,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (status == ServiceStatusLevel.upcoming) ...[
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _progress(),
                  backgroundColor: kSurfaceContainerHighest,
                  color: kTertiaryFixed,
                  minHeight: 4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  double _progress() {
    final total = item.servico.kmProximoServico ?? 1;
    final done = total - item.kmRestante.clamp(0, total);
    return (done / total).clamp(0.0, 1.0);
  }

  String _fmtKm(int km) {
    final s = km.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline,
              size: 64, color: kGoodStatus.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            'Tudo em dia!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: kOnSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nenhum serviço pendente',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
