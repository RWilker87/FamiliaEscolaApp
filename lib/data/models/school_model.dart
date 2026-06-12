import 'package:cloud_firestore/cloud_firestore.dart';

class SchoolModel {
  final String id;
  final String nome;
  final String tipo;
  final String? info;
  final String? endereco;
  final String? telefone;
  final String? emailContato;
  final String gestorId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SchoolModel({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.gestorId,
    this.info,
    this.endereco,
    this.telefone,
    this.emailContato,
    this.createdAt,
    this.updatedAt,
  });

  // ── Convenience getters ────────────────────────────────────────────────────
  String get initial => nome.isNotEmpty ? nome[0].toUpperCase() : 'E';

  String get tipoLabel {
    switch (tipo.toLowerCase()) {
      case 'publica':
      case 'pública':
        return 'Pública';
      case 'privada':
        return 'Privada';
      case 'federal':
        return 'Federal';
      default:
        return tipo;
    }
  }

  // ── Factory from Firestore ─────────────────────────────────────────────────
  factory SchoolModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return SchoolModel(
      id: doc.id,
      nome: (data['nome'] as String?) ?? '',
      tipo: (data['tipo'] as String?) ?? '',
      gestorId: (data['gestorId'] as String?) ?? '',
      info: data['info'] as String?,
      endereco: data['endereco'] as String?,
      telefone: data['telefone'] as String?,
      emailContato: data['email'] as String?,
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
    );
  }

  factory SchoolModel.fromMap(String id, Map<String, dynamic> data) {
    return SchoolModel(
      id: id,
      nome: (data['nome'] as String?) ?? '',
      tipo: (data['tipo'] as String?) ?? '',
      gestorId: (data['gestorId'] as String?) ?? '',
      info: data['info'] as String?,
      endereco: data['endereco'] as String?,
      telefone: data['telefone'] as String?,
      emailContato: data['email'] as String?,
      createdAt: _parseDate(data['createdAt']),
      updatedAt: _parseDate(data['updatedAt']),
    );
  }

  // ── Serialization ──────────────────────────────────────────────────────────
  Map<String, dynamic> toMap() => {
    'nome': nome,
    'tipo': tipo,
    'gestorId': gestorId,
    if (info != null) 'info': info,
    if (endereco != null) 'endereco': endereco,
    if (telefone != null) 'telefone': telefone,
    if (emailContato != null) 'email': emailContato,
  };

  // ── CopyWith ───────────────────────────────────────────────────────────────
  SchoolModel copyWith({
    String? nome,
    String? tipo,
    String? info,
    String? endereco,
    String? telefone,
    String? emailContato,
  }) {
    return SchoolModel(
      id: id,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      gestorId: gestorId,
      info: info ?? this.info,
      endereco: endereco ?? this.endereco,
      telefone: telefone ?? this.telefone,
      emailContato: emailContato ?? this.emailContato,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      return DateTime.tryParse(value);
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }

  @override
  String toString() => 'SchoolModel(id: $id, nome: $nome)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is SchoolModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
