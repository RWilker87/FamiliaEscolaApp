import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../shared/providers/user_provider.dart';
import '../shared/widgets/app_avatar.dart';
import '../shared/widgets/app_empty_state.dart';
import '../shared/widgets/app_section_header.dart';
import '../shared/widgets/app_loading_skeleton.dart';
import '../shared/widgets/aviso_card.dart';
import '../shared/widgets/notification_badge.dart';
import '../shared/widgets/staggered_fade_slide.dart';
import 'alunos_page.dart';
import 'mensagens_page.dart';
import 'school_details_page.dart';
import 'turmas_page.dart';
import 'add_student_page.dart';
import 'avisos_page.dart';
import 'responsaveis_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String? _escolaId;

  // Helper: inscreve no tópico da escola
  void _subscribeToSchoolTopic(String escolaId) {
    if (_escolaId != escolaId) {
      _escolaId = escolaId;
      FirebaseMessaging.instance.subscribeToTopic("escola_$escolaId");
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userModelProvider);

    return userAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text("Usuário não encontrado")),
          );
        }

        final uid = user.uid;
        final nomeUsuario = user.nome;
        final isGestor = user.isGestor;
        final escolaId = user.escolaId;

        if (escolaId == null || escolaId.isEmpty) {
          return const Scaffold(
            body: Center(
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
                    "Usuário não vinculado a uma escola",
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF718096),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        _subscribeToSchoolTopic(escolaId);

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: const Text(
              "Família & Escola",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: -0.5,
              ),
            ),
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.white,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userModelProvider);
              await Future.delayed(const Duration(milliseconds: 800));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header de boas-vindas
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        AppAvatar(
                          name: nomeUsuario,
                          radius: 25,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Olá, $nomeUsuario!",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2D3748),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isGestor ? "Perfil: Gestão Escolar" : "Perfil: Responsável",
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF718096),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Quadro de Avisos
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('avisos')
                          .where('escolaId', isEqualTo: escolaId)
                          .orderBy('data', descending: true)
                          .limit(3)
                          .snapshots(),
                      builder: (context, avisoSnapshot) {
                        if (avisoSnapshot.connectionState == ConnectionState.waiting) {
                          return AppLoadingSkeleton.list(itemCount: 2, showAvatar: false);
                        }

                        if (!avisoSnapshot.hasData || avisoSnapshot.data!.docs.isEmpty) {
                          return const AppEmptyState(
                            icon: Icons.campaign_outlined,
                            title: "Nenhum aviso disponível",
                            description: "Fique atento para as próximas atualizações da escola.",
                          );
                        }

                        final avisos = avisoSnapshot.data!.docs;

                        int naoLidos = 0;
                        if (!isGestor) {
                          for (var aviso in avisos) {
                            final data = aviso.data() as Map<String, dynamic>;
                            final lidoPor = List<String>.from(data['lidoPor'] ?? []);
                            if (!lidoPor.contains(uid)) {
                              naoLidos++;
                            }
                          }
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppSectionHeader(
                              title: "Quadro de Avisos",
                              icon: Icons.campaign_outlined,
                              trailing: (!isGestor && naoLidos > 0)
                                  ? NotificationBadge(count: naoLidos)
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: avisos.length,
                              itemBuilder: (context, index) {
                                final doc = avisos[index];
                                final aviso = doc.data() as Map<String, dynamic>;
                                final titulo = aviso['titulo'] ?? "Sem título";
                                final mensagem = aviso['mensagem'] ?? "";
                                final data = (aviso['data'] as Timestamp?)?.toDate();
                                final lidoPor = List<String>.from(aviso['lidoPor'] ?? []);
                                final jaLido = isGestor || lidoPor.contains(uid);

                                return StaggeredFadeSlide(
                                  index: index,
                                  child: AvisoCard(
                                    title: titulo,
                                    message: mensagem,
                                    date: data,
                                    jaLido: jaLido,
                                    role: isGestor ? 'gestao' : 'responsavel',
                                    readCount: lidoPor.length,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AvisoDetalhesPage(
                                            avisoId: doc.id,
                                            aviso: aviso,
                                            role: isGestor ? 'gestao' : 'responsavel',
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
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const AvisosPage()),
                                  );
                                },
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("Ver todos os avisos"),
                                    SizedBox(width: 4),
                                    Icon(Icons.arrow_forward, size: 16),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  const AppSectionHeader(
                    title: "Atalhos Rápidos",
                    icon: Icons.grid_view_outlined,
                  ),

                  const SizedBox(height: 16),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.4,
                    children: [
                      StaggeredFadeSlide(
                        index: 0,
                        child: _menuButton("Alunos", Icons.people_outline, Theme.of(context).colorScheme.primary, () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AlunosPage()),
                          );
                        }),
                      ),
                      StaggeredFadeSlide(
                        index: 1,
                        child: _menuButton("Turmas", Icons.class_outlined, const Color(0xFF6B0000), () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TurmasPage()),
                          );
                        }),
                      ),
                      StaggeredFadeSlide(
                        index: 2,
                        child: _menuButton("Mensagens", Icons.chat_outlined, const Color(0xFFED8936), () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MensagensPage()),
                          );
                        }),
                      ),
                      if (isGestor)
                        StaggeredFadeSlide(
                          index: 3,
                          child: _menuButton("Adicionar Aluno", Icons.person_add_outlined, const Color(0xFF4299E1), () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const AddStudentPage()),
                            );
                          }),
                        ),
                      if (isGestor)
                        StaggeredFadeSlide(
                          index: 4,
                          child: _menuButton("Responsáveis", Icons.supervised_user_circle_outlined, const Color(0xFF9F7AEA), () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ResponsaveisPage(
                                  escolaId: escolaId,
                                  gestorUid: uid,
                                ),
                              ),
                            );
                          }),
                        ),
                      StaggeredFadeSlide(
                        index: isGestor ? 5 : 3,
                        child: _menuButton("Escola", Icons.school_outlined, const Color(0xFFF56565), () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SchoolDetailsPage(schoolId: escolaId),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text("Erro ao carregar página inicial: $err")),
      ),
    );
  }

  Widget _menuButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3748),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}