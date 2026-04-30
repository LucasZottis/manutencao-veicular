import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/colors.dart';
import '../../../core/widgets/app_input.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/database/lookup_models.dart';
import '../../../core/database/lookup_repository.dart';
import '../../garagem/controller/garagem_controller.dart';
import '../../garagem/data/veiculo_model.dart';
import '../controller/servicos_controller.dart';
import '../data/servico_model.dart';
import '../data/servico_repository.dart';

class ServicoFormScreen extends StatefulWidget {
  final int veiculoId;
  final int? servicoId;

  const ServicoFormScreen({
    super.key,
    required this.veiculoId,
    this.servicoId,
  });

  @override
  State<ServicoFormScreen> createState() => _ServicoFormScreenState();
}

class _ServicoFormScreenState extends State<ServicoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valorCtrl = TextEditingController();
  final _odometroCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  final _observacaoCtrl = TextEditingController();
  final _kmProximoCtrl = TextEditingController();
  final _estabelecimentoCtrl = TextEditingController();

  List<Veiculo> _veiculos = [];
  List<TipoServico> _tiposServico = [];
  List<Estabelecimento> _estabelecimentos = [];

  int? _veiculoId;
  int? _tipoServicoId;
  int? _estabelecimentoId;
  DateTime _dataHora = DateTime.now();
  bool _atualizarOdometro = true;
  bool _loading = false;
  bool _initializing = true;
  Servico? _editing;

  static final _dateFmt = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _veiculoId = widget.veiculoId;
    _init();
  }

  Future<void> _init() async {
    final repo = LookupRepository();
    final gCtrl = context.read<GaragemController>();

    await Future.wait([
      gCtrl.load(),
      repo.getTiposServico().then((v) => _tiposServico = v),
      repo.getEstabelecimentos().then((v) => _estabelecimentos = v),
    ]);

    _veiculos = context.read<GaragemController>().veiculos;

    if (widget.servicoId != null) {
      final rows = await ServicoRepository().getByVeiculo(widget.veiculoId);
      _editing =
          rows.where((s) => s.id == widget.servicoId).firstOrNull;
      if (_editing != null) {
        _veiculoId = _editing!.veiculoId;
        _tipoServicoId = _editing!.tipoServicoId;
        _estabelecimentoId = _editing!.estabelecimentoId;
        _dataHora = _editing!.dataHora;
        _valorCtrl.text = _editing!.valor.toStringAsFixed(2);
        _odometroCtrl.text = _editing!.odometro.toStringAsFixed(0);
        _descricaoCtrl.text = _editing!.descricao ?? '';
        _observacaoCtrl.text = _editing!.observacao ?? '';
        _kmProximoCtrl.text =
            _editing!.kmProximoServico?.toStringAsFixed(0) ?? '';
      }
    } else {
      final veiculo = await context
          .read<GaragemController>()
          .getById(widget.veiculoId);
      if (veiculo != null) {
        _odometroCtrl.text = veiculo.odometroAtual.toStringAsFixed(0);
      }
    }

    if (mounted) setState(() => _initializing = false);
  }

  @override
  void dispose() {
    _valorCtrl.dispose();
    _odometroCtrl.dispose();
    _descricaoCtrl.dispose();
    _observacaoCtrl.dispose();
    _kmProximoCtrl.dispose();
    _estabelecimentoCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataHora,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dataHora = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final odometro = double.tryParse(_odometroCtrl.text) ?? 0;

    final veiculo =
        await context.read<GaragemController>().getById(_veiculoId!);
    bool updateOdometro = false;

    if (veiculo != null && odometro > veiculo.odometroAtual && _atualizarOdometro) {
      updateOdometro = true;
    }

    // If odometro > atual but toggle is false, ask user
    if (veiculo != null &&
        odometro > veiculo.odometroAtual &&
        !_atualizarOdometro) {
      final confirm = await _showOdometroSheet(odometro);
      updateOdometro = confirm;
    }

    setState(() => _loading = true);

    // Handle new estabelecimento text
    int? estId = _estabelecimentoId;
    if (_estabelecimentoCtrl.text.trim().isNotEmpty && estId == null) {
      estId = await LookupRepository()
          .insertEstabelecimento(_estabelecimentoCtrl.text.trim());
    }

    final s = Servico(
      id: _editing?.id,
      veiculoId: _veiculoId!,
      tipoServicoId: _tipoServicoId,
      estabelecimentoId: estId,
      dataHora: _dataHora,
      odometro: odometro,
      valor: double.tryParse(_valorCtrl.text.replaceAll(',', '.')) ?? 0,
      descricao: _descricaoCtrl.text.trim().isEmpty
          ? null
          : _descricaoCtrl.text.trim(),
      observacao: _observacaoCtrl.text.trim().isEmpty
          ? null
          : _observacaoCtrl.text.trim(),
      kmProximoServico: _kmProximoCtrl.text.trim().isEmpty
          ? null
          : double.tryParse(_kmProximoCtrl.text),
    );

    await context
        .read<ServicosController>()
        .save(s, updateOdometro: updateOdometro);

    if (mounted) context.pop();
  }

  Future<bool> _showOdometroSheet(double odometro) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Atualizar odômetro do veículo?',
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'O odômetro informado (${odometro.toInt()} km) é maior que o atual. Deseja atualizar?',
              style: Theme.of(ctx).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Não'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: kPrimary),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Sim',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    return result ?? false;
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
          widget.servicoId == null ? 'Nova Manutenção' : 'Editar Serviço',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: _initializing
          ? const Center(child: CircularProgressIndicator(color: kPrimary))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _field(
                      label: 'SELECIONAR VEÍCULO',
                      child: DropdownButtonFormField<int>(
                        value: _veiculoId,
                        items: _veiculos
                            .map((v) => DropdownMenuItem(
                                  value: v.id,
                                  child: Row(
                                    children: [
                                      const Icon(Icons.directions_car_outlined,
                                          size: 18, color: kOnSurfaceVariant),
                                      const SizedBox(width: 8),
                                      Text(v.apelido),
                                    ],
                                  ),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _veiculoId = v),
                        decoration: const InputDecoration(
                          hintText: 'Escolha da sua frota',
                        ),
                        validator: (v) => v == null ? 'Obrigatório' : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _field(
                      label: 'TIPO DE SERVIÇO',
                      optional: true,
                      child: DropdownButtonFormField<int>(
                        value: _tipoServicoId,
                        items: [
                          const DropdownMenuItem(
                              value: null,
                              child: Text('Selecionar...',
                                  style:
                                      TextStyle(color: kOnSurfaceVariant))),
                          ..._tiposServico.map((t) => DropdownMenuItem(
                                value: t.id,
                                child: Text(t.descricao),
                              )),
                        ],
                        onChanged: (v) => setState(() => _tipoServicoId = v),
                        decoration: const InputDecoration(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _field(
                      label: 'DATA DO SERVIÇO',
                      child: TextFormField(
                        readOnly: true,
                        onTap: _pickDate,
                        decoration: InputDecoration(
                          hintText: 'dd/mm/aaaa',
                          prefixIcon: const Icon(Icons.calendar_today_outlined,
                              size: 18, color: kOnSurfaceVariant),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.calendar_month_outlined,
                                color: kOnSurfaceVariant),
                            onPressed: _pickDate,
                          ),
                        ),
                        controller: TextEditingController(
                            text: _dateFmt.format(_dataHora)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _field(
                      label: 'CUSTO DO SERVIÇO',
                      child: TextFormField(
                        controller: _valorCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        decoration: const InputDecoration(
                          prefixText: 'R\$ ',
                          hintText: '0,00',
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Obrigatório' : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _field(
                      label: 'ESTABELECIMENTO',
                      optional: true,
                      child: DropdownButtonFormField<int>(
                        value: _estabelecimentoId,
                        items: [
                          const DropdownMenuItem(
                              value: null,
                              child: Text('Selecionar ou digitar...',
                                  style:
                                      TextStyle(color: kOnSurfaceVariant))),
                          ..._estabelecimentos.map((e) => DropdownMenuItem(
                                value: e.id,
                                child: Text(e.nome),
                              )),
                        ],
                        onChanged: (v) =>
                            setState(() => _estabelecimentoId = v),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.storefront_outlined,
                              size: 18, color: kOnSurfaceVariant),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _field(
                      label: 'QUILOMETRAGEM ATUAL (KM)',
                      child: TextFormField(
                        controller: _odometroCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.speed_outlined,
                              size: 18, color: kOnSurfaceVariant),
                        ),
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Obrigatório' : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Switch(
                          value: _atualizarOdometro,
                          onChanged: (v) =>
                              setState(() => _atualizarOdometro = v),
                          activeColor: kPrimary,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'ATUALIZAR QUILOMETRAGEM DO VEÍCULO',
                            style: TextStyle(
                              color: kOnSurfaceVariant,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _field(
                      label: 'PRÓXIMO SERVIÇO EM (KM)',
                      optional: true,
                      child: TextFormField(
                        controller: _kmProximoCtrl,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.speed_outlined,
                              size: 18, color: kOnSurfaceVariant),
                          hintText: '000.000',
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _field(
                      label: 'DESCRIÇÃO',
                      optional: true,
                      child: TextFormField(
                        controller: _descricaoCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                            hintText: 'Detalhes do serviço'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _field(
                      label: 'OBSERVAÇÃO',
                      optional: true,
                      child: TextFormField(
                        controller: _observacaoCtrl,
                        maxLines: 2,
                        decoration:
                            const InputDecoration(hintText: 'Observações'),
                      ),
                    ),
                    const SizedBox(height: 32),
                    PrimaryButton(
                      label: 'SALVAR REGISTRO',
                      icon: Icons.check,
                      onPressed: _save,
                      loading: _loading,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text(
                        'CANCELAR',
                        style: TextStyle(
                          color: kOnSurfaceVariant,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _field({
    required String label,
    required Widget child,
    bool optional = false,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: kSurfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: kOnSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.6,
                ),
              ),
              if (optional) ...[
                const Spacer(),
                const Text(
                  '(OPCIONAL)',
                  style: TextStyle(
                    color: kOnSurfaceVariant,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
