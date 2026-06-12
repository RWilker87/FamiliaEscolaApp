import 'package:cloud_firestore/cloud_firestore.dart';

class StudentModel {
  final String id;
  final String nome;
  final DateTime? dataNascimento;
  final String responsibleName;
  final String responsibleCpf;
  final String escolaId;
  final String? turmaId;
  final DateTime? createdAt;

  const StudentModel({
    required this.id,
    required this.nome,
    required this.responsibleName,
    required this.responsibleCpf,
    required this.escolaId,
    this.dataNascimento,
    this.turmaId,
    this.createdAt,
  });

  // ── Convenience getters ────────────────────────────────────────────────────
  String get initial => nome.isNotEmpty ? nome[0].toUpperCase() : '?';

  bool get hasTurma => turmaId != null && turmaId!.isNotEmpty;

  int? get idade {
    if (dataNascimento == null) return null;
    final hoje = DateTime.now();
    int anos = hoje.year - dataNascimento!.year;
    if (hoje.month < dataNascimento!.month ||
        (hoje.month == dataNascimento!.month && hoje.day < dataNascimento!.day)) {
      anos--;
    }
    return anos;
  }

  String get idadeLabel {
    final i = idade;
    if (i == null) return '';
    return '$i ${i == 1 ? 'ano' : 'anos'}';
  }

  // ── Factory from Firestore ─────────────────────────────────────────────────
  factory StudentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return StudentModel(
      id: doc.id,
      nome: (data['nome'] as String?) ?? '',
      dataNascimento: _parseDate(data['dataNascimento']),
      responsibleName: (data['responsibleName'] as String?) ?? '',
      responsibleCpf: (data['responsibleCpf'] as String?) ?? '',
      escolaId: (data['escolaId'] as String?) ?? '',
      turmaId: data['turmaId'] as String?,
      createdAt: _parseDate(data['createdAt']),
    );
  }

  factory StudentModel.fromMap(String id, Map<String, dynamic> data) {
    return StudentModel(
      id: id,
      nome: (data['nome'] as String?) ?? '',
      dataNascimento: _parseDate(data['dataNascimento']),
      responsibleName: (data['responsibleName'] as String?) ?? '',
      responsibleCpf: (data['responsibleCpf'] as String?) ?? '',
      escolaId: (data['escolaId'] as String?) ?? '',
      turmaId: data['turmaId'] as String?,
      createdAt: _parseDate(data['createdAt']),
    );
  }

  // ── Serialization ──────────────────────────────────────────────────────────
  Map<String, dynamic> toMap() => {
    'nome': nome,
    'responsibleName': responsibleName,
    'responsibleCpf': responsibleCpf,
    'escolaId': escolaId,
    if (dataNascimento != null)
      'dataNascimento': Timestamp.fromDate(dataNascimento!),
    if (turmaId != null) 'turmaId': turmaId,
  };

  // ── CopyWith ───────────────────────────────────────────────────────────────
  StudentModel copyWith({
    String? nome,
    DateTime? dataNascimento,
    String? responsibleName,
    String? responsibleCpf,
    String? turmaId,
  }) {
    return StudentModel(
      id: id,
      nome: nome ?? this.nome,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      responsibleName: responsibleName ?? this.responsibleName,
      responsibleCpf: responsibleCpf ?? this.responsibleCpf,
      escolaId: escolaId,
      turmaId: turmaId ?? this.turmaId,
      createdAt: createdAt,
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
  String toString() => 'StudentModel(id: $id, nome: $nome)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is StudentModel && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
