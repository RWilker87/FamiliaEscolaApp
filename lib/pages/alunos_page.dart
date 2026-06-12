import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared/providers/user_provider.dart';
import '../shared/widgets/staggered_fade_slide.dart';
import '../data/models/user_model.dart';
import 'aluno_detalhes_page.dart';

class AlunosPage extends ConsumerWidget {
  const AlunosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userModelAsync = ref.watch(userModelProvider);

    return userModelAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text("Usuário não autenticado")),
          );
        }

        final role = user.role == UserRole.gestor ? 'gestao' : 'responsavel';
        final escolaIdUser = user.escolaId;
        final userName = user.nome;

        if (escolaIdUser == null || escolaIdUser.isEmpty) {
          return const Scaffold(
            body: Center(child: Text("Usuário não vinculado a uma escola")),
          );
        }

        // Query de alunos
        Query alunosQuery;
        if (role == 'gestao') {
          alunosQuery = FirebaseFirestore.instance
              .collection('students')
              .where('escolaId', isEqualTo: escolaIdUser)
              .orderBy('nome');
        } else {
          final cpfUsuario = user.cpf;
          if (cpfUsuario.isEmpty) {
            return const Scaffold(
              body: Center(child: Text("CPF do usuário não cadastrado")),
            );
          }

          alunosQuery = FirebaseFirestore.instance
              .collection('students')
              .where('escolaId', isEqualTo: escolaIdUser)
              .where('responsibleCpf', isEqualTo: cpfUsuario)
              .orderBy('nome');
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: const Text(
              'Alunos',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2D3748),
            elevation: 0,
            centerTitle: false,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header informativo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.people_alt_outlined,
                        size: 24,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            role == 'gestao' ? 'Todos os Alunos' : 'Meus Alunos',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            role == 'gestao'
                                ? 'Escola ID: $escolaIdUser'
                                : 'Alunos vinculados a $userName',
                            style: const TextStyle(
                              color: Color(0xFF718096),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de alunos
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: alunosQuery.snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("Erro ao carregar alunos: ${snapshot.error}"));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.school_outlined,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              role == 'gestao'
                                  ? 'Nenhum aluno cadastrado'
                                  : 'Nenhum aluno vinculado',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF718096),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              role == 'gestao'
                                  ? 'ID da Escola: $escolaIdUser'
                                  : 'Verifique o CPF cadastrado ou contate a administração',
                              style: const TextStyle(
                                color: Color(0xFFA0AEC0),
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    final alunos = snapshot.data!.docs;

                    return Column(
                      children: [
                        // Contador de alunos
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          color: Colors.grey.shade50,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total: ${alunos.length} aluno(s)',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              Text(
                                'Escola ID: $escolaIdUser',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF718096),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Lista
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              await Future.delayed(const Duration(milliseconds: 800));
                            },
                            child: ListView.separated(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemCount: alunos.length,
                              itemBuilder: (context, index) {
                                final alunoDoc = alunos[index];
                                final aluno = alunoDoc.data() as Map<String, dynamic>;

                                final alunoNome = aluno['nome'] ?? 'Sem nome';
                                final responsavelNome = aluno['responsibleName'] ?? 'Não informado';
                                final escolaIdAluno = aluno['escolaId'] ?? '';

                                return StaggeredFadeSlide(
                                  index: index,
                                  child: Container(
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
                                      leading: Hero(
                                        tag: 'student_avatar_${alunoDoc.id}',
                                        child: Material(
                                          type: MaterialType.transparency,
                                          child: Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                alunoNome.isNotEmpty ? alunoNome[0].toUpperCase() : "?",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context).colorScheme.primary,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      title: Text(
                                        alunoNome,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2D3748),
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            "Responsável: $responsavelNome",
                                            style: const TextStyle(
                                              color: Color(0xFF718096),
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "Escola ID: $escolaIdAluno",
                                            style: const TextStyle(
                                              color: Color(0xFFA0AEC0),
                                              fontSize: 10,
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
                                                  alunoId: alunoDoc.id,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text("Erro ao carregar perfil: $err")),
      ),
    );
  }
}
