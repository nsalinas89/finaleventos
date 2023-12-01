import 'package:app_eventos/pages/eventosbn_page.dart';
import 'package:app_eventos/pages/usuariologueado_page.dart';
import 'package:app_eventos/services/google_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/autenticacion_provider.dart';

class BienvenidoPage extends StatefulWidget {
  @override
  State<BienvenidoPage> createState() => _BienvenidoPageState();
}

class _BienvenidoPageState extends State<BienvenidoPage> {
  final GoogleAuthService googleAuthService = GoogleAuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Bienvenido',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFF831B05),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                User? authenticatedUser =
                    await googleAuthService.iniciarSesionGoogle(context);
                if (authenticatedUser != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UsuarioLogueadoPage(
                        user: authenticatedUser,
                        googleAuthService: googleAuthService,
                      ),
                    ),
                  );
                } else {
                  print('Ha fallado en el inicio de sesión');
                }
              },
              child: Text('Iniciar Sesión con Google'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.read<Autenticacion>().signInAsGuest();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventosBNPage(),
                  ),
                );
              },
              child: Text('Entrar como Invitado'),
            ),
          ],
        ),
      ),
    );
  }
}

