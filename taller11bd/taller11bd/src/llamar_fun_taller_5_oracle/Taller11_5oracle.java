/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package llamar_fun_taller_5_oracle;

import java.sql.*;

/**
 *
 * @author migue
 */
public class Taller11_5oracle {
    public static void main(String[] args) {
        try {
            Class.forName("org.postgresql.Driver");
            Connection conexion = DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres", "postgres", "mitologia2003");
            // TALLER 5
            // Llamada al procedimiento generar_auditoria
            CallableStatement taller5 = conexion.prepareCall("call taller5.generar_auditoria(?, ?)");
            taller5.setDate(1, java.sql.Date.valueOf("2000-11-12"));
            taller5.setDate(2, java.sql.Date.valueOf("2004-11-12"));
            taller5.execute();
            taller5.close();
            // Llamada al procedimiento simular_ventas_mes
            CallableStatement taller5ventas = conexion.prepareCall("call taller5.simular_ventas_mes()");
            taller5ventas.execute();
            taller5ventas.close();
            
            conexion.close();
        } catch (Exception e) {
            System.out.println("Error " + e.getMessage());
        }
    }
}
