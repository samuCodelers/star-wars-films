import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PersonajesPage extends StatefulWidget {
  const PersonajesPage({
    super.key,
    required this.personajesLinks,
    required this.tituloPelicula
  });

  final List<dynamic> personajesLinks;
  final String tituloPelicula;

  @override
  State<PersonajesPage> createState() => _PersonajesPageState();
}

class _PersonajesPageState extends State<PersonajesPage> {
  late final Future<List<Personaje>> personajes;
  late final Future<List<Origen>> origen;

  //Recorre la lista con los links de los personajes y se almacena su
  //información mediante la clase Personaje
  Future<List<Personaje>> getPersonajes() async {
    List<Personaje> personajes = [];
    //Se recorren los links con la información de cada personaje
    for (var personajeLink in widget.personajesLinks) {
      //Se obtine su JSON y se añade a la lista
      final respuesta = await http.get(Uri.parse(personajeLink));
      if (respuesta.statusCode == 200) {
        personajes.add(Personaje.fromJson(json.decode(respuesta.body)));
      } else {
        throw Exception('Error al cargar los personajes');
      }
    }
    return personajes;
  }

  //Recorre la lista con los links de las especies de cada personaje y se
  //almacena su infromación mediante la clase Especie
  Future<List<Especie>> getEspecies(especiesLinks) async {
    List<Especie> especies = [];
    //Se recorren los links con las especies de cada personaje
    for (var especieLink in especiesLinks) {
      //Se obtine su JSON y se añade a la lista
      final respuesta = await http.get(Uri.parse(especieLink));
      if (respuesta.statusCode == 200) {
        especies.add(Especie.fromJson(json.decode(respuesta.body)));
      } else {
        throw Exception('Error al cargar los personajes');
      }
    }
    return especies;
  }

  //Obtiene el origen del personaje mediante una petición al link
  //que contiene el origen de cada personaje
  Future<Origen> getOrigen(origenLink) async {
    final respuesta = await http.get(Uri.parse(origenLink));
    if (respuesta.statusCode == 200) {
      return Origen.fromJson(json.decode(respuesta.body));
    } else {
      throw Exception('Error al cargar los personajes');
    }
  }

  //Se obtienen los personajes en la inicialización del estado
  @override
  void initState() {
    super.initState();
    personajes = getPersonajes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.tituloPelicula.toUpperCase()),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(168,233,216,1),
      ),
      body: Column (
        children: [
          //Espacio con la lista de contenedores de información de cada
          //personaje
          SizedBox(
            height: MediaQuery.of(context).size.height
              - AppBar().preferredSize.height
              - MediaQuery.of(context).padding.top,
            child: FutureBuilder<List<Personaje>>(
              future: personajes,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView(
                    //Lista de películas almacenadas en la lista "results"
                    children: snapshot.data!.map((personaje) {
                      return Container(
                        padding: const EdgeInsets.all(20),
                        margin: const EdgeInsets.only(
                          top: 10, bottom: 5, left: 20, right: 20
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: const Color.fromRGBO(168,233,216,1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Nombre personaje
                            SizedBox(
                              height: 30,
                              child: Text(personaje.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18
                                ),
                              ),
                            ),
                            //Origen del personaje
                            FutureBuilder<Origen>(
                              //Para cada personaje obtendrá su origen
                              future: getOrigen(personaje.homeworld),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return SizedBox(
                                    height: 30,
                                    child: Text(
                                      "Origen: ${snapshot.data!.name}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.grey[700]
                                      ),
                                    ),
                                  );
                                } else {
                                  //Mientras se carga el origen se muestra
                                  //un loader
                                  return Container(
                                    height: 30,
                                    padding: const EdgeInsets.all(12),
                                    child: const LinearProgressIndicator(),
                                  );
                                }
                              }
                            ),
                            //Título lista de especies
                            SizedBox(
                              height: 25,
                              child: Text(
                                "Lista de especies:",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.grey[700]
                                ),
                              ),
                            ),
                            //Lista de especies del personaje
                            FutureBuilder<List<Especie>>(
                              future: getEspecies(personaje.species),
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  //Si está vacía no se muestra nada
                                  if(snapshot.data!.isEmpty) {
                                    return const Text("-");
                                  }
                                  else {
                                    return Container(
                                      color: Colors.white,
                                      height: 50,
                                      padding: const EdgeInsets.all(5),
                                      child: ListView(
                                        children: snapshot.data!.map((especie) {
                                          return Text(
                                            especie.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: Colors.grey[700]
                                            ),
                                          );
                                        }
                                      ).toList()),
                                    );
                                  }
                                } else {
                                  return Container();
                                }
                              }
                            )
                          ],
                        )
                      );
                    }).toList()
                  );
                } else if (snapshot.hasError) {
                  return Text("${snapshot.error}");
                }
                return Center(
                  child: Container(
                    height: 120,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(
                      top: 10, bottom: 5, left: 20, right: 20
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromRGBO(168,233,216,1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text("Cargando personajes"),
                      ]
                    )
                  )
                );
              },
            ),
          ),
        ]
      )
    );
  }
}

//Clase Personaje para serializar el JSON de la respuesta
class Personaje {
  final String name;
  final List<dynamic> species;
  final String homeworld;

  Personaje({
    required this.name,
    required this.species,
    required this.homeworld,
  });

  factory Personaje.fromJson(Map<String, dynamic> json) {
    return Personaje(
      name: json['name'],
      species: json['species'],
      homeworld: json['homeworld'],
    );
  }
}

//Clase Origen para serializar el JSON de la respuesta de petición del origen
class Origen {
  final String name;

  Origen({
    required this.name,
  });

  factory Origen.fromJson(Map<String, dynamic> json) {
    return Origen(
      name: json['name'],
    );
  }
}

//Clase Especie para serializar el JSON de la respuesta de petición de especies
class Especie {
  final String name;

  Especie({
    required this.name,
  });

  factory Especie.fromJson(Map<String, dynamic> json) {
    return Especie(
      name: json['name'],
    );
  }
}