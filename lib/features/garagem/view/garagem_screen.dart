import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../controller/garagem_controller.dart';
import '../data/veiculo_model.dart';

class GaragemScreen extends StatefulWidget {
  const GaragemScreen({super.key});

  @override
  State<GaragemScreen> createState() => _GaragemScreenState();
}

class _GaragemScreenState extends State<GaragemScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GaragemController>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(),
            Expanded(child: _VeiculoList()),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Row(
        children: [
          const Icon(Icons.directions_car_outlined, color: kPrimary, size: 28),
          const SizedBox(width: 12),
          Text(
            'Garagem',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
    );
  }
}

class _VeiculoList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GaragemController>(
      builder: (context, ctrl, _) {
        if (ctrl.loading) {
          return const Center(
            child: CircularProgressIndicator(color: kPrimary),
          );
        }
        if (ctrl.veiculos.isEmpty) {
          return _EmptyState();
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
          itemCount: ctrl.veiculos.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) => _VeiculoCard(veiculo: ctrl.veiculos[i]),
        );
      },
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
          Icon(Icons.garage_outlined, size: 64, color: kOnSurfaceVariant.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text(
            'Nenhum veículo cadastrado',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: kOnSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toque no botão + para adicionar',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _VeiculoCard extends StatelessWidget {
  final Veiculo veiculo;
  const _VeiculoCard({required this.veiculo});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => context.push('/veiculo/${veiculo.id}'),
        borderRadius: BorderRadius.circular(16),
        splashColor: kPrimaryFixed,
        highlightColor: kPrimaryFixed.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      veiculo.apelido,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    if (veiculo.placa != null && veiculo.placa!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _PlacaChip(placa: veiculo.placa!),
                    ],
                    const SizedBox(height: 16),
                    Text(
                      'QUILOMETRAGEM ATUAL',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          _formatKm(veiculo.odometroAtual),
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: kPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'KM',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.open_in_new,
                color: kOnSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatKm(double km) {
    final n = km.toInt();
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _PlacaChip extends StatelessWidget {
  final String placa;
  const _PlacaChip({required this.placa});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: kOutlineVariant.withOpacity(0.25),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'PLACA: $placa',
        style: const TextStyle(
          color: kPrimary,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
