class TipoCombustivel {
  final int id;
  final String descricao;
  const TipoCombustivel({required this.id, required this.descricao});
  factory TipoCombustivel.fromMap(Map<String, dynamic> m) =>
      TipoCombustivel(id: m['id'] as int, descricao: m['descricao'] as String);
}

class TipoServico {
  final int id;
  final String descricao;
  const TipoServico({required this.id, required this.descricao});
  factory TipoServico.fromMap(Map<String, dynamic> m) =>
      TipoServico(id: m['id'] as int, descricao: m['descricao'] as String);
}

class Estabelecimento {
  final int id;
  final String nome;
  const Estabelecimento({required this.id, required this.nome});
  factory Estabelecimento.fromMap(Map<String, dynamic> m) =>
      Estabelecimento(id: m['id'] as int, nome: m['nome'] as String);
}
