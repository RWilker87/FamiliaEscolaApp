import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../shared/providers/user_provider.dart';
import '../shared/widgets/app_empty_state.dart';
import '../shared/widgets/app_loading_skeleton.dart';
import '../shared/widgets/aviso_card.dart';
import '../shared/widgets/confirm_dialog.dart';
import '../shared/widgets/staggered_fade_slide.dart';
import '../shared/widgets/animated_fab.dart';
import '../core/constants/app_spacing.dart';
import '../data/models/user_model.dart';
import 'adicionar_avisos_page.dart';

class AvisosPage extends ConsumerWidget {
  const AvisosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userModelAsync = ref.watch(userModelProvider);

    return userModelAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text("Usuário não encontrado")),
          );
        }

        final uid = user.uid;
        final role = user.role == UserRole.gestor ? 'gestao' : 'responsavel';
        final escolaId = user.escolaId;

        if (escolaId == null || escolaId.isEmpty) {
          return const Scaffold(
            body: Center(child: Text("Usuário não vinculado a nenhuma escola.")),
          );
        }

        final avisosQuery = FirebaseFirestore.instance
            .collection('avisos')
            .where('escolaId', isEqualTo: escolaId)
            .orderBy('data', descending: true);

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: const Text(
              "Avisos da Escola",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            elevation: 0,
            backgroundColor: Colors.white,
            centerTitle: false,
          ),
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: avisosQuery.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return AppLoadingSkeleton.cards(itemCount: 3);
              }
              if (snapshot.hasError) {
                return Center(child: Text("Erro ao carregar avisos: ${snapshot.error}"));
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const AppEmptyState(
                  icon: Icons.notifications_off_outlined,
                  title: "Nenhum aviso disponível",
                  description: "Sua escola ainda não publicou avisos.",
                );
              }

              final avisos = snapshot.data!.docs;

              return RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 800));
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.pagePadding),
                  itemCount: avisos.length,
                  itemBuilder: (context, i) {
                    final doc = avisos[i];
                    final aviso = doc.data();
                    final lidoPor = List<String>.from(aviso['lidoPor'] ?? []);
                    final jaLido = lidoPor.contains(uid);
                    final data = (aviso['data'] as Timestamp?)?.toDate();

                    return StaggeredFadeSlide(
                      index: i,
                      child: AvisoCard(
                        title: (aviso['titulo'] ?? '').toString(),
                        message: (aviso['mensagem'] ?? '').toString(),
                        date: data,
                        jaLido: jaLido,
                        role: role,
                        readCount: lidoPor.length,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AvisoDetalhesPage(
                                avisoId: doc.id,
                                aviso: aviso,
                                role: role,
                                uid: uid,
                                jaLido: jaLido,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
          floatingActionButton: role == 'gestao'
              ? AnimatedFAB(
                  child: FloatingActionButton.extended(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdicionarAvisoPage()),
                      );
                    },
                    label: const Text("Novo Aviso"),
                    icon: const Icon(Icons.add),
                  ),
                )
              : null,
        );
      },
      loading: () => Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: AppLoadingSkeleton.cards(itemCount: 3),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text("Erro ao carregar avisos: $err")),
      ),
    );
  }
}

class AvisoDetalhesPage extends StatelessWidget {
  final String avisoId;
  final Map<String, dynamic> aviso;
  final String role;
  final String uid;
  final bool jaLido;

  const AvisoDetalhesPage({
    super.key,
    required this.avisoId,
    required this.aviso,
    required this.role,
    required this.uid,
    required this.jaLido,
  });

  String _fmtData(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    return DateFormat('dd/MM/yyyy \'às\' HH:mm').format(dt);
  }

  Future<void> _marcarComoLido() async {
    if (role == 'responsavel' && !jaLido) {
      await FirebaseFirestore.instance.collection('avisos').doc(avisoId).update({
        'lidoPor': FieldValue.arrayUnion([uid])
      });
    }
  }

  Future<void> _excluirAviso(BuildContext context) async {
    final confirm = await ConfirmDialog.show(
      context,
      title: "Excluir Aviso",
      message: "Tem certeza que deseja excluir este aviso? Esta ação não pode ser desfeita.",
      confirmLabel: "Excluir",
      isDestructive: true,
      onConfirm: () async {
        await FirebaseFirestore.instance.collection('avisos').doc(avisoId).delete();
      },
    );

    if (confirm == true) {
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    _marcarComoLido();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Detalhes do Aviso"),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (role == 'gestao') ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: "Editar",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdicionarAvisoPage(avisoId: avisoId, aviso: aviso),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              tooltip: "Excluir",
              onPressed: () => _excluirAviso(context),
            ),
          ],
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              aviso['titulo'] ?? 'Sem título',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.schedule, size: 14, color: Color(0xFFA0AEC0)),
                const SizedBox(width: 4),
                Text(
                  _fmtData(aviso['data'] as Timestamp?),
                  style: const TextStyle(fontSize: 12, color: Color(0xFFA0AEC0)),
                ),
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  aviso['mensagem'] ?? 'Sem mensagem',
                  style: const TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF2D3748)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
