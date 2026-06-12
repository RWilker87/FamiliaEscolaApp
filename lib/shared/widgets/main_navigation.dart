import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../pages/home_page.dart';
import '../../pages/avisos_page.dart';
import '../../pages/mensagens_page.dart';
import '../../pages/forumPage.dart';
import '../../pages/profile_page.dart';
import '../providers/user_provider.dart';

class MainNavigation extends ConsumerStatefulWidget {
  final int initialTab;
  const MainNavigation({super.key, this.initialTab = 0});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final userModelAsync = ref.watch(userModelProvider);
    final unreadCount = ref.watch(unreadCountProvider).value ?? 0;

    return userModelAsync.when(
      data: (user) {
        if (user == null) {
          return const Scaffold(
            body: Center(child: Text("Usuário não encontrado")),
          );
        }

        final pages = [
          const HomePage(),
          const AvisosPage(),
          const MensagensPage(),
          ForumPage(escolaId: user.escolaId ?? ''),
          const ProfilePage(),
        ];

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Color(0x0F0F172A),
                  blurRadius: 10,
                  offset: Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              type: BottomNavigationBarType.fixed,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor: Colors.white,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: const Color(0xFF64748B),
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontSize: 12),
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: "Início",
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.notifications_none),
                  activeIcon: Icon(Icons.notifications),
                  label: "Avisos",
                ),
                BottomNavigationBarItem(
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.chat_bubble_outline),
                      if (unreadCount > 0)
                        Positioned(
                          right: -6,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              unreadCount > 9 ? "9+" : "$unreadCount",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  activeIcon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(Icons.chat_bubble),
                      if (unreadCount > 0)
                        Positioned(
                          right: -6,
                          top: -2,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.error,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              unreadCount > 9 ? "9+" : "$unreadCount",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: "Chat",
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.forum_outlined),
                  activeIcon: Icon(Icons.forum),
                  label: "Fórum",
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.person_outline),
                  activeIcon: Icon(Icons.person),
                  label: "Perfil",
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) => Scaffold(
        body: Center(child: Text("Erro ao carregar navegação: $err")),
      ),
    );
  }
}
