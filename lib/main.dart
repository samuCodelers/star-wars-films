import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:star_wars_app/personajes.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Star Wars App',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      home: const MyHomePage(title: 'STAR WARS'),
    );
  }
}


//Página principal - Muestra la lista de películas de STAR WARS
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final Future<Peliculas> peliculas;

  //Obtine mediante un solicitud POST la lista de películas
  //Devuelve un objeto futuro Peliculas que sericializa el JSON de respuesta
  //Devuelve una excepción en caso de error
  Future<Peliculas> getPeliculas() async {
    final respuesta = await http
        .get(Uri.parse('https://swapi.dev/api/films/'));
    if (respuesta.statusCode == 200) {
      return Peliculas.fromJson(json.decode(respuesta.body));
    } else {
      throw Exception('Error al cargar las películas');
    }
  }

  //Se llama al método para la obtención de películas en la inicialización
  //del build
  @override
  void initState() {
    super.initState();
    peliculas = getPeliculas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height*.06),
            Padding(
              padding: EdgeInsets.all(
                MediaQuery.of(context).size.height*.02
              ),
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Color.fromRGBO(168,233,216,1),
                  BlendMode.modulate
                ),
                //Logo de star wars
                child: Image.asset(
                  "images/sw-logo.png",
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
              ),
            ),
            //Container con el título de la lista
            Container(
              height: MediaQuery.of(context).size.height*.08,
              padding: const EdgeInsets.all(20),
              child: const Text(
                  "- LISTA DE PELÍCULAS -",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18
                ),
              ),
            ),
            //Línea divisora
            Container(
              height: MediaQuery.of(context).size.height*.02,
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: const Divider(height: 1, color: Colors.white),
            ),
            //Espacio para la lista de películas
            SizedBox(
              height: MediaQuery.of(context).size.height*.7,
              child: FutureBuilder<Peliculas>(
                future: peliculas,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return ListView(
                      //Container de películas almacenadas en la lista "results"
                      //Cada container puede ser pulsado y lleva a la página
                      //de personajes de cada película
                      children: snapshot.data!.results.map((pelicula) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                  PersonajesPage(
                                    tituloPelicula: pelicula["title"],
                                    personajesLinks: pelicula["characters"]
                                  ),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.only(
                              top: 10, bottom: 5, left: 20, right: 20
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color.fromRGBO(168,233,216,1),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              pelicula["title"],
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        );
                      }).toList()
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                      "${snapshot.error}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }
                  //Mientras se carga se muestra un loader
                  return Center(
                    child: Container(
                      height: MediaQuery.of(context).size.height*.15,
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
                          Text("Cargando películas"),
                        ]
                      )
                    )
                  );
                },
              ),
            ),
          ],
        )
      ),
    );
  }
}

//Clase peliculas para serializar el JSON de la respuesta
class Peliculas {
  final int count;
  final dynamic next;
  final dynamic previous;
  final List<dynamic> results;

  Peliculas({
    required this.count,
    required this.next,
    required this.previous,
    required this.results
  });

  factory Peliculas.fromJson(Map<String, dynamic> json) {
    return Peliculas(
      count: json['count'],
      next: json['next'],
      previous: json['previous'],
      results: json['results'],
    );
  }
}
