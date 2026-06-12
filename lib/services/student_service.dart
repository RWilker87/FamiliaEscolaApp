import 'package:cloud_firestore/cloud_firestore.dart';

class StudentService {
  final _db = FirebaseFirestore.instance;

  /// ➕ Adiciona um novo aluno na coleção raiz 'students'
  Future<void> addStudent({
    required String schoolId,
    required String studentName,
    required String studentBirthDate,
    required String responsibleName,
    required String responsibleCpf,
  }) async {
    await _db.collection('students').add({
      'nome': studentName,
      'dataNascimento': studentBirthDate,
      'responsibleName': responsibleName,
      'responsibleCpf': responsibleCpf,
      'escolaId': schoolId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Busca alunos vinculados a um responsável pelo CPF em uma escola específica
  /// CORREÇÃO: Agora busca na coleção raiz 'students'
  Stream<QuerySnapshot<Map<String, dynamic>>> getStudentsForResponsibleByCpf(
      String schoolId, String cpf) {
    return _db
        .collection('students')
        .where('responsibleCpf', isEqualTo: cpf)
        .where('escolaId', isEqualTo: schoolId)
        .snapshots();
  }

  /// ✏️ Atualiza dados de um aluno na coleção raiz 'students'
  Future<void> updateStudent(String studentId, Map<String, dynamic> data) async {
    await _db
        .collection('students')
        .doc(studentId)
        .update(data);
  }

  /// ❌ Remove um aluno da coleção raiz 'students'
  Future<void> deleteStudent(String studentId) async {
    await _db
        .collection('students')
        .doc(studentId)
        .delete();
  }
}