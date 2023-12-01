import 'package:flutter/material.dart';

class Autenticacion extends ChangeNotifier {
  // Estado de autenticación
  bool _isAuthenticated = false;
  // Estado si se entra como invitado
  bool _isGuest = false;

  // Se obtiene el estado de autenticación
  bool get isAuthenticated => _isAuthenticated;
  // Se obtener el estado si es invitado
  bool get isGuest => _isGuest;

  // Método para establecer el estado de autenticación
  void setAuthenticated(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  // Método para establecer el estado del invitado
  void setGuest(bool value) {
    _isGuest = value;
    notifyListeners();
  }

  // Método para comprobar el estado de autenticación
  bool checkAuthentication() {
    return _isAuthenticated;
  }

  // Método para comprobar el estado de si es invitado
  bool checkGuest() {
    return _isGuest;
  }

  void signInAsGuest() {
    setGuest(true);
  }
}