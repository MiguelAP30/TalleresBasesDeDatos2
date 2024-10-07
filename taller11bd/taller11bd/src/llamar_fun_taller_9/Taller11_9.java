/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Main.java to edit this template
 */
package llamar_fun_taller_9;

import java.math.BigDecimal;
import java.sql.*;

/**
 *
 * @author migue
 */
public class Taller11_9 {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        try {
            Class.forName("org.postgresql.Driver");
            Connection conexion = DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres", "postgres", "mitologia2003");

            PreparedStatement setSchema = conexion.prepareStatement("SET search_path TO taller9");
            setSchema.execute();
            // TALLER 9
            // Llamada a la funcion obtener_nomina_empleado(p_empleado_id INTEGER, p_mes INTEGER, p_anio INTEGER)
            PreparedStatement taller9obtenernomina = conexion.prepareStatement("SELECT * FROM taller9.obtener_nomina_empleado(?, ?, ?)");
            taller9obtenernomina.setInt(1, 32);
            taller9obtenernomina.setInt(2, 1);
            taller9obtenernomina.setInt(3, 2021);
            ResultSet resultado = taller9obtenernomina.executeQuery();
            while (resultado.next()) {
                String nombre = resultado.getString("nombre");
                BigDecimal totalDevengado = resultado.getBigDecimal("total_devengado");
                BigDecimal totalDeducciones = resultado.getBigDecimal("total_deducciones");
                BigDecimal total = resultado.getBigDecimal("total");
                System.out.println("Nombre: " + nombre + ", Total Devengado: " + totalDevengado + ", Total Deducciones: " + totalDeducciones + ", Total: " + total);
            }

            resultado.close();
            taller9obtenernomina.close();
            
            conexion.close();
        } catch (Exception e) {
            System.out.println("Error " + e.getMessage());
        }
    }
    
}
