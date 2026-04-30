import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../controller/servicos_controller.dart';
import '../data/servico_model.dart';

class ServicosScreen extends StatefulWidget {
  final int veiculoId;
  const ServicosScreen({super.key, required this.veiculoId});

  @override
  State<ServicosScreen> createState() => _ServicosScreenState();
}

class _ServicosScreenState extends State<ServicosScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServicosController>()
        ..clearFilter()
        ..load(widget.veiculoId);
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
        title: const Text('Histórico'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context
              .push('/veiculo/${widget.veiculoId}/servicos/novo');
          if (mounted) context.read<ServicosController>().load(widget.veiculoId);
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo Serviço'),
      ),
      body: Consumer<ServicosController>(
        builder: (context, ctrl, _) {
          return Column(
            children: [
              _TotalHeader(total: ctrl.totalGasto),
              _FilterRow(veiculoId: widget.veiculoId),
              Expanded(
                child: ctrl.loading
                    ? const Center(
                        child: CircularProgressIndicator(color: kPrimary))
                    : ctrl.servicos.isEmpty
                        ? _EmptyState()
                        : _ServicoList(
                            servicos: ctrl.servicos,
                            veiculoId: widget.veiculoId,
                          ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _TotalHeader extends StatelessWidget {
  final double total;
  const _TotalHeader({required this.total});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: kSurfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'TOTAL GASTO',
            style: TextStyle(
              color: kOnSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            fmt.format(total),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: kPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final int veiculoId;
  const _FilterRow({required this.veiculoId});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<ServicosController>();
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _FilterChip(
            label: ctrl.filterAno?.toString() ?? 'ANO',
            active: ctrl.filterAno != null,
            onTap: () async {
              final picked = await _pickYear(context, ctrl.filterAno ?? now.year);
              if (picked != null) {
                ctrl.setFilter(ano: picked, mes: ctrl.filterMes, dia: ctrl.filterDia);
                ctrl.load(veiculoId);
              }
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: ctrl.filterMes != null
                ? _monthName(ctrl.filterMes!)
                : 'MÊS',
            active: ctrl.filterMes != null,
            onTap: () async {
              final picked =
                  await _pickMonth(context, ctrl.filterMes ?? now.month);
              if (picked != null) {
                ctrl.setFilter(ano: ctrl.filterAno, mes: picked, dia: ctrl.filterDia);
                ctrl.load(veiculoId);
              }
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: ctrl.filterDia?.toString().padLeft(2, '0') ?? 'DIA',
            active: ctrl.filterDia != null,
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(
                  ctrl.filterAno ?? now.year,
                  ctrl.filterMes ?? now.month,
                ),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                ctrl.setFilter(
                    ano: picked.year, mes: picked.month, dia: picked.day);
                ctrl.load(veiculoId);
              }
            },
          ),
          if (ctrl.filterAno != null || ctrl.filterMes != null || ctrl.filterDia != null) ...[
            const Spacer(),
            TextButton.icon(
              onPressed: () {
                ctrl.clearFilter();
                ctrl.load(veiculoId);
              },
              icon: const Icon(Icons.close, size: 14),
              label: const Text('LIMPAR', style: TextStyle(fontSize: 11)),
              style: TextButton.styleFrom(foregroundColor: kOnSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }

  Future<int?> _pickYear(BuildContext context, int current) async {
    int? result;
    await showDialog<int>(
      context: context,
      builder: (ctx) {
        int selected = current;
        return AlertDialog(
          title: const Text('Selecionar Ano'),
          content: StatefulBuilder(builder: (_, set) {
            return DropdownButton<int>(
              value: selected,
              items: List.generate(
                10,
                (i) => DropdownMenuItem(
                  value: DateTime.now().year - i,
                  child: Text('${DateTime.now().year - i}'),
                ),
              ),
              onChanged: (v) => set(() => selected = v!),
            );
          }),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            TextButton(
                onPressed: () {
                  result = selected;
                  Navigator.pop(ctx);
                },
                child: const Text('OK')),
          ],
        );
      },
    );
    return result;
  }

  Future<int?> _pickMonth(BuildContext context, int current) async {
    int? result;
    await showDialog<int>(
      context: context,
      builder: (ctx) {
        int selected = current;
        return AlertDialog(
          title: const Text('Selecionar Mês'),
          content: StatefulBuilder(builder: (_, set) {
            return DropdownButton<int>(
              value: selected,
              items: List.generate(
                12,
                (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text(_monthName(i + 1)),
                ),
              ),
              onChanged: (v) => set(() => selected = v!),
            );
          }),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar')),
            TextButton(
                onPressed: () {
                  result = selected;
                  Navigator.pop(ctx);
                },
                child: const Text('OK')),
          ],
        );
      },
    );
    return result;
  }

  String _monthName(int m) {
    const names = [
      'JAN', 'FEV', 'MAR', 'ABR', 'MAI', 'JUN',
      'JUL', 'AGO', 'SET', 'OUT', 'NOV', 'DEZ'
    ];
    return names[m - 1];
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? kPrimaryFixed : kSurfaceContainerHighest,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: active ? kPrimary : kOnSurfaceVariant,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 14,
              color: active ? kPrimary : kOnSurfaceVariant,
            ),
          ],
        ),
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
          Icon(Icons.build_outlined,
              size: 56, color: kOnSurfaceVariant.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text('Nenhum serviço registrado',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: kOnSurfaceVariant)),
        ],
      ),
    );
  }
}

class _ServicoList extends StatelessWidget {
  final List<Servico> servicos;
  final int veiculoId;

  const _ServicoList({required this.servicos, required this.veiculoId});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: servicos.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (ctx, i) => _ServicoCard(
        servico: servicos[i],
        veiculoId: veiculoId,
      ),
    );
  }
}

class _ServicoCard extends StatelessWidget {
  final Servico servico;
  final int veiculoId;

  const _ServicoCard({required this.servico, required this.veiculoId});

  static final _dateFmt = DateFormat('dd MMM yyyy', 'pt_BR');
  static final _currFmt =
      NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await context.push(
              '/veiculo/$veiculoId/servicos/novo?id=${servico.id}');
          if (context.mounted) {
            context.read<ServicosController>().load(veiculoId);
          }
        },
        splashColor: kPrimaryFixed,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _dateFmt.format(servico.dataHora).toUpperCase(),
                    style: const TextStyle(
                      color: kOnSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'CUSTO',
                        style: TextStyle(
                          color: kOnSurfaceVariant,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        _currFmt.format(servico.valor),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: kPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                servico.label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.speed_outlined,
                      size: 14, color: kOnSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '${servico.odometro.toInt()} KM',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  if (servico.estabelecimentoNome != null) ...[
                    const SizedBox(width: 16),
                    const Icon(Icons.location_on_outlined,
                        size: 14, color: kOnSurfaceVariant),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        servico.estabelecimentoNome!,
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
