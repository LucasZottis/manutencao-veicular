import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../controller/garagem_controller.dart';
import '../data/veiculo_model.dart';

class VeiculoDetailScreen extends StatefulWidget {
  final int veiculoId;
  const VeiculoDetailScreen({super.key, required this.veiculoId});

  @override
  State<VeiculoDetailScreen> createState() => _VeiculoDetailScreenState();
}

class _VeiculoDetailScreenState extends State<VeiculoDetailScreen> {
  Veiculo? _veiculo;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final v = await context.read<GaragemController>().getById(widget.veiculoId);
    if (mounted) setState(() { _veiculo = v; _loading = false; });
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
        title: Text(
          _veiculo?.apelido ?? '',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: kPrimary),
            onPressed: _veiculo == null
                ? null
                : () async {
                    await context.push('/veiculo/${widget.veiculoId}/editar');
                    _load();
                  },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : _veiculo == null
              ? const Center(child: Text('Veículo não encontrado'))
              : _Body(veiculo: _veiculo!),
    );
  }
}

class _Body extends StatelessWidget {
  final Veiculo veiculo;
  const _Body({required this.veiculo});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _OdometroCard(veiculo: veiculo),
          const SizedBox(height: 16),
          _NavCard(
            icon: Icons.build_outlined,
            title: 'Histórico de Serviços',
            subtitle: 'Manutenções e revisões',
            onTap: () => context.push('/veiculo/${veiculo.id}/servicos'),
          ),
          const SizedBox(height: 12),
          _NavCard(
            icon: Icons.local_gas_station_outlined,
            title: 'Histórico de Abastecimentos',
            subtitle: 'Registros de combustível',
            onTap: () => context.push('/veiculo/${veiculo.id}/abastecimentos'),
          ),
        ],
      ),
    );
  }
}

class _OdometroCard extends StatelessWidget {
  final Veiculo veiculo;
  const _OdometroCard({required this.veiculo});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          if (veiculo.placa != null && veiculo.placa!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                veiculo.placa!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          const SizedBox(height: 20),
          const Text(
            'QUILOMETRAGEM ATUAL',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _fmt(veiculo.odometroAtual),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'KM',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(double km) {
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

class _NavCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _NavCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: kPrimaryFixed,
        highlightColor: kPrimaryFixed.withOpacity(0.5),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: kPrimaryFixed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: kPrimary, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: kOnSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
