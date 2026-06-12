import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { gestor, responsavel }

class UserModel {
  final String uid;
  final String nome;
  final String email;
  final String cpf;
  final UserRole role;
  final String? escolaId;
  final DateTime? dataNascimento;
  final DateTime? createdAt;

  const UserModel({
    required this.uid,
    required this.nome,
    required this.email,
    required this.cpf,
    required this.role,
    this.escolaId,
    this.dataNascimento,
    this.createdAt,
  });

  // ── Convenience getters ────────────────────────────────────────────────────
  bool get isGestor     => role == UserRole.gestor;
  bool get isResponsavel => role == UserRole.responsavel;
  bool get hasSchool    => escolaId != null && escolaId!.isNotEmpty;

  String get roleLabel => isGestor ? 'Gestão Escolar' : 'Responsável';

  String get initials {
    final parts = nome.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return nome.isNotEmpty ? nome[0].toUpperCase() : '?';
  }

  // ── Factory from Firestore ─────────────────────────────────────────────────
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      nome: (data['nome'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      cpf: (data['cpf'] as String?) ?? '',
      role: _parseRole(data['role'] as String?),
      escolaId: data['escolaId'] as String?,
      dataNascimento: _parseDate(data['dataNascimento']),
      createdAt: _parseDate(data['createdAt']),
    );
  }

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      nome: (data['nome'] as String?) ?? '',
      email: (data['email'] as String?) ?? '',
      cpf: (data['cpf'] as String?) ?? '',
      role: _parseRole(data['role'] as String?),
      escolaId: data['escolaId'] as String?,
      dataNascimento: _parseDate(data['dataNascimento']),
      createdAt: _parseDate(data['createdAt']),
    );
  }

  // ── Serialization ──────────────────────────────────────────────────────────
  Map<String, dynamic> toMap() => {
    'nome': nome,
    'email': email,
    'cpf': cpf,
    'role': role == UserRole.gestor ? 'gestao' : 'responsavel',
    if (escolaId != null) 'escolaId': escolaId,
    if (dataNascimento != null)
      'dataNascimento': Timestamp.fromDate(dataNascimento!),
  };

  // ── CopyWith ───────────────────────────────────────────────────────────────
  UserModel copyWith({
    String? nome,
    String? email,
    String? cpf,
    UserRole? role,
    String? escolaId,
    DateTime? dataNascimento,
  }) {
    return UserModel(
      uid: uid,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      cpf: cpf ?? this.cpf,
      role: role ?? this.role,
      escolaId: escolaId ?? this.escolaId,
      dataNascimento: dataNascimento ?? this.dataNascimento,
      createdAt: createdAt,
    );
  }

  static UserRole _parseRole(String? raw) {
    return raw == 'gestao' ? UserRole.gestor : UserRole.responsavel;
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
  String toString() => 'UserModel(uid: $uid, nome: $nome, role: $role)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is UserModel && other.uid == uid);

  @override
  int get hashCode => uid.hashCode;
}
