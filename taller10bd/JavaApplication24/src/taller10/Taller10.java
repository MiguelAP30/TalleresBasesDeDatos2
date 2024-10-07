/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Main.java to edit this template
 */
package taller10;

import java.math.BigDecimal;
import java.sql.*;

/**
 *
 * @author migue
 */
public class Taller10 {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        try {
            Class.forName("org.postgresql.Driver");
            Connection conexion = DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres?currentSchema=taller6", "postgres", "mitologia2003");
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

            // TALLER 6
            // Llamada a la funcion transacciones_total_mes(date,int)
            PreparedStatement taller6transaccionesmes = conexion.prepareStatement("SELECT taller6.transacciones_total_mes(?, ?)");
            taller6transaccionesmes.setDate(1, java.sql.Date.valueOf("2024-09-01"));
            taller6transaccionesmes.setInt(2, 11);
            ResultSet resultado = taller6transaccionesmes.executeQuery();
            BigDecimal valor = new BigDecimal(0);
            while (resultado.next()) {
                valor = resultado.getBigDecimal(1);
            }
            System.out.println("El valor total de las transacciones del mes es: " + valor);
            resultado.close();
            taller6transaccionesmes.close();
            
            conexion.close();
        } catch (Exception e) {
            System.out.println("Error " + e.getMessage());
        }
    }
}