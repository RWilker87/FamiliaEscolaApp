import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_model.dart';

/// StreamProvider que escuta as mudanças de autenticação do Firebase.
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// StreamProvider que escuta em tempo real o documento do usuário no Firestore.
final userModelProvider = StreamProvider<UserModel?>((ref) {
  final authStateAsync = ref.watch(authStateProvider);
  
  return authStateAsync.when(
    data: (user) {
      if (user == null) {
        return Stream.value(null);
      }
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
    },
    error: (err, stack) => Stream.error(err, stack),
    loading: () => const Stream.empty(),
  );
});

/// StreamProvider que escuta e soma as mensagens não lidas em tempo real do usuário.
final unreadCountProvider = StreamProvider<int>((ref) {
  final userModelAsync = ref.watch(userModelProvider);

  return userModelAsync.when(
    data: (user) {
      if (user == null || user.escolaId == null || user.escolaId!.isEmpty) {
        return Stream.value(0);
      }
      return FirebaseFirestore.instance
          .collection("escolas")
          .doc(user.escolaId)
          .collection("conversas")
          .where("participantes", arrayContains: user.uid)
          .snapshots()
          .map((snapshot) {
            int count = 0;
            for (var doc in snapshot.docs) {
              final data = doc.data();
              final unreadMap = Map<String, dynamic>.from(data["unread"] ?? {});
              count += (unreadMap[user.uid] is int)
                  ? unreadMap[user.uid] as int
                  : 0;
            }
            return count;
          });
    },
    error: (err, stack) => Stream.value(0),
    loading: () => Stream.value(0),
  );
});
