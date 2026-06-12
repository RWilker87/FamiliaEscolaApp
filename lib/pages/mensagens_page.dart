import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../shared/providers/user_provider.dart';
import '../shared/widgets/confirm_dialog.dart';
import '../shared/widgets/app_empty_state.dart';
import '../shared/widgets/app_loading_skeleton.dart';
import '../shared/widgets/conversation_tile.dart';
import '../shared/widgets/staggered_fade_slide.dart';
import 'selecionar_responsavel_page.dart';

/// Abre (ou cria) uma conversa 1-1 entre [meUid] e [otherUid].
/// Retorna o conversaId.
Future<String> _openOrCreate1to1({
  required String escolaId,
  required String meUid,
  required String otherUid,
}) async {
  // Ordena os UIDs para criar uma chave única determinística
  final list = [meUid, otherUid]..sort();
  final pairId = '${list[0]}_${list[1]}';
  
  final conversaRef = FirebaseFirestore.instance
      .collection('escolas')
      .doc(escolaId)
      .collection('conversas')
      .doc(pairId);

  // Pega dados do próprio usuário
  final meDoc = await FirebaseFirestore.instance.collection('users').doc(meUid).get();
  final meData = meDoc.data() ?? {};
  final meuRole = meData['role'] ?? '';

  // Pega dados do outro usuário (se for gestor tem permissão total, senão retorna Gestão)
  Map<String, dynamic> otherData = {};
  if (meuRole == 'gestao') {
    final otherDoc = await FirebaseFirestore.instance.collection('users').doc(otherUid).get();
    otherData = otherDoc.data() ?? {};
  }

  final otherNome = otherData['nome'] ?? 'Gestão';
  final otherRole = otherData['role'] ?? 'gestao';

  await conversaRef.set({
    'escolaId': escolaId,
    'tipo': '1-1',
    'participantes': [meUid, otherUid],
    'participantesInfo': {
      meUid: {'nome': meData['nome'] ?? 'Você', 'role': meuRole},
      otherUid: {'nome': otherNome, 'role': otherRole},
    },
    'titulo': otherNome,
    'ultimoTexto': '',
    'atualizadoEm': FieldValue.serverTimestamp(),
    'unread': {meUid: 0, otherUid: 0},
  }, SetOptions(merge: true));

  return conversaRef.id;
}

/// Helper compartilhado para deletar conversa e suas mensagens de forma limpa.
Future<void> _deletarConversaCompartilhada({
  required String escolaId,
  required String conversaId,
  required BuildContext context,
  VoidCallback? onSuccess,
}) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  try {
    final conversaRef = FirebaseFirestore.instance
        .collection('escolas')
        .doc(escolaId)
        .collection('conversas')
        .doc(conversaId);

    final conversaDoc = await conversaRef.get();
    if (!conversaDoc.exists) return;

    final participantes = List<String>.from(conversaDoc['participantes'] ?? []);
    if (!participantes.contains(uid)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Você não tem permissão para deletar esta conversa.')),
        );
      }
      return;
    }

    final confirmar = await ConfirmDialog.show(
      context,
      title: 'Deletar conversa',
      message: 'Tem certeza que deseja deletar esta conversa? Esta ação não pode ser desfeita.',
      confirmLabel: 'Deletar',
      isDestructive: true,
      onConfirm: () {},
    );

    if (confirmar != true) return;

    // Deleta mensagens
    final mensagensSnapshot = await conversaRef.collection('mensagens').get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in mensagensSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    // Deleta conversa
    await conversaRef.delete();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conversa deletada com sucesso.')),
      );
      if (onSuccess != null) {
        onSuccess();
      }
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao deletar conversa: $e')),
      );
    }
  }
}

class MensagensPage extends ConsumerWidget {
  const MensagensPage({super.key});

  Future<void> _startChatWithGestor(
    BuildContext context, {
    required String escolaId,
    required String myUid,
  }) async {
    try {
      final escolaDoc = await FirebaseFirestore.instance
          .collection('escolas')
          .doc(escolaId)
          .get();

      final gestorId = escolaDoc.data()?['gestorId'] as String?;
      if (gestorId == null || gestorId.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('⚠️ Escola sem gestor vinculado.')),
          );
        }
        return;
      }

      final conversaId = await _openOrCreate1to1(
        escolaId: escolaId,
        meUid: myUid,
        otherUid: gestorId,
      );

      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MensagensThreadPage(
              escolaId: escolaId,
              conversaId: conversaId,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao iniciar conversa: $e')),
        );
      }
    }
  }

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
        final escolaId = user.escolaId;
        final isGestor = user.isGestor;

        if (escolaId == null || escolaId.isEmpty) {
          return const Scaffold(
            body: Center(child: Text("Usuário não vinculado a uma escola")),
          );
        }

        final conversasStream = FirebaseFirestore.instance
            .collection("escolas")
            .doc(escolaId)
            .collection("conversas")
            .where("participantes", arrayContains: uid)
            .orderBy("atualizadoEm", descending: true)
            .snapshots();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: const Text(
              "Mensagens",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            elevation: 0,
            backgroundColor: Colors.white,
            centerTitle: false,
            actions: [
              IconButton(
                icon: const Icon(Icons.add_comment_outlined),
                tooltip: "Nova conversa",
                onPressed: () async {
                  if (isGestor) {
                    final selected = await Navigator.push<Map<String, dynamic>?>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SelecionarResponsavelPage(escolaId: escolaId),
                      ),
                    );
                    if (selected != null && selected['uid'] != null) {
                      final conversaId = await _openOrCreate1to1(
                        escolaId: escolaId,
                        meUid: uid,
                        otherUid: selected['uid'] as String,
                      );
                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MensagensThreadPage(
                                escolaId: escolaId, conversaId: conversaId),
                          ),
                        );
                      }
                    }
                  } else {
                    await _startChatWithGestor(context, escolaId: escolaId, myUid: uid);
                  }
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: StreamBuilder<QuerySnapshot>(
            stream: conversasStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return AppLoadingSkeleton.list();
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return AppEmptyState(
                  icon: Icons.forum_outlined,
                  title: "Nenhuma conversa ativa",
                  description: isGestor
                      ? 'Inicie uma conversa com os responsáveis dos alunos'
                      : 'Converse com a coordenação ou professores da escola',
                  actionLabel: isGestor ? 'Iniciar conversa' : 'Conversar com a escola',
                  onActionPressed: () async {
                    if (isGestor) {
                      final selected = await Navigator.push<Map<String, dynamic>?>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SelecionarResponsavelPage(escolaId: escolaId),
                        ),
                      );
                      if (selected != null && selected['uid'] != null) {
                        final conversaId = await _openOrCreate1to1(
                          escolaId: escolaId,
                          meUid: uid,
                          otherUid: selected['uid'] as String,
                        );
                        if (context.mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MensagensThreadPage(
                                  escolaId: escolaId, conversaId: conversaId),
                            ),
                          );
                        }
                      }
                    } else {
                      await _startChatWithGestor(context, escolaId: escolaId, myUid: uid);
                    }
                  },
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  await Future.delayed(const Duration(milliseconds: 800));
                },
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    final dados = doc.data() as Map<String, dynamic>;
                    final ultimoTexto = (dados['ultimoTexto'] ?? '').toString();
                    final unreadMap = Map<String, dynamic>.from(dados['unread'] ?? {});
                    final int minhasNaoLidas = (unreadMap[uid] is int) ? unreadMap[uid] as int : 0;
                    final atualizadoEm = (dados['atualizadoEm'] as Timestamp?)?.toDate();
                    final timeStr = atualizadoEm != null
                        ? DateFormat('HH:mm').format(atualizadoEm)
                        : '';

                    return StaggeredFadeSlide(
                      index: index,
                      child: ConversationTile(
                        title: (dados['titulo'] ?? 'Conversa').toString(),
                        lastMessage: ultimoTexto,
                        time: timeStr,
                        unreadCount: minhasNaoLidas,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MensagensThreadPage(escolaId: escolaId, conversaId: doc.id),
                            ),
                          );
                        },
                        onDelete: () {
                          _deletarConversaCompartilhada(
                            escolaId: escolaId,
                            conversaId: doc.id,
                            context: context,
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
      loading: () => Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: AppLoadingSkeleton.list(),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text("Erro ao carregar mensagens: $err")),
      ),
    );
  }
}

class MensagensThreadPage extends ConsumerStatefulWidget {
  final String escolaId;
  final String conversaId;

  const MensagensThreadPage({
    super.key,
    required this.escolaId,
    required this.conversaId,
  });

  @override
  ConsumerState<MensagensThreadPage> createState() => _MensagensThreadPageState();
}

class _MensagensThreadPageState extends ConsumerState<MensagensThreadPage> {
  final _msgCtrl = TextEditingController();
  final _scrollController = ScrollController();
  bool _marcouLidasNaAbertura = false;

  @override
  void initState() {
    super.initState();
    _marcarConversaComoLida();
    
    // Scroll inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _marcarConversaComoLida() async {
    if (_marcouLidasNaAbertura) return;
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final conversaRef = FirebaseFirestore.instance
        .collection("escolas").doc(widget.escolaId)
        .collection("conversas").doc(widget.conversaId);

    try {
      await conversaRef.update({"unread.$uid": 0});
      final msgs = await conversaRef.collection("mensagens")
          .orderBy("data", descending: true).limit(50).get();

      final batch = FirebaseFirestore.instance.batch();
      for (final m in msgs.docs) {
        final data = m.data();
        final lidoPor = List<String>.from(data['lidoPor'] ?? []);
        if (!lidoPor.contains(uid)) {
          batch.update(m.reference, {'lidoPor': FieldValue.arrayUnion([uid])});
        }
      }
      await batch.commit();
    } catch (_) {} finally {
      _marcouLidasNaAbertura = true;
    }
  }

  Future<void> _marcarMensagensVisiveisComoLidas(List<QueryDocumentSnapshot> docs) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || docs.isEmpty) return;

    final batch = FirebaseFirestore.instance.batch();
    for (final d in docs.take(50)) {
      final data = d.data() as Map<String, dynamic>;
      final lidoPor = List<String>.from(data['lidoPor'] ?? []);
      if (!lidoPor.contains(uid)) {
        batch.update(d.reference, {'lidoPor': FieldValue.arrayUnion([uid])});
      }
    }
    try { await batch.commit(); } catch (_) {}
  }

  Future<void> _enviarMensagem() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _msgCtrl.text.trim().isEmpty) return;

    HapticFeedback.lightImpact();

    final userDoc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
    final userData = userDoc.data() ?? {};
    final conversaRef = FirebaseFirestore.instance
        .collection("escolas").doc(widget.escolaId)
        .collection("conversas").doc(widget.conversaId);

    final conteudo = _msgCtrl.text.trim();

    // 1) cria a mensagem
    final msgRef = conversaRef.collection("mensagens").doc();
    await msgRef.set({
      "autorId": uid,
      "autorNome": userData["nome"] ?? "Anônimo",
      "conteudo": conteudo,
      "tipo": "texto",
      "data": FieldValue.serverTimestamp(),
      "lidoPor": [uid],
    });

    // 2) atualiza conversa
    final convSnap = await conversaRef.get();
    final convData = convSnap.data() ?? {};
    final participantes = List<String>.from(convData['participantes'] ?? []);
    final unread = Map<String, dynamic>.from(convData['unread'] ?? {});

    for (final p in participantes) {
      if (p == uid) continue;
      unread[p] = (unread[p] is int ? unread[p] as int : 0) + 1;
    }

    await conversaRef.update({
      "ultimoTexto": conteudo,
      "atualizadoEm": FieldValue.serverTimestamp(),
      "unread": unread,
    });

    _msgCtrl.clear();

    // Auto scroll para o final após o envio manual
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Conversa",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        elevation: 0.5,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
        actions: [
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.primary),
            onSelected: (value) {
              if (value == 'delete') {
                _deletarConversaCompartilhada(
                  escolaId: widget.escolaId,
                  conversaId: widget.conversaId,
                  context: context,
                  onSuccess: () => Navigator.pop(context),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Text('Deletar conversa', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("escolas").doc(widget.escolaId)
                  .collection("conversas").doc(widget.conversaId)
                  .collection("mensagens")
                  .orderBy("data", descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final mensagens = snapshot.data!.docs;
                _marcarMensagensVisiveisComoLidas(mensagens.cast<QueryDocumentSnapshot>());

                // Inteligência de scroll quando novas mensagens chegam via Stream
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    final maxScroll = _scrollController.position.maxScrollExtent;
                    final currentScroll = _scrollController.position.pixels;
                    // Se estiver próximo do fim (150 pixels ou menos)
                    if (maxScroll - currentScroll < 150) {
                      _scrollController.animateTo(
                        maxScroll,
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                      );
                    }
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  itemCount: mensagens.length,
                  itemBuilder: (context, index) {
                    final data = mensagens[index].data() as Map<String, dynamic>;
                    final autorId = (data["autorId"] ?? '') as String;
                    final autorNome = (data["autorNome"] ?? "Anônimo").toString();
                    final conteudo = (data["conteudo"] ?? "").toString();
                    final timestamp = (data["data"] as Timestamp?)?.toDate();
                    final timeStr = timestamp != null
                        ? DateFormat('HH:mm').format(timestamp)
                        : '';
                    final lidoPor = List<String>.from(data['lidoPor'] ?? []);
                    final isMe = autorId == uid;
                    final outrosLeram = lidoPor.any((x) => x != autorId);

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          if (!isMe)
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  autorNome.isNotEmpty ? autorNome[0].toUpperCase() : '?',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                          if (!isMe) const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isMe
                                    ? Theme.of(context).colorScheme.primary
                                    : const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isMe)
                                    Text(
                                      autorNome,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  if (!isMe) const SizedBox(height: 4),
                                  Text(
                                    conteudo,
                                    style: TextStyle(
                                      color: isMe ? Colors.white : const Color(0xFF1E293B),
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        timeStr,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isMe ? Colors.white70 : const Color(0xFF64748B),
                                        ),
                                      ),
                                      if (isMe) const SizedBox(width: 4),
                                      if (isMe)
                                        Icon(
                                          Icons.done_all,
                                          size: 14,
                                          color: outrosLeram
                                              ? const Color(0xFF86EFAC) // check lido verde
                                              : Colors.white60, // check entregue cinza claro
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: TextField(
                      controller: _msgCtrl,
                      decoration: const InputDecoration(
                        hintText: "Digite sua mensagem...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                      ),
                      onSubmitted: (_) => _enviarMensagem(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _enviarMensagem,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}