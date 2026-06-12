import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';

class AddStudentPage extends StatefulWidget {
  const AddStudentPage({super.key});

  @override
  State<AddStudentPage> createState() => _AddStudentPageState();
}

class _AddStudentPageState extends State<AddStudentPage> {
  final _formKey = GlobalKey<FormState>();
  final _studentNameCtrl = TextEditingController();
  final _studentBirthDateCtrl = TextEditingController();
  final _responsibleNameCtrl = TextEditingController();
  final _responsibleCpfCtrl = TextEditingController();

  DateTime? _birthDate;
  bool _loading = false;

  @override
  void dispose() {
    _studentNameCtrl.dispose();
    _studentBirthDateCtrl.dispose();
    _responsibleNameCtrl.dispose();
    _responsibleCpfCtrl.dispose();
    super.dispose();
  }

  Future<void> _addStudent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_birthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Selecione a data de nascimento"),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("Usuário não autenticado");

      final userDoc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
      final escolaId = userDoc.data()?["escolaId"];
      if (escolaId == null) throw Exception("Gestor não vinculado a nenhuma escola");

      await FirebaseFirestore.instance.collection("students").add({
        "nome": _studentNameCtrl.text.trim(),
        "dataNascimento": Timestamp.fromDate(_birthDate!),
        "responsibleName": _responsibleNameCtrl.text.trim(),
        "responsibleCpf": _responsibleCpfCtrl.text.trim(),
        "escolaId": escolaId,
        "createdAt": FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("Aluno adicionado com sucesso!"),
            backgroundColor: AppColors.primary600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erro ao adicionar aluno: ${e.toString()}"),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2015),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      locale: const Locale("pt", "BR"),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary600,
              onPrimary: Colors.white,
              onSurface: AppColors.neutral900,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      _birthDate = picked;
      _studentBirthDateCtrl.text =
      "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
    }
  }

  String? _validateCpf(String? value) {
    if (value == null || value.isEmpty) return "Informe o CPF do responsável";
    if (value.length != 11) return "CPF deve ter 11 dígitos";
    return null;
  }

  Widget _buildFormSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.neutral200),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary600),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.neutral900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutral50,
      appBar: AppBar(
        title: const Text(
          "Adicionar Aluno",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.neutral800,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Seção Inicial
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary100),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.primary100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1_rounded,
                        size: 26,
                        color: AppColors.primary600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Cadastro de Aluno",
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.neutral900,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Insira as informações do estudante e de seu responsável.",
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Seção 1: Dados do Aluno
              _buildFormSection(
                title: "Dados do Estudante",
                icon: Icons.child_care_rounded,
                children: [
                  TextFormField(
                    controller: _studentNameCtrl,
                    decoration: const InputDecoration(
                      labelText: "Nome do Aluno",
                      hintText: "Nome completo do estudante",
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (v) => v == null || v.isEmpty ? "Informe o nome do aluno" : null,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _studentBirthDateCtrl,
                    readOnly: true,
                    onTap: _pickDate,
                    decoration: const InputDecoration(
                      labelText: "Data de Nascimento",
                      hintText: "Selecione a data de nascimento",
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      suffixIcon: Icon(Icons.arrow_drop_down_rounded),
                    ),
                    validator: (v) => v == null || v.isEmpty ? "Informe a data de nascimento" : null,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Seção 2: Dados do Responsável
              _buildFormSection(
                title: "Responsável Legal",
                icon: Icons.family_restroom_rounded,
                children: [
                  TextFormField(
                    controller: _responsibleNameCtrl,
                    decoration: const InputDecoration(
                      labelText: "Nome do Responsável",
                      hintText: "Nome completo do pai, mãe ou tutor",
                      prefixIcon: Icon(Icons.supervised_user_circle_outlined),
                    ),
                    validator: (v) => v == null || v.isEmpty ? "Informe o nome do responsável" : null,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _responsibleCpfCtrl,
                    decoration: const InputDecoration(
                      labelText: "CPF do Responsável",
                      hintText: "Apenas números (11 dígitos)",
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                    validator: _validateCpf,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Botão Adicionar
              ElevatedButton(
                onPressed: _loading ? null : _addStudent,
                child: _loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Adicionar Aluno",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}