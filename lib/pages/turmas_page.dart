import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'add_turma_page.dart';
import 'turma_detalhes_page.dart';
import '../shared/providers/user_provider.dart';
import '../shared/widgets/staggered_fade_slide.dart';
import '../shared/widgets/animated_fab.dart';
import '../data/models/user_model.dart';

class TurmasPage extends ConsumerWidget {
  const TurmasPage({super.key});

  Future<void> _editarTurma(
      BuildContext context, String escolaId, String turmaId, String nomeAtual) async {
    final controller = TextEditingController(text: nomeAtual);

    await showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Editar Turma",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: "Nome da turma",
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancelar"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        if (controller.text.trim().isNotEmpty) {
                          await FirebaseFirestore.instance
                              .collection('escolas')
                              .doc(escolaId)
                              .collection('turmas')
                              .doc(turmaId)
                              .update({"nome": controller.text.trim()});
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      child: const Text("Salvar"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _excluirTurma(
      BuildContext context, String escolaId, String turmaId) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Excluir Turma"),
        content: const Text("Tem certeza que deseja excluir esta turma?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancelar"),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text("Excluir"),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      await FirebaseFirestore.instance
          .collection('escolas')
          .doc(escolaId)
          .collection('turmas')
          .doc(turmaId)
          .delete();
    }
  }

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
        final escolaId = user.escolaId;

        if (role != 'gestao') {
          return Scaffold(
            appBar: AppBar(title: const Text("Acesso restrito")),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_outline,
                    size: 64,
                    color: Colors.orange.shade400,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Acesso restrito",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Apenas gestores podem acessar esta funcionalidade",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (escolaId == null || escolaId.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text("Gestor não vinculado")),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: Color(0xFFA0AEC0),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Gestor não vinculado",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Você não está vinculado a nenhuma escola",
                    style: TextStyle(
                      color: Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: const Text(
              "Gerenciar Turmas",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2D3748),
            elevation: 0,
            centerTitle: false,
          ),
          body: Column(
            children: [
              // Header
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
                        Icons.group,
                        size: 24,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Gerenciar Turmas",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Organize os alunos em turmas",
                            style: TextStyle(
                              color: Color(0xFF718096),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de turmas
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('escolas')
                      .doc(escolaId)
                      .collection('turmas')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.group_outlined,
                              size: 64,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "Nenhuma turma encontrada",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF718096),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Comece criando sua primeira turma",
                              style: TextStyle(
                                color: Color(0xFFA0AEC0),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final turmas = snapshot.data!.docs;

                    return RefreshIndicator(
                      onRefresh: () async {
                        await Future.delayed(const Duration(milliseconds: 800));
                      },
                      child: ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemCount: turmas.length,
                        itemBuilder: (context, index) {
                          final turmaDoc = turmas[index];
                          final turma = turmaDoc.data() as Map<String, dynamic>;
                          final turmaNome = turma['nome'] ?? 'Sem nome';

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
                                leading: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.class_outlined,
                                    size: 24,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                                title: Text(
                                  turmaNome,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2D3748),
                                  ),
                                ),
                                trailing: PopupMenuButton<String>(
                                  icon: const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
                                  onSelected: (value) {
                                    if (value == 'editar') {
                                      _editarTurma(
                                          context, escolaId, turmaDoc.id, turmaNome);
                                    } else if (value == 'excluir') {
                                      _excluirTurma(context, escolaId, turmaDoc.id);
                                    }
                                  },
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'editar',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit_outlined, size: 20, color: Colors.blue),
                                          SizedBox(width: 8),
                                          Text("Editar"),
                                        ],
                                      ),
                                    ),
                                    const PopupMenuItem(
                                      value: 'excluir',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                          SizedBox(width: 8),
                                          Text("Excluir"),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => TurmaDetalhesPage(
                                        escolaId: escolaId,
                                        turmaId: turmaDoc.id,
                                        turmaNome: turmaNome,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton: AnimatedFAB(
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddTurmaPage()),
                );
              },
              child: const Icon(Icons.add, size: 24),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text("Erro ao carregar turmas: $err")),
      ),
    );
  }
}