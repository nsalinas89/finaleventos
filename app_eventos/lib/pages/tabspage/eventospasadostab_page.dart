import 'package:app_eventos/providers/autenticacion_provider.dart';
import 'package:app_eventos/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';



class EventosPasadosTabPage extends StatelessWidget {
  const EventosPasadosTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        title: Text("Eventos Pasados", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Expanded(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: StreamBuilder(
            stream: FirestoreService().obtenerEventos(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else {
                //return FutureBuilder<int>(
                //  future: FirestoreService().cantidadPasado(), // Llamada al método futuro
                //  builder: (context, AsyncSnapshot<int> itemCountSnapshot) {
                //    if (itemCountSnapshot.connectionState == ConnectionState.waiting) {
                //      return Center(child: CircularProgressIndicator());
                //    } else if (itemCountSnapshot.hasError) {
                //      return Center(child: Text('Error: ${itemCountSnapshot.error}'));
                //    } else {
                //      print('-----------------Flag 1------------');
                //      print(itemCountSnapshot.data);
                      return ListView.separated(
                        separatorBuilder: (context, index) => Divider(),
                        //itemCount: itemCountSnapshot.data ?? 0,
                        itemCount: snapshot.data!.docs.length,
                        //itemCount: 3,
                        itemBuilder: (context, index) {
                          var evento = snapshot.data!.docs[index];
                          //print('-----------------Flag a------------');
                          //print('-----------------${evento['nombre']}------------');
                          //print('-----------------${evento['proyeccion']}------------');
                          if (evento['proyeccion']==false){
                            print('-----------------Flag 2------------');
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
                                  //Accion 1 Edit
                                  SlidableAction(
                                    icon: MdiIcons.sunCompass,
                                    label: 'Toggle',
                                    backgroundColor: Colors.yellow,
                                    onPressed: (context) {
                                      if(!context.read<Autenticacion>().isGuest){
                                        FirestoreService().modificarActivo(evento.id, false);
                                      };
                                    },
                                  ),
                                  //Accion 2 Eliminar
                                  SlidableAction(
                                    icon: MdiIcons.graveStone,
                                    label: 'Eliminar',
                                    backgroundColor: Colors.red,
                                    onPressed: (context) {
                                       if(!context.read<Autenticacion>().isGuest){
                                        print(context.read<Autenticacion>().isGuest);
                                        FirestoreService().eventoBorrar(evento.id);
                                      };
                                    },
                                  ),
                                ],
                              ),
                              child: ListTile(
                                //leading: Image.network(evento['fotografia'], width: 50, height: 50), // Imagen del evento
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
                          } else{
                            print('-----------------Flag 3------------');
                            return Container();
                          }
                        },
                      );
                    }
            
        
                    //print('-----------------Flag 1------------'),
        
                  //}, //--Com
        
                  
        
                //); //--Com
        
                //print('-----------------Flag 3------------'),
        
              }
            //}, //--Com
          ),
        ),
      ),
    );
  }
}