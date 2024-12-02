package com.mycompany.parcialneo;

import org.neo4j.driver.AuthTokens;
import org.neo4j.driver.Driver;
import org.neo4j.driver.Session;
import org.neo4j.driver.Query;

public class Parcialneo {

    public static void main(String[] args) {
        
    //>>>QUINTA PREGUNTA<<<
        String uri = "bolt://localhost:7687";
        String user = "neo4j";
        String password = "hola123";

        try (Driver driver = org.neo4j.driver.GraphDatabase.driver(uri, AuthTokens.basic(user, password))) {
            try (Session session = driver.session()) {
                // Crear personas
                crearPersona(session, "Ana Gómez", "ana.gomez@example.com", 28, "Buenos Aires");
                crearPersona(session, "Juan Pérez", "juan.perez@example.com", 35, "Madrid");

                // Crear relación Comentario entre las personas
                crearComentario(session, "ana.gomez@example.com", "juan.perez@example.com", "Este es un comentario de ejemplo.");

                System.out.println("Operaciones realizadas con éxito.");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // Método para crear un nodo Persona
    private static void crearPersona(Session session, String nombre, String correo, int edad, String ciudad) {
        String query = """
            MERGE (p:Persona {correo: $correo})
            SET p.nombre = $nombre, p.edad = $edad, p.ciudad = $ciudad
        """;
        session.run(new Query(query)
                .addParameter("nombre", nombre)
                .addParameter("correo", correo)
                .addParameter("edad", edad)
                .addParameter("ciudad", ciudad));
        System.out.println("Persona creada: " + nombre);
    }

    // Método para crear una relación Comentario
    private static void crearComentario(Session session, String correoOrigen, String correoDestino, String descripcion) {
        String query = """
            MATCH (p1:Persona {correo: $correoOrigen})
            MATCH (p2:Persona {correo: $correoDestino})
            MERGE (p1)-[r:Comentario {descripcion: $descripcion}]->(p2)
        """;
        session.run(new Query(query)
                .addParameter("correoOrigen", correoOrigen)
                .addParameter("correoDestino", correoDestino)
                .addParameter("descripcion", descripcion));
        System.out.println("Comentario creado entre " + correoOrigen + " y " + correoDestino);
    }
}
