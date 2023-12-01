import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference _eventosCollection = FirebaseFirestore.instance.collection('eventos');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Agregar un registro
  Future<void> agregarEvento(String nombre, String fechayhora, String descripcion, String lugar, String tipo, int cantidadmg, bool proyeccion, bool activo, String fotografia) {
    return _eventosCollection.add({
      'nombre': nombre,
      'fechayhora': fechayhora,
      'descripcion': descripcion,
      'lugar': lugar,
      'tipo': tipo,
      'cantidadmg': cantidadmg,
      'proyeccion': proyeccion,
      'activo': activo,
      'fotografia': fotografia,
    });
  }

  // Aumentar "CantidadMG" en 1
  Future<void> incrementarCantidadMG(String documentoId) {
    return _eventosCollection.doc(documentoId).update({
      'cantidadmg': FieldValue.increment(1)
    });
  }

  //Eliminar Evento
  Future<void> eventoBorrar(String documentoId) async {
    return _eventosCollection.doc(documentoId).delete();
  }

  // Modificar "Proyección"
  Future<void> modificarProyeccion(String documentoId, bool nuevaProyeccion) {
    return _eventosCollection.doc(documentoId).update({
      'proyeccion': nuevaProyeccion
    });
  }

  // Modificar "Activo"
  Future<void> modificarActivo(String documentoId, bool nuevoActivo) {
    return _eventosCollection.doc(documentoId).update({
      'activo': nuevoActivo
    });
  }

  // Mostrar todos los registros
  Stream<QuerySnapshot> obtenerEventos() {
    return _eventosCollection.snapshots();
  }

  Future<int> cantidadFuturo() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('eventos')
          .where('proyeccion', isEqualTo: true)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print("FLAG ERROR $e");
      return 0;
    }
  }

  Future<int> cantidadPasado() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('eventos')
          .where('proyeccion', isEqualTo: false)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print("FLAG ERROR $e");
      return 0;
    }
  }
}