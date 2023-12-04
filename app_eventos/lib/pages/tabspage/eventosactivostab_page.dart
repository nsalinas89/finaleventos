import 'package:app_eventos/providers/autenticacion_provider.dart';
import 'package:app_eventos/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';

class EventosActivosTabPage extends StatelessWidget {
  const EventosActivosTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        title: Text("Eventos Activos", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: StreamBuilder(
          stream: FirestoreService().obtenerEventos(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              // Obtener la fecha actual
              DateTime ahora = DateTime.now();

              // Mostrar eventos próximos a realizarse (en 3 días o menos) 
              List<QueryDocumentSnapshot> eventosProximos = snapshot.data!.docs.where((evento) {
                DateTime fechaEvento = DateTime.parse(evento['fechayhora']);
                return fechaEvento.isAfter(ahora) && fechaEvento.difference(ahora).inDays <= 3;
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (eventosProximos.isNotEmpty)
                    Container(
                      padding: EdgeInsets.all(8),
                      color: Colors.blue,
                      child: Text(
                        'Eventos a Realizarse en los Próximos 3 Días:',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  if (eventosProximos.isNotEmpty)
                    Container(
                      height: 200,
                      child: ListView.builder(
                        itemCount: eventosProximos.length,
                        itemBuilder: (context, index) {
                          var evento = eventosProximos[index];
                          // Interfaz de usuario para eventos próximos
                          return ListTile(
                            title: Text('${evento['nombre']}'),
                            subtitle: Text('Fecha: ${evento['fechayhora']}'),
                          );
                        },
                      ),
                    ),
                  Expanded(
                    child: ListView.separated(
                      separatorBuilder: (context, index) => Divider(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        var evento = snapshot.data!.docs[index];
                        if (evento['proyeccion'] == true) {
                          return Slidable(
                            startActionPane: ActionPane(
                              motion: ScrollMotion(),
                              children: [
                                SlidableAction(
                                  icon: MdiIcons.sunCompass,
                                  label: 'Me gusta',
                                  backgroundColor: Colors.green,
                                  onPressed: (context) {
                                    FirestoreService().incrementarCantidadMG(evento.id);
                                  },
                                ),
                              ],
                            ),
                            endActionPane: ActionPane(
                              motion: ScrollMotion(),
                              children: [
                                //Accion 1 Editar
                                SlidableAction(
                                  icon: MdiIcons.sunCompass,
                                  label: 'Toggle',
                                  backgroundColor: Colors.yellow,
                                  onPressed: (context) {
                                    if (!context.read<Autenticacion>().isGuest) {
                                      FirestoreService().modificarActivo(evento.id, false);
                                    }
                                  },
                                ),
                                //Accion 2 Eliminar
                                SlidableAction(
                                  icon: MdiIcons.graveStone,
                                  label: 'Eliminar',
                                  backgroundColor: Colors.red,
                                  onPressed: (context) {
                                    if (!context.read<Autenticacion>().isGuest) {
                                      print(context.read<Autenticacion>().isGuest);
                                      FirestoreService().eventoBorrar(evento.id);
                                    }
                                  },
                                ),
                              ],
                            ),
                            child: ListTile(
                              title: Text('${evento['nombre']}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Descripción: ${evento['descripcion']}'),
                                  Text('Dirección: ${evento['lugar']}'),
                                  Text('Fecha: ${evento['fechayhora']}'),
                                  Text('Tipo: ${evento['tipo']}'),
                                  Text('Me gusta: ${evento['cantidadmg']}'),
                                  Text('Flag: ${evento['fotografia']}'),
                                ],
                              ),
                            ),
                          );
                        } else {
                          print('-----------------Flag 3------------');
                          return Container();
                        }
                      },
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
