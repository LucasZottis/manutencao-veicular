import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../controller/abastecimentos_controller.dart';
import '../data/abastecimento_model.dart';

class AbastecimentosScreen extends StatefulWidget {
  final int veiculoId;
  const AbastecimentosScreen({super.key, required this.veiculoId});

  @override
  State<AbastecimentosScreen> createState() => _AbastecimentosScreenState();
}

class _AbastecimentosScreenState extends State<AbastecimentosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AbastecimentosController>().load(widget.veiculoId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Histórico de Abastecimento'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context
              .push('/veiculo/${widget.veiculoId}/abastecimentos/novo');
          if (mounted) {
            context.read<AbastecimentosController>().load(widget.veiculoId);
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Abastecer'),
      ),
      body: Consumer<AbastecimentosController>(
        builder: (context, ctrl, _) {
          if (ctrl.loading) {
            return const Center(
              child: CircularProgressIndicator(color: kPrimary),
            );
          }
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _HeaderStats(ctrl: ctrl),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                sliver: ctrl.abastecimentos.isEmpty
                    ? SliverFillRemaining(child: _EmptyState())
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _AbastecimentoCard(
                              abastecimento: ctrl.abastecimentos[i],
                              veiculoId: widget.veiculoId,
                            ),
                          ),
                          childCount: ctrl.abastecimentos.length,
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderStats extends StatelessWidget {
  final AbastecimentosController ctrl;
  const _HeaderStats({required this.ctrl});

  static final _curr = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Total gasto — dark card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [kPrimary, kPrimaryContainer],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TOTAL GASTO EM\nABASTECIMENTO',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _curr.format(ctrl.totalGasto),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Stats row
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  topLabel: 'ÚLTIMO\nABASTECIMENTO',
                  value: ctrl.ultimo != null
                      ? _curr.format(ctrl.ultimo!.valorTotal)
                      : '—',
                  bottom: ctrl.ultimo != null
                      ? Row(
                          children: [
                            const Icon(Icons.speed_outlined,
                                size: 12, color: kOnSurfaceVariant),
                            const SizedBox(width: 4),
                            Text(
                              '${ctrl.ultimo!.odometro.toInt()} KM',
                              style: const TextStyle(
                                  color: kOnSurfaceVariant, fontSize: 11),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  topLabel: 'CONSUMO\nMÉDIO',
                  value: ctrl.consumoMedio != null
                      ? '${ctrl.consumoMedio!.toStringAsFixed(1)}'
                      : '—',
                  unit: ctrl.consumoMedio != null ? 'L/KM' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Registros de Abastecimento',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String topLabel;
  final String value;
  final String? unit;
  final Widget? bottom;

  const _StatCard({
    required this.topLabel,
    required this.value,
    this.unit,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kSurfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            topLabel,
            style: const TextStyle(
              color: kOnSurfaceVariant,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: const TextStyle(
                      color: kOnSurfaceVariant, fontSize: 11),
                ),
              ],
            ],
          ),
          if (bottom != null) ...[
            const SizedBox(height: 4),
            bottom!,
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.local_gas_station_outlined,
              size: 56, color: kOnSurfaceVariant.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('Nenhum abastecimento registrado',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: kOnSurfaceVariant)),
        ],
      ),
    );
  }
}

class _AbastecimentoCard extends StatelessWidget {
  final Abastecimento abastecimento;
  final int veiculoId;

  const _AbastecimentoCard({
    required this.abastecimento,
    required this.veiculoId,
  });

  static final _dateFmt = DateFormat('dd/MM/yyyy');
  static final _curr = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () async {
          await context.push(
              '/veiculo/$veiculoId/abastecimentos/novo?id=${abastecimento.id}');
          if (context.mounted) {
            context.read<AbastecimentosController>().load(veiculoId);
          }
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: kPrimaryFixed,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kPrimaryFixed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.local_gas_station_outlined,
                    color: kPrimary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _curr.format(abastecimento.valorTotal),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      _dateFmt.format(abastecimento.dataHora),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: kSurfaceContainerHighest,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  '${abastecimento.totalLitros.toStringAsFixed(0)}L',
                  style: const TextStyle(
                    color: kOnSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
