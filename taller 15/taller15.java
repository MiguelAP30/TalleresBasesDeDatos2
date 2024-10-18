/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Main.java to edit this template
 */
package taller15;

import java.sql.Connection;
import java.sql.DriverManager;

/**
 *
 * @author miguel
 */
import java.sql.*;
public class Taller15 {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {

        try (Connection conexion = DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres", "postgres", "andres2003");) {
            // Llamada al procedimiento guardar_libro
            CallableStatement csGuardar = conexion.prepareCall("{ call guardar_libro(?, ?) }");
            csGuardar.setString(1, "9781234567890");
            csGuardar.setString(2, "Brave New World");
            csGuardar.execute();

            // Llamada a la función obtener_autor_libro_por_isbn
            CallableStatement csAutorPorIsbn = conexion.prepareCall("{ ? = call obtener_autor_libro_por_isbn(?) }");
            csAutorPorIsbn.registerOutParameter(1, Types.VARCHAR);
            csAutorPorIsbn.setString(2, "9781234567890");
            csAutorPorIsbn.execute();
            String autor = csAutorPorIsbn.getString(1);
            System.out.println("Autor: " + autor);

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}