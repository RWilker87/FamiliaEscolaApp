import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../services/student_service.dart';
import '../shared/providers/user_provider.dart';
import '../shared/widgets/app_avatar.dart';
import '../shared/widgets/confirm_dialog.dart';
import '../shared/widgets/app_empty_state.dart';
import '../shared/widgets/app_loading_skeleton.dart';
import '../core/constants/app_shadows.dart';
import '../core/constants/app_colors.dart';
import 'profile_edit_page.dart';
import 'school_details_page.dart';
import 'aluno_detalhes_page.dart';
import '../data/models/student_model.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userModelAsync = ref.watch(userModelProvider);
    final studentService = StudentService();

    return userModelAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text("Usuário não encontrado")),
          );
        }

        final isGestor = user.isGestor;
        final schoolId = user.escolaId;

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: const Text(
              "Perfil",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            elevation: 0,
            backgroundColor: Colors.white,
            centerTitle: false,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileHeader(context, user),
                const SizedBox(height: 24),
                _buildInfoCard(context, user),
                const SizedBox(height: 24),

                // Botão Editar Perfil
                FilledButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileEditPage()),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  label: const Text("Editar Perfil"),
                ),

                const SizedBox(height: 12),

                // Botão Sair da Conta
                OutlinedButton.icon(
                  onPressed: () async {
                    await ConfirmDialog.show(
                      context,
                      title: "Confirmar Saída",
                      message: "Deseja realmente sair da sua conta?",
                      confirmLabel: "Sair",
                      isDestructive: true,
                      onConfirm: () async {
                        await FirebaseAuth.instance.signOut();
                      },
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                    side: BorderSide(color: Theme.of(context).colorScheme.error, width: 1.5),
                  ),
                  icon: const Icon(Icons.exit_to_app, size: 20),
                  label: const Text("Sair da Conta"),
                ),

                const SizedBox(height: 24),

                // Gestão → Gerenciar Escola
                if (isGestor && schoolId != null)
                  _buildManageSchoolCard(context, schoolId),

                // Responsável → Listar alunos
                if (!isGestor && schoolId != null)
                  Builder(
                    builder: (context) {
                      final cpf = user.cpf;
                      if (cpf.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.warningLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.warning),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber, color: AppColors.warningDark),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  "CPF não cadastrado. Entre em contato com a escola.",
                                  style: TextStyle(
                                    color: AppColors.warningDark,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: studentService.getStudentsForResponsibleByCpf(schoolId, cpf),
                        builder: (context, studentSnapshot) {
                          if (studentSnapshot.connectionState == ConnectionState.waiting) {
                            return AppLoadingSkeleton.list(itemCount: 2);
                          }
                          if (!studentSnapshot.hasData || studentSnapshot.data!.docs.isEmpty) {
                            return const AppEmptyState(
                              icon: Icons.school_outlined,
                              title: 'Nenhum aluno vinculado',
                              description: 'Entre em contato com a escola para vincular alunos',
                            );
                          }
                          final students = studentSnapshot.data!.docs;
                          return _buildStudentsList(students, context);
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: AppLoadingSkeleton.list(itemCount: 3),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text("Erro ao carregar perfil: $err")),
      ),
    );
  }

  Widget _buildManageSchoolCard(BuildContext context, String schoolId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.school,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        title: const Text(
          'Gerenciar Escola',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF2D3748),
          ),
        ),
        subtitle: const Text(
          'Editar informações da sua escola',
          style: TextStyle(
            color: Color(0xFF718096),
            fontSize: 14,
          ),
        ),
        trailing: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.arrow_forward,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SchoolDetailsPage(schoolId: schoolId),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStudentsList(List<QueryDocumentSnapshot<Map<String, dynamic>>> students, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16, top: 8),
          child: Text(
            'Alunos Vinculados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3748),
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: students.length,
          itemBuilder: (context, index) {
            final studentDoc = students[index];
            final student = StudentModel.fromFirestore(studentDoc);
            final nascimento = student.dataNascimento;
            String idade = '';

            if (nascimento != null) {
              final hoje = DateTime.now();
              int anos = hoje.year - nascimento.year;
              if (hoje.month < nascimento.month ||
                  (hoje.month == nascimento.month && hoje.day < nascimento.day)) {
                anos--;
              }
              idade = ' • $anos anos';
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: AppAvatar(
                  name: student.nome,
                  radius: 25,
                  heroTag: 'student_avatar_${student.id}',
                ),
                title: Text(
                  student.nome.isNotEmpty ? student.nome : 'Nome não informado',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3748),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    if (nascimento != null)
                      Text(
                        'Nascimento: ${DateFormat('dd/MM/yyyy').format(nascimento)}$idade',
                        style: const TextStyle(
                          color: Color(0xFF718096),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
                trailing: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_forward,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AlunoDetalhesPage(
                            alunoId: studentDoc.id,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    final nome = user.nome;
    final roleLabel = user.roleLabel;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Theme.of(context).colorScheme.primary, const Color(0xFF22C55E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppShadows.colored(Theme.of(context).colorScheme.primary, opacity: 0.25),
      ),
      child: Row(
        children: [
          AppAvatar(
            name: nome,
            radius: 40,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            textColor: Colors.white,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nome,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    roleLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, user) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações Pessoais',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(context, Icons.person_outline, "Nome", user.nome),
            const SizedBox(height: 12),
            _buildInfoRow(context, Icons.credit_card_outlined, "CPF", user.cpf.isNotEmpty ? user.cpf : 'Não informado'),
            const SizedBox(height: 12),
            _buildInfoRow(context, Icons.email_outlined, "E-mail", user.email),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF718096),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2D3748),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}