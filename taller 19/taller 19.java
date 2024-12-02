import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoCursor;
import com.mongodb.client.MongoDatabase;
import static com.mongodb.client.model.Filters.and;
import static com.mongodb.client.model.Filters.eq;
import static com.mongodb.client.model.Filters.gt;
import static com.mongodb.client.model.Updates.set;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import org.bson.Document;

public class Taller19 {

    public static void main(String[] args) {
        String uri= "mongodb://localhost:27017";
        MongoClient mongoClient= MongoClients.create(uri);
        MongoDatabase database = mongoClient.getDatabase("pruebas");
        MongoCollection<Document> collection = database.getCollection("productos");
        System.out.println("Conexion exitosa");
        
        //Insertar 10 registros
        List<Document> productos = new ArrayList<>();

        for (int i = 1; i <= 10; i++) {
            Document producto = new Document("ProductoID", i)
                    .append("Nombre", "Producto" + i)
                    .append("Descripción", "Descripción del producto " + i)
                    .append("Precio", 10 * i)
                    .append("Categoría", new Document("CategoríaID", i)
                            .append("NombreCategoria", "Categoría " + i))
                    .append("Comentarios", Arrays.asList(
                            new Document("ComentarioID", 1)
                                    .append("Texto", "Comentario1  " + i)
                                    .append("Cliente", "Cliente" + i),
                            new Document("ComentarioID", 2)
                                    .append("Texto", "Comentario2  " + i)
                                    .append("Cliente", "Cliente" + (i + 1))
                    ));

            productos.add(producto);
        }

        collection.insertMany(productos);
        
        //Actualizar 5 registros
        for (int i = 1; i <= 5; i++) {
            collection.updateOne(
                    eq("ProductoID", i), 
                    new Document("$set", new Document("Precio", 15 * i)) 
            );
        }   
        
        // Eliminar 2 registros
        collection.deleteOne(eq("ProductoID", 1));
        collection.deleteOne(eq("ProductoID", 2));
        //Productos con precio mayor a 10 dólares
        MongoCursor<Document> cursor = collection.find(gt("Precio", 10)).iterator();
        while (cursor.hasNext()) {
            System.out.println(cursor.next().toJson());
        }
        
        //Productos con precio mayor a 50 dólares y categoría igual a ropa
        MongoCursor<Document> cursor2 = collection.find(
        and(gt("Precio", 50), eq("Categoría.NombreCategoria", "Ropa"))
        ).iterator();

        while (cursor2.hasNext()) {
            System.out.println(cursor2.next().toJson());
        }
    }
}