import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../shared/providers/user_provider.dart';

class DashboardPage extends ConsumerWidget {
  final String escolaId;

  const DashboardPage({super.key, required this.escolaId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userModelAsync = ref.watch(userModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          "Dashboard da Escola",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF2D3748),
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.primary),
      ),
      body: userModelAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text("Usuário não encontrado"));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.only(bottom: 20),
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
                          Icons.analytics_outlined,
                          size: 24,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          "Visão Geral da Escola",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                // Seção: Indicadores Gerais
                _buildSectionTitle(context, Icons.bar_chart_outlined, "Indicadores Gerais"),
                const SizedBox(height: 16),
                _buildRealtimeResumoGrid(user.uid),

                const SizedBox(height: 28),
                const Divider(height: 1),
                const SizedBox(height: 28),

                // Seção: Alunos por Turma
                _buildSectionTitle(context, Icons.pie_chart_outline, "Distribuição de Alunos por Turma"),
                const SizedBox(height: 16),
                _buildRealtimeAlunosPorTurma(),

                const SizedBox(height: 28),
                const Divider(height: 1),
                const SizedBox(height: 28),

                // Seção: Avisos Publicados
                _buildSectionTitle(context, Icons.campaign_outlined, "Avisos Publicados por Mês"),
                const SizedBox(height: 16),
                _buildRealtimeAvisosPorMes(),

                const SizedBox(height: 28),
                const Divider(height: 1),
                const SizedBox(height: 28),

                // Seção: Atividade Fórum
                _buildSectionTitle(context, Icons.forum_outlined, "Atividade no Fórum"),
                const SizedBox(height: 16),
                _buildRealtimeForumAtividade(),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text("Erro ao carregar dados: $err")),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
      ],
    );
  }

  // Grid de Indicadores em tempo real utilizando múltiplos StreamBuilders reativos
  Widget _buildRealtimeResumoGrid(String uid) {
    final db = FirebaseFirestore.instance;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.35,
      children: [
        _buildStreamCard(
          title: "Alunos",
          stream: db.collection('students').where('escolaId', isEqualTo: escolaId).snapshots(),
          icon: Icons.people_outline,
          color: const Color(0xFF16A34A),
        ),
        _buildStreamCard(
          title: "Turmas",
          stream: db.collection('escolas').doc(escolaId).collection('turmas').snapshots(),
          icon: Icons.class_outlined,
          color: const Color(0xFF3B82F6),
        ),
        _buildStreamCard(
          title: "Avisos",
          stream: db.collection('avisos').where('escolaId', isEqualTo: escolaId).snapshots(),
          icon: Icons.campaign_outlined,
          color: const Color(0xFFF59E0B),
        ),
        _buildStreamCard(
          title: "Conversas",
          stream: db.collection('escolas').doc(escolaId).collection('conversas').where('participantes', arrayContains: uid).snapshots(),
          icon: Icons.chat_bubble_outline,
          color: const Color(0xFF8B5CF6),
        ),
        _buildStreamCard(
          title: "Tópicos",
          stream: db.collection('escolas').doc(escolaId).collection('forum').snapshots(),
          icon: Icons.forum_outlined,
          color: const Color(0xFF14B8A6),
        ),
      ],
    );
  }

  Widget _buildStreamCard({
    required String title,
    required Stream<QuerySnapshot> stream,
    required IconData icon,
    required Color color,
  }) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Container(
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
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: color),
                ),
                const SizedBox(height: 8),
                isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                const SizedBox(height: 2),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Pizza Chart: Alunos por turma em tempo real
  Widget _buildRealtimeAlunosPorTurma() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("students")
          .where("escolaId", isEqualTo: escolaId)
          .snapshots(),
      builder: (context, studentSnapshot) {
        if (studentSnapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!studentSnapshot.hasData || studentSnapshot.data!.docs.isEmpty) {
          return _buildEmptyChartPlaceholder("Nenhum aluno cadastrado");
        }

        final alunos = studentSnapshot.data!.docs;
        final Map<String, int> porTurma = {};
        for (var doc in alunos) {
          final data = doc.data() as Map<String, dynamic>;
          final turmaId = data['turmaId'] ?? "Sem turma";
          porTurma[turmaId] = (porTurma[turmaId] ?? 0) + 1;
        }

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("escolas")
              .doc(escolaId)
              .collection("turmas")
              .snapshots(),
          builder: (context, turmaSnapshot) {
            if (!turmaSnapshot.hasData) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            final turmasDocs = turmaSnapshot.data!.docs;
            final Map<String, String> turmaNomes = {
              for (var t in turmasDocs)
                t.id: (t.data() as Map<String, dynamic>)['nome'] ?? t.id,
            };

            final colors = [
              const Color(0xFF16A34A),
              const Color(0xFF3B82F6),
              const Color(0xFFF59E0B),
              const Color(0xFF8B5CF6),
              const Color(0xFF14B8A6),
              const Color(0xFFEF4444),
            ];

            final sections = porTurma.entries.map((entry) {
              final index = porTurma.keys.toList().indexOf(entry.key);
              final nome = entry.key == "Sem turma"
                  ? "Sem turma"
                  : turmaNomes[entry.key] ?? entry.key;

              return PieChartSectionData(
                value: entry.value.toDouble(),
                title: "$nome\n(${entry.value})",
                color: colors[index % colors.length],
                radius: 55,
                titleStyle: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              );
            }).toList();

            return Container(
              height: 240,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: PieChart(
                PieChartData(sections: sections, centerSpaceRadius: 35),
              ),
            );
          },
        );
      },
    );
  }

  // Bar Chart: Avisos por mês em tempo real
  Widget _buildRealtimeAvisosPorMes() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("avisos")
          .where("escolaId", isEqualTo: escolaId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyChartPlaceholder("Nenhum aviso publicado");
        }

        final avisos = snapshot.data!.docs;
        final Map<String, int> porMes = {};
        for (var doc in avisos) {
          final data = doc.data() as Map<String, dynamic>;
          final ts = data["data"] as Timestamp?;
          if (ts != null) {
            final date = ts.toDate();
            final mes = DateFormat("MM/yyyy").format(date);
            porMes[mes] = (porMes[mes] ?? 0) + 1;
          }
        }

        final barGroups = porMes.entries.map((entry) {
          final index = porMes.keys.toList().indexOf(entry.key);
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: entry.value.toDouble(),
                color: Theme.of(context).colorScheme.primary,
                width: 20,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList();

        return Container(
          height: 240,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: BarChart(
            BarChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: Colors.grey.withValues(alpha: 0.1), strokeWidth: 1),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      if (value % 1 == 0) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10, color: Color(0xFF718096)),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < porMes.keys.length) {
                        final mes = porMes.keys.elementAt(index);
                        final formatado = DateFormat("MMM/yy").format(DateFormat("MM/yyyy").parse(mes));
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            formatado,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              barGroups: barGroups,
              barTouchData: BarTouchData(enabled: true),
            ),
          ),
        );
      },
    );
  }

  // Line Chart: Atividade no fórum em tempo real
  Widget _buildRealtimeForumAtividade() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("escolas")
          .doc(escolaId)
          .collection("forum")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyChartPlaceholder("Nenhuma atividade no fórum");
        }

        final topicos = snapshot.data!.docs;
        final Map<String, int> porDia = {};
        for (var doc in topicos) {
          final data = doc.data() as Map<String, dynamic>;
          final ts = data["criadoEm"] as Timestamp?;
          if (ts != null) {
            final date = ts.toDate();
            final dia = DateFormat("dd/MM").format(date);
            porDia[dia] = (porDia[dia] ?? 0) + 1;
          }
        }

        final spots = porDia.entries.map((entry) {
          final index = porDia.keys.toList().indexOf(entry.key);
          return FlSpot(index.toDouble(), entry.value.toDouble());
        }).toList();

        return Container(
          height: 240,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      if (value % 1 == 0) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10, color: Color(0xFF718096)),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < porDia.keys.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            porDia.keys.elementAt(index),
                            style: const TextStyle(fontSize: 10, color: Color(0xFF718096)),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  barWidth: 3,
                  color: Theme.of(context).colorScheme.primary,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyChartPlaceholder(String message) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bar_chart_outlined, size: 48, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            Text(
              message,
              style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
