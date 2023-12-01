import 'dart:io';
import 'package:app_eventos/providers/autenticacion_provider.dart';
import 'package:app_eventos/services/firestore_service.dart';
import 'package:app_eventos/services/select_image_service.dart';
import 'package:app_eventos/services/upload_image_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EventosAgregarTabPage extends StatefulWidget {
  @override
  _EventosAgregarTabPageState createState() => _EventosAgregarTabPageState();
}

class _EventosAgregarTabPageState extends State<EventosAgregarTabPage> {
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _fechaController = TextEditingController();
  final TextEditingController _ubicacionController = TextEditingController();
  //final DateTime _selectedDate = DateTime.now();

  bool _esFuturo = true;

  List<String> _tiposEventos = [
    'Concierto',
    'Fiesta',
    'Evento Deportivo',
    'Seminario',
    'Charla',
    'Comunitario',
  ];

  String _tipoEventoSeleccionado = 'Concierto';
  File? _imagenSeleccionada;

  @override
  Widget build(BuildContext context) {
    bool esAdministrador = context.read<Autenticacion>().isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        centerTitle: true,
        title: Text("Agregar Nuevo Evento", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: esAdministrador
          ? SingleChildScrollView( // Envuelve tu Column con SingleChildScrollView
              child: _buildFormularioAgregarEvento(),
            )
          : _buildMensajeInvitado(),
    );
  }

  Widget _buildFormularioAgregarEvento() {
  return Padding(
    padding: EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: _tituloController,
          decoration: InputDecoration(labelText: 'Título del Evento'),
        ),
        SizedBox(height: 10),
        TextFormField(
          controller: _descripcionController,
          decoration: InputDecoration(labelText: 'Descripción del Evento'),
        ),
        SizedBox(height: 10),
        //
        TextField(
          controller: _fechaController,
          decoration: const InputDecoration(
            icon: Icon(Icons.calendar_today_rounded),
            labelText: "Fecha evento",
          ),
          onTap: () async {
            DateTime? pickeddate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2030),);

              if (pickeddate != null){
                setState( () {
                  if ( DateTime.now().isBefore(pickeddate) ) {
                    _esFuturo = true;
                  } else {
                    _esFuturo = false;
                  };
                  _fechaController.text = DateFormat('yyyy-MM-dd').format(pickeddate);
                });
              }
          },
        ),
        //
        SizedBox(height: 10),
        TextFormField(
          controller: _ubicacionController,
          decoration: InputDecoration(labelText: 'Ubicación del Evento'),
        ),
        SizedBox(height: 10),
        DropdownButton<String>(
          value: _tipoEventoSeleccionado,
          onChanged: (String? newValue) {
            setState(() {
              _tipoEventoSeleccionado = newValue!;
            });
          },
          items: _tiposEventos.map((String tipoEvento) {
            return DropdownMenuItem<String>(
              value: tipoEvento,
              child: Text(tipoEvento),
            );
          }).toList(),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            final imagen = await getImage();
            setState(() {
              _imagenSeleccionada = File(imagen!.path);
              print(_imagenSeleccionada);
            });
          },
          child: Text('Seleccionar Imagen'),
        ),
        SizedBox(height: 10),
        _imagenSeleccionada != null
            ? Image.file(_imagenSeleccionada!)
            : Container(
                height: 200,
                width: double.maxFinite,
                color: Colors.green.shade700,
              ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () async {
            await _guardarEvento();
          },
          child: Text('Guardar Evento'),
        ),
      ],
    ),
  );
}


  Future<void> _guardarEvento() async {
    bool esAdministrador = context.read<Autenticacion>().isAuthenticated;

    if (esAdministrador) {
      String nombre = _tituloController.text;
      String fechayhora = _fechaController.text;
      String descripcion = _descripcionController.text;
      String lugar = _ubicacionController.text;
      String tipo = _tipoEventoSeleccionado;

      FirestoreService().agregarEvento(
        nombre,
        fechayhora,
        descripcion,
        lugar,
        tipo,
        0,
        _esFuturo,
        true,
        '',
      );

      if (_imagenSeleccionada != null) {
        bool subidaExitosa = await uploadImage(_imagenSeleccionada!);

        if (subidaExitosa) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El evento y la imagen se han guardado con éxito'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al guardar la imagen')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes seleccionar una imagen')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lo siento, como invitado no puedes agregar eventos.',
          ),
        ),
      );
    }
  }

  Widget _buildMensajeInvitado() {
    return Center(
      child: Text(
        'Lo siento,  notienes permisos para agregar eventos.',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
