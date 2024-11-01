
-- Crear tabla usuarios
CREATE TABLE usuarios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(40),
    direccion VARCHAR(40),
    email VARCHAR(40),
    fecha_registro DATE,
    estadoU VARCHAR(40)
);

-- Crear tabla tarjetas
CREATE TABLE tarjetas (
    id SERIAL PRIMARY KEY,
    numero_tarjeta VARCHAR(40),
    fecha_de_expiracion DATE,
    cvv VARCHAR(3),
    tipo_tarjeta VARCHAR(40)
);

-- Crear tabla productos
CREATE TABLE productos (
    id SERIAL PRIMARY KEY,
    codigo_productos VARCHAR(40),
    nombre VARCHAR(40),
    categoria VARCHAR(40),
    porcentaje_impuesto NUMERIC,
    precio NUMERIC
);

-- Crear tabla pagos
CREATE TABLE pagos (
    id SERIAL PRIMARY KEY,
    codigo_pago VARCHAR(40),
    fecha DATE,
    estadop VARCHAR(40),
    monto NUMERIC,
    producto_id INT,
    tarjeta_id INT,
    usuario_id INT,
    FOREIGN KEY (producto_id) REFERENCES productos(id),
    FOREIGN KEY (tarjeta_id) REFERENCES tarjetas(id),
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
);

-- Crear tabla comprobante_de_pago
CREATE TABLE comprobante_de_pago (
    id SERIAL PRIMARY KEY,
    detalle_xml TEXT,
    detalle_json TEXT
);





--PRIMERA PREGUNTA




-- Crear función almacenada para obtener pagos de un usuario
CREATE OR REPLACE FUNCTION obtener_pagos_usuario(p_usuario_id INT, p_fecha DATE)
RETURNS TABLE (
    codigo_pago VARCHAR,
    nombre_producto VARCHAR,
    monto NUMERIC,
    estado VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT p.codigo_pago, pr.nombre, p.monto, p.estadop
    FROM pagos p
    JOIN productos pr ON p.producto_id = pr.id
    WHERE p.usuario_id = p_usuario_id AND p.fecha = p_fecha;
END;
$$ LANGUAGE plpgsql;

-- Crear función almacenada para obtener las tarjetas del usuario que han pagado un monto mayor a $1000
CREATE OR REPLACE FUNCTION obtener_tarjetas_usuario(p_usuario_id INT)
RETURNS TABLE (
    nombre_usuario VARCHAR,
    email VARCHAR,
    numero_tarjeta VARCHAR,
    cvv VARCHAR,
    tipo_tarjeta VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT u.nombre, u.email, t.numero_tarjeta, t.cvv, t.tipo_tarjeta
    FROM pagos p
    JOIN tarjetas t ON p.tarjeta_id = t.id
    JOIN usuarios u ON p.usuario_id = u.id
    WHERE p.usuario_id = p_usuario_id AND p.monto > 1000;
END;
$$ LANGUAGE plpgsql;






--SEGUNDA PREGUNTA:

--con cursores realizar las siguientesfunciones almacenadas: -funcion almacenada obtener tarjeta con detalle de usuario. Parametro: usuario_id. Retornar en el cursor numero_tarjeta, fecha_expiracion, nombre, email. -funcion almacenada obtener pagos menores a $1000 dada una fecha. parametros: fecha. retornar en el cursor monto, estado, nombre_producto, porcentaje_impuesto, usuario_direccion, email
-- Crear función almacenada para obtener tarjeta con detalle de usuario usando cursores
CREATE OR REPLACE FUNCTION obtener_tarjeta_detalle_usuario(p_usuario_id INT)
RETURNS REFCURSOR AS $$
DECLARE
    tarjeta_cursor REFCURSOR;
BEGIN
    OPEN tarjeta_cursor FOR
    SELECT t.numero_tarjeta, t.fecha_de_expiracion, u.nombre, u.email
    FROM tarjetas t
    JOIN usuarios u ON t.id = u.id
    WHERE u.id = p_usuario_id;
    RETURN tarjeta_cursor;
END;
$$ LANGUAGE plpgsql;

-- Crear función almacenada para obtener pagos menores a $1000 dada una fecha usando cursores
CREATE OR REPLACE FUNCTION obtener_pagos_menores(p_fecha DATE)
RETURNS REFCURSOR AS $$
DECLARE
    pagos_cursor REFCURSOR;
BEGIN
    OPEN pagos_cursor FOR
    SELECT p.monto, p.estadop, pr.nombre, pr.porcentaje_impuesto, u.direccion, u.email
    FROM pagos p
    JOIN productos pr ON p.producto_id = pr.id
    JOIN usuarios u ON p.usuario_id = u.id
    WHERE p.fecha = p_fecha AND p.monto < 1000;
    RETURN pagos_cursor;
END;
$$ LANGUAGE plpgsql;


--crear los siguientes procedimientos almacenados para el campo xml y json de la tabla comprobantes de pago: -procedimiento guardar_xml: insertar el xml <pago><codigoPago></codigoPago><nombreUsuario></nombreUsuario><numeroTarjeta></numeroTarjeta><nombreProducto></nombreProducto><montoPago></montoPago></pago>
--procedimiento guardar_json: insertar el json: {emailUsuario: "", numeroTarjeta: "", tipoTarjeta: "", codigoProducto: "", codigoPago: "", montoPago ""}
-- Crear procedimiento para guardar XML en la tabla comprobante_de_pago
CREATE OR REPLACE PROCEDURE guardar_xml(
    p_codigo_pago VARCHAR,
    p_nombre_usuario VARCHAR,
    p_numero_tarjeta VARCHAR,
    p_nombre_producto VARCHAR,
    p_monto_pago NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO comprobante_de_pago (detalle_xml)
    VALUES (
        '<pago>' ||
        '<codigoPago>' || p_codigo_pago || '</codigoPago>' ||
        '<nombreUsuario>' || p_nombre_usuario || '</nombreUsuario>' ||
        '<numeroTarjeta>' || p_numero_tarjeta || '</numeroTarjeta>' ||
        '<nombreProducto>' || p_nombre_producto || '</nombreProducto>' ||
        '<montoPago>' || p_monto_pago || '</montoPago>' ||
        '</pago>'
    );
END;
$$;

-- Crear procedimiento para guardar JSON en la tabla comprobante_de_pago
CREATE OR REPLACE PROCEDURE guardar_json(
    p_email_usuario VARCHAR,
    p_numero_tarjeta VARCHAR,
    p_tipo_tarjeta VARCHAR,
    p_codigo_producto VARCHAR,
    p_codigo_pago VARCHAR,
    p_monto_pago NUMERIC
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO comprobante_de_pago (detalle_json)
    VALUES (
        json_build_object(
            'emailUsuario', p_email_usuario,
            'numeroTarjeta', p_numero_tarjeta,
            'tipoTarjeta', p_tipo_tarjeta,
            'codigoProducto', p_codigo_producto,
            'codigoPago', p_codigo_pago,
            'montoPago', p_monto_pago
        )::TEXT
    );
END;
$$;




--TERCERA PREGUNTA
--crear un before trigger llamado validaciones_producto donde se debe validar que el precio debe ser mayor a 0 y menor a 20000, el porcentaje debe ser mayor a 1% y menor o igual a 20% 
--crear un after trigger llamado trigger_xml que permita almacenar el xml y el json posteriora al insertar un registro en la tabla pagos




-- Crear función para el trigger validaciones_producto
CREATE OR REPLACE FUNCTION validaciones_producto()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.precio <= 0 OR NEW.precio >= 20000 THEN
        RAISE EXCEPTION 'El precio debe ser mayor a 0 y menor a 20000';
    END IF;

    IF NEW.porcentaje_impuesto <= 1 OR NEW.porcentaje_impuesto > 20 THEN
        RAISE EXCEPTION 'El porcentaje de impuesto debe ser mayor a 1% y menor o igual a 20%';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger before para validaciones_producto
CREATE TRIGGER validaciones_producto
BEFORE INSERT OR UPDATE ON productos
FOR EACH ROW
EXECUTE FUNCTION validaciones_producto();

-- Crear función para el trigger trigger_xml
CREATE OR REPLACE FUNCTION trigger_xml()
RETURNS TRIGGER AS $$
BEGIN
    -- Insertar XML en comprobante_de_pago
    INSERT INTO comprobante_de_pago (detalle_xml)
    VALUES (
        '<pago>' ||
        '<codigoPago>' || NEW.codigo_pago || '</codigoPago>' ||
        '<nombreUsuario>' || (SELECT nombre FROM usuarios WHERE id = NEW.usuario_id) || '</nombreUsuario>' ||
        '<numeroTarjeta>' || (SELECT numero_tarjeta FROM tarjetas WHERE id = NEW.tarjeta_id) || '</numeroTarjeta>' ||
        '<nombreProducto>' || (SELECT nombre FROM productos WHERE id = NEW.producto_id) || '</nombreProducto>' ||
        '<montoPago>' || NEW.monto || '</montoPago>' ||
        '</pago>'
    );

    -- Insertar JSON en comprobante_de_pago
    INSERT INTO comprobante_de_pago (detalle_json)
    VALUES (
        json_build_object(
            'emailUsuario', (SELECT email FROM usuarios WHERE id = NEW.usuario_id),
            'numeroTarjeta', (SELECT numero_tarjeta FROM tarjetas WHERE id = NEW.tarjeta_id),
            'tipoTarjeta', (SELECT tipo_tarjeta FROM tarjetas WHERE id = NEW.tarjeta_id),
            'codigoProducto', (SELECT codigo_productos FROM productos WHERE id = NEW.producto_id),
            'codigoPago', NEW.codigo_pago,
            'montoPago', NEW.monto
        )::TEXT
    );

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Crear trigger after para trigger_xml
CREATE TRIGGER trigger_xml
AFTER INSERT ON pagos
FOR EACH ROW
EXECUTE FUNCTION trigger_xml();





--CUARTA PREGUNTA
--crear secuencias para los siguientes campos:
--el codigo de producto debe iniciar en desde el 5 e incrementar de 5 en 5 
--el codigo unico de pagos debe iniciar en 1 e incrementar de 100 en 100
--crear las siguientes funciones almacenadas para el campo de xml de la tabla comprobante de pago:
--obtener info_xml: retornar la informacion del nombreUsuario, nombreProducto y montoPago del campo xml
--obtener info_json: retornar la informacion del emailUsuario, codigoProducto, montoPago 





-- Crear secuencia para el código de producto
CREATE SEQUENCE seq_codigo_producto
START WITH 5
INCREMENT BY 5;

-- Crear secuencia para el código único de pagos
CREATE SEQUENCE seq_codigo_pago
START WITH 1
INCREMENT BY 100;	

-- Crear función para obtener información del campo XML
CREATE OR REPLACE FUNCTION obtener_info_xml(p_id INT)
RETURNS TABLE (
    nombre_usuario VARCHAR,
    nombre_producto VARCHAR,
    monto_pago NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        xpath('/pago/nombreUsuario/text()', detalle_xml)::TEXT,
        xpath('/pago/nombreProducto/text()', detalle_xml)::TEXT,
        xpath('/pago/montoPago/text()', detalle_xml)::NUMERIC
    FROM comprobante_de_pago
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

-- Crear función para obtener información del campo JSON
CREATE OR REPLACE FUNCTION obtener_info_json(p_id INT)
RETURNS TABLE (
    email_usuario VARCHAR,
    codigo_producto VARCHAR,
    monto_pago NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        (detalle_json::json->>'emailUsuario')::TEXT,
        (detalle_json::json->>'codigoProducto')::TEXT,
        (detalle_json::json->>'montoPago')::NUMERIC
    FROM comprobante_de_pago
    WHERE id = p_id;
END;
$$ LANGUAGE plpgsql;

-- Insertar un nuevo producto utilizando la secuencia
INSERT INTO productos (codigo_productos, nombre, categoria, porcentaje_impuesto, precio)
VALUES (nextval('seq_codigo_producto'), 'Producto 3', 'Categoria 3', 12, 1800);

-- Insertar un nuevo pago utilizando la secuencia
INSERT INTO pagos (codigo_pago, fecha, estadop, monto, producto_id, tarjeta_id, usuario_id)
VALUES (nextval('seq_codigo_pago'), '2023-03-03', 'Completado', 1500, 1, 1, 1);

-- Llamar a la función obtener_info_xml
SELECT * FROM obtener_info_xml(1);

-- Llamar a la función obtener_info_json
SELECT * FROM obtener_info_json(1);






--INSERTS

-- Insertar datos en la tabla usuarios
INSERT INTO usuarios (nombre, direccion, email, fecha_registro, estadoU)
VALUES 
('Juan Perez', 'Calle Falsa 123', 'juan.perez@example.com', '2023-01-01', 'Activo'),
('Maria Lopez', 'Avenida Siempre Viva 456', 'maria.lopez@example.com', '2023-02-01', 'Activo');

-- Insertar datos en la tabla tarjetas
INSERT INTO tarjetas (numero_tarjeta, fecha_de_expiracion, cvv, tipo_tarjeta)
VALUES 
('1234567890123456', '2025-12-31', '123', 'Visa'),
('6543210987654321', '2024-11-30', '456', 'MasterCard');

-- Insertar datos en la tabla productos
INSERT INTO productos (codigo_productos, nombre, categoria, porcentaje_impuesto, precio)
VALUES 
('P001', 'Producto 1', 'Categoria 1', 10, 1500),
('P002', 'Producto 2', 'Categoria 2', 15, 2500);

-- Insertar datos en la tabla pagos
INSERT INTO pagos (codigo_pago, fecha, estadop, monto, producto_id, tarjeta_id, usuario_id)
VALUES 
('CP001', '2023-03-01', 'Completado', 1200, 1, 1, 1),
('CP002', '2023-03-02', 'Completado', 800, 2, 2, 2);

-- Llamar a la función obtener_pagos_usuario
SELECT * FROM obtener_pagos_usuario(1, '2023-03-01');

-- Llamar a la función obtener_tarjetas_usuario
SELECT * FROM obtener_tarjetas_usuario(1);

-- Llamar a la función obtener_tarjeta_detalle_usuario
DO $$
DECLARE
    tarjeta_cursor REFCURSOR;
    record RECORD;
BEGIN
    tarjeta_cursor := obtener_tarjeta_detalle_usuario(1);
    LOOP
        FETCH tarjeta_cursor INTO record;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Tarjeta: %, Expiración: %, Nombre: %, Email: %', record.numero_tarjeta, record.fecha_de_expiracion, record.nombre, record.email;
    END LOOP;
    CLOSE tarjeta_cursor;
END $$;

-- Llamar a la función obtener_pagos_menores
DO $$
DECLARE
    pagos_cursor REFCURSOR;
    record RECORD;
BEGIN
    pagos_cursor := obtener_pagos_menores('2023-03-02');
    LOOP
        FETCH pagos_cursor INTO record;
        EXIT WHEN NOT FOUND;
        RAISE NOTICE 'Monto: %, Estado: %, Producto: %, Impuesto: %, Dirección: %, Email: %', record.monto, record.estadop, record.nombre, record.porcentaje_impuesto, record.direccion, record.email;
    END LOOP;
    CLOSE pagos_cursor;
END $$;

-- Llamar al procedimiento guardar_xml
CALL guardar_xml('CP001', 'Juan Perez', '1234567890123456', 'Producto 1', 1200);

-- Llamar al procedimiento guardar_json
CALL guardar_json('juan.perez@example.com', '1234567890123456', 'Visa', 'P001', 'CP001', 1200);


--QUINTA PREGUNTA
--Realizar el llamado delas funciones de base de datos desde el lenguaje de programacion java de la pregunta 1 y pregunta 2




