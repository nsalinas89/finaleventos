import 'package:app_eventos/providers/autenticacion_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class GoogleAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<User?> iniciarSesionGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      // Verificar si el usuario es un administrador
      bool isAdmin = _esAdministrador(userCredential.user?.email);

      // Configurar el estado de autenticación
      context.read<Autenticacion>().setAuthenticated(isAdmin);
      // Configurar el estado de invitado
      context.read<Autenticacion>().setGuest(!isAdmin);

      print('Es Administrador: $isAdmin');
      print('IsAuthenticated: ${context.read<Autenticacion>().isAuthenticated}');
      print('IsGuest: ${context.read<Autenticacion>().isGuest}');

      return userCredential.user;
    } catch (e) {
      print("Ha ocurrido un error en el proceso: $e");
      throw Exception("Ha fallado el inicio de sesión");
    }
  }

  bool _esAdministrador(String? email) {
    // Lista de correos electrónicos de administradores
    const List<String> correosAdministradores = [
      'sludgehammerofdoom@gmail.com',
      'low.signal1989@gmail.com', 
    ];

    // Verificar si el correo electrónico pertenece a la lista de administradores
    return correosAdministradores.contains(email);
  }

  Future<void> cerrarSesion() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
