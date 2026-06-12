import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'shared/providers/user_provider.dart';
import 'pages/login_page.dart';
import 'shared/widgets/main_navigation.dart';
import 'pages/add_school_page.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userModelAsync = ref.watch(userModelProvider);

    return userModelAsync.when(
      data: (user) {
        if (user == null) {
          // Se não há usuário autenticado ou o documento no Firestore não existe
          final firebaseUser = FirebaseAuth.instance.currentUser;
          if (firebaseUser != null) {
            FirebaseAuth.instance.signOut();
          }
          return const LoginPage();
        }

        final isGestor = user.isGestor;
        final escolaId = user.escolaId;

        if (isGestor && (escolaId == null || escolaId.isEmpty)) {
          return const AddSchoolPage();
        }

        if (escolaId != null && escolaId.isNotEmpty) {
          return const MainNavigation();
        }

        // Caso de um responsável que, por algum erro, não foi vinculado.
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Você ainda não está vinculado a nenhuma escola. Contate a administração.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => FirebaseAuth.instance.signOut(),
                    child: const Text("Voltar para o Login"),
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
      error: (error, stackTrace) {
        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Erro de autenticação: $error", textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => FirebaseAuth.instance.signOut(),
                    child: const Text("Tentar Novamente"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}