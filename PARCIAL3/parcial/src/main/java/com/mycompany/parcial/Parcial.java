package com.mycompany.parcial;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import static com.mongodb.client.model.Filters.eq;
import static com.mongodb.client.model.Filters.and;
import static com.mongodb.client.model.Filters.gt;
import static com.mongodb.client.model.Updates.set;
import org.bson.Document;
import java.util.Arrays;



public class Parcial {

    public static void main(String[] args) {
        String uri = "mongodb://localhost:27017";
        MongoClient mongoClient = MongoClients.create(uri);
        MongoDatabase database = mongoClient.getDatabase("parcial");
       
        MongoCollection<Document> productos = database.getCollection("Productos");
        MongoCollection<Document> pedidos = database.getCollection("Pedidos");
        MongoCollection<Document> detallePedidos = database.getCollection("Detalle_Pedidos");
        
        MongoCollection<Document> reservas = database.getCollection("Reservas");
        
        System.out.println("Conexión exitosa");
        
        //PRIMERA PREGUNTA
        //Insertar registros
        insertarDatos(productos, pedidos, detallePedidos);
        //Mostrar datos
        leerDatos(productos, pedidos, detallePedidos);
        //Modificar registros
        actualizarDatos(productos);
        //Borrar registros
        eliminarDatos(productos, pedidos, detallePedidos);
        
        //SEGUNDA PREGUNTA
        insertarDatos2(productos, pedidos, detallePedidos);
        realizarConsultas(productos, pedidos, detallePedidos);
        
        //TERCERA PREGUNTA
        realizarCRUDReservas(reservas);
        
        //CUARTA PREGUNTA
        realizarConsultasReservas(reservas);
    }

    //>>>PRIMERA PREGUNTA<<<
    
    private static void insertarDatos(MongoCollection<Document> productos, MongoCollection<Document> pedidos, MongoCollection<Document> detallePedidos) {
        // Insertar un producto
        Document producto = new Document("_id", "producto001")
                .append("nombre", "Camiseta de algodón")
                .append("descripcion", "Camiseta 100% algodón, disponible en varios colores.")
                .append("precio", 15.99)
                .append("stock", 200);
        productos.insertOne(producto);

        // Insertar un pedido
        Document pedido = new Document("_id", "pedido001")
                .append("cliente", "cliente001")
                .append("fecha_pedido", "2024-12-02T14:00:00Z")
                .append("estado", "Enviado")
                .append("total", 31.98);
        pedidos.insertOne(pedido);

        // Insertar detalle de pedido
        Document detallePedido = new Document("_id", "detalle001")
                .append("pedido_id", "pedido001")
                .append("producto_id", "producto001")
                .append("cantidad", 2)
                .append("precio_unitario", 15.99);
        detallePedidos.insertOne(detallePedido);
    }
    
    
    private static void leerDatos(MongoCollection<Document> productos, MongoCollection<Document> pedidos, MongoCollection<Document> detallePedidos) {
        System.out.println("Productos:");
        for (Document doc : productos.find()) {
            System.out.println(doc.toJson());
        }

        System.out.println("Pedidos:");
        for (Document doc : pedidos.find()) {
            System.out.println(doc.toJson());
        }

        System.out.println("Detalle_Pedidos:");
        for (Document doc : detallePedidos.find()) {
            System.out.println(doc.toJson());
        }
    }

    private static void actualizarDatos(MongoCollection<Document> productos) {
        // Actualizar stock del producto
        productos.updateOne(eq("_id", "producto001"), set("stock", 180));
        System.out.println("Stock actualizado");
    }

    private static void eliminarDatos(MongoCollection<Document> productos, MongoCollection<Document> pedidos, MongoCollection<Document> detallePedidos) {
        // Eliminar producto
        productos.deleteOne(eq("_id", "producto001"));

        // Eliminar pedido
        pedidos.deleteOne(eq("_id", "pedido001"));

        // Eliminar detalle de pedido
        detallePedidos.deleteOne(eq("_id", "detalle001"));

        System.out.println("Datos eliminados");
    }
    
    //>>>SEGUNDA PREGUNTA<<<
    private static void insertarDatos2(MongoCollection<Document> productos, MongoCollection<Document> pedidos, MongoCollection<Document> detallePedidos) {
        // Insertar un producto con precio mayor a 20 dólares
        Document producto2 = new Document("_id", "producto002")
                .append("nombre", "a")
                .append("descripcion", "a")
                .append("precio", 35.50)
                .append("stock", 150);
        productos.insertOne(producto2);

        // Insertar producto "producto010"
        Document producto3 = new Document("_id", "producto010")
                .append("nombre", "b")
                .append("descripcion", "b")
                .append("precio", 50.00)
                .append("stock", 100);
        productos.insertOne(producto3);

        // Insertar un pedido con total mayor a 100 dolares
        Document pedido2 = new Document("_id", "pedido002")
                .append("cliente", "cliente003")
                .append("fecha_pedido", "2024-12-02T14:00:00Z")
                .append("estado", "Pendiente")
                .append("total", 150.75);
        pedidos.insertOne(pedido2);

        // Insertar detalle de mayor de 100 dolares
        Document detallePedido2 = new Document("_id", "detalle002")
                .append("pedido_id", "pedido002")
                .append("producto_id", "producto002")
                .append("cantidad", 3)
                .append("precio_unitario", 35.50);
        detallePedidos.insertOne(detallePedido2);

        // Insertar detalle de pedido con producto "producto010"
        Document detallePedido3 = new Document("_id", "detalle003")
                .append("pedido_id", "pedido002")
                .append("producto_id", "producto010")
                .append("cantidad", 1)
                .append("precio_unitario", 50.00);
        detallePedidos.insertOne(detallePedido3);
    }
    private static void realizarConsultas(MongoCollection<Document> productos, MongoCollection<Document> pedidos, MongoCollection<Document> detallePedidos) {
        // Productos con precio mayor a 20 dolares
        System.out.println("Productos con precio mayor a 20 dolares:");
        for (Document doc : productos.find(gt("precio", 20))) {
            System.out.println(doc.toJson());
        }

        // Pedidos con total mayor a 100 dolares
        System.out.println("Pedidos con total mayor a 100 dolares:");
        for (Document doc : pedidos.find(gt("total", 100))) {
            System.out.println(doc.toJson());
        }

        // Pedidos con detalle de pedido que contenga el producto 'producto010'
        System.out.println("Pedidos con detalle que contiene el producto 'producto010':");
        for (Document detalle : detallePedidos.find(eq("producto_id", "producto010"))) {
            String pedidoId = detalle.getString("pedido_id");
            for (Document pedido : pedidos.find(eq("_id", pedidoId))) {
                System.out.println(pedido.toJson());
            }
        }
    }
    
    // >>>TERCERA PREGUNTA <<<
    private static void realizarCRUDReservas(MongoCollection<Document> reservas) {
        // Crear una reserva
        Document reserva = new Document("_id", "reserva001")
                .append("cliente", new Document("nombre", "Ana Gómez")
                        .append("correo", "ana.gomez@example.com")
                        .append("telefono", "+54111223344")
                        .append("direccion", "Calle Ficticia 123, Buenos Aires, Argentina"))
                .append("habitacion", new Document("tipo", "Suite")
                        .append("numero", 101)
                        .append("precio_noche", 200.00)
                        .append("capacidad", 2)
                        .append("descripcion", "Suite con vista al mar, cama king size, baño privado y balcón."))
                .append("fecha_entrada", "2024-12-15T14:00:00Z")
                .append("fecha_salida", "2024-12-18T12:00:00Z")
                .append("total", 740.00)
                .append("estado_pago", "Pagado")
                .append("metodo_pago", "Tarjeta de Crédito")
                .append("fecha_reserva", "2024-11-30T10:00:00Z");
        reservas.insertOne(reserva);
        System.out.println("Reserva creada.");
        
        Document reserva2 = new Document("_id", "reserva002")
                .append("cliente", new Document("nombre", "Ana Gómez")
                        .append("correo", "ana.gomez@example.com")
                        .append("telefono", "+54111223344")
                        .append("direccion", "Calle Ficticia 123, Buenos Aires, Argentina"))
                .append("habitacion", new Document("tipo", "Suite")
                        .append("numero", 101)
                        .append("precio_noche", 200.00)
                        .append("capacidad", 2)
                        .append("descripcion", "Suite con vista al mar, cama king size, baño privado y balcón."))
                .append("fecha_entrada", "2024-12-15T14:00:00Z")
                .append("fecha_salida", "2024-12-18T12:00:00Z")
                .append("total", 740.00)
                .append("estado_pago", "Pagado")
                .append("metodo_pago", "Tarjeta de Crédito")
                .append("fecha_reserva", "2024-11-30T10:00:00Z");
        reservas.insertOne(reserva);
        System.out.println("Reserva 2 creada.");

        // Leer todas las reservas
        System.out.println("Reservas:");
        for (Document doc : reservas.find()) {
            System.out.println(doc.toJson());
        }

        // Actualizar la fecha de salida de la reserva
        reservas.updateOne(eq("_id", "reserva001"), set("fecha_salida", "2024-12-19T12:00:00Z"));
        System.out.println("Reserva actualizada.");

        // Eliminar una reserva
        reservas.deleteOne(eq("_id", "reserva002"));
        System.out.println("Reserva eliminada.");
    }

    // >>>CUARTA PREGUNTA<<<
    private static void realizarConsultasReservas(MongoCollection<Document> reservas) {
        // Consultar habitaciones reservadas de tipo Sencilla
        System.out.println("Habitaciones reservadas de tipo 'Sencilla':");
        for (Document doc : reservas.find(eq("habitacion.tipo", "Sencilla"))) {
            System.out.println(doc.toJson());
        }

        // Sumar el total de las reservas pagadas
        System.out.println("Suma total de reservas pagadas:");
        double sumaTotal = 0;
        for (Document doc : reservas.find(eq("estado_pago", "Pagado"))) {
            sumaTotal += doc.getDouble("total");
        }
        System.out.println("Total: " + sumaTotal);

        // Consultar reservas con precio_noche > 100
        System.out.println("Reservas con precio_noche mayor a 100:");
        for (Document doc : reservas.find(gt("habitacion.precio_noche", 100))) {
            System.out.println(doc.toJson());
        }
    }


}
