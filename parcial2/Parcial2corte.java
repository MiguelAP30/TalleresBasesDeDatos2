/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Main.java to edit this template
 */
package parcial2corte;

import java.math.BigDecimal;
import java.sql.*;

public class Parcial2corte {

    public static void main(String[] args) {
        try {
            Class.forName("org.postgresql.Driver");
            Connection conexion = DriverManager.getConnection("jdbc:postgresql://localhost:5432/postgres", "postgres", "mitologia2003");

            // Llamada a la función obtener_pagos_usuario
            PreparedStatement obtenerPagosUsuario = conexion.prepareStatement("SELECT * FROM obtener_pagos_usuario(?, ?)");
            obtenerPagosUsuario.setInt(1, 1); // usuario_id
            obtenerPagosUsuario.setDate(2, java.sql.Date.valueOf("2023-03-01")); // fecha
            ResultSet resultadoPagosUsuario = obtenerPagosUsuario.executeQuery();
            while (resultadoPagosUsuario.next()) {
                String codigoPago = resultadoPagosUsuario.getString("codigo_pago");
                String nombreProducto = resultadoPagosUsuario.getString("nombre_producto");
                BigDecimal monto = resultadoPagosUsuario.getBigDecimal("monto");
                String estado = resultadoPagosUsuario.getString("estado");
                System.out.println("Código Pago: " + codigoPago + ", Nombre Producto: " + nombreProducto + ", Monto: " + monto + ", Estado: " + estado);
            }
            resultadoPagosUsuario.close();
            obtenerPagosUsuario.close();

            // Llamada a la función obtener_tarjetas_usuario
            PreparedStatement obtenerTarjetasUsuario = conexion.prepareStatement("SELECT * FROM obtener_tarjetas_usuario(?)");
            obtenerTarjetasUsuario.setInt(1, 1); // usuario_id
            ResultSet resultadoTarjetasUsuario = obtenerTarjetasUsuario.executeQuery();
            while (resultadoTarjetasUsuario.next()) {
                String nombreUsuario = resultadoTarjetasUsuario.getString("nombre_usuario");
                String email = resultadoTarjetasUsuario.getString("email");
                String numeroTarjeta = resultadoTarjetasUsuario.getString("numero_tarjeta");
                String cvv = resultadoTarjetasUsuario.getString("cvv");
                String tipoTarjeta = resultadoTarjetasUsuario.getString("tipo_tarjeta");
                System.out.println("Nombre Usuario: " + nombreUsuario + ", Email: " + email + ", Número Tarjeta: " + numeroTarjeta + ", CVV: " + cvv + ", Tipo Tarjeta: " + tipoTarjeta);
            }
            resultadoTarjetasUsuario.close();
            obtenerTarjetasUsuario.close();

            // Llamada a la función obtener_tarjeta_detalle_usuario
            CallableStatement obtenerTarjetaDetalleUsuario = conexion.prepareCall("{? = call obtener_tarjeta_detalle_usuario(?)}");
            obtenerTarjetaDetalleUsuario.registerOutParameter(1, Types.REF_CURSOR);
            obtenerTarjetaDetalleUsuario.setInt(2, 1); // usuario_id
            obtenerTarjetaDetalleUsuario.execute();
            ResultSet resultadoTarjetaDetalleUsuario = (ResultSet) obtenerTarjetaDetalleUsuario.getObject(1);
            while (resultadoTarjetaDetalleUsuario.next()) {
                String numeroTarjeta = resultadoTarjetaDetalleUsuario.getString("numero_tarjeta");
                Date fechaExpiracion = resultadoTarjetaDetalleUsuario.getDate("fecha_de_expiracion");
                String nombre = resultadoTarjetaDetalleUsuario.getString("nombre");
                String email = resultadoTarjetaDetalleUsuario.getString("email");
                System.out.println("Número Tarjeta: " + numeroTarjeta + ", Fecha Expiración: " + fechaExpiracion + ", Nombre: " + nombre + ", Email: " + email);
            }
            resultadoTarjetaDetalleUsuario.close();
            obtenerTarjetaDetalleUsuario.close();

            // Llamada a la función obtener_pagos_menores
            CallableStatement obtenerPagosMenores = conexion.prepareCall("{? = call obtener_pagos_menores(?)}");
            obtenerPagosMenores.registerOutParameter(1, Types.REF_CURSOR);
            obtenerPagosMenores.setDate(2, java.sql.Date.valueOf("2023-03-02")); // fecha
            obtenerPagosMenores.execute();
            ResultSet resultadoPagosMenores = (ResultSet) obtenerPagosMenores.getObject(1);
            while (resultadoPagosMenores.next()) {
                BigDecimal monto = resultadoPagosMenores.getBigDecimal("monto");
                String estado = resultadoPagosMenores.getString("estadop");
                String nombreProducto = resultadoPagosMenores.getString("nombre");
                BigDecimal porcentajeImpuesto = resultadoPagosMenores.getBigDecimal("porcentaje_impuesto");
                String direccion = resultadoPagosMenores.getString("direccion");
                String email = resultadoPagosMenores.getString("email");
                System.out.println("Monto: " + monto + ", Estado: " + estado + ", Producto: " + nombreProducto + ", Impuesto: " + porcentajeImpuesto + ", Dirección: " + direccion + ", Email: " + email);
            }
            resultadoPagosMenores.close();
            obtenerPagosMenores.close();

            conexion.close();
        } catch (Exception e) {
            System.out.println("Error " + e.getMessage());
        }
    }
}