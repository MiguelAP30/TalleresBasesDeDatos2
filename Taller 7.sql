ALTER USER "TARRER7"  QUOTA UNLIMITED ON USERS;

CREATE TABLE clientes (
    identificacion varchar(10) PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    edad integer NOT NULL,
    correo VARCHAR(20) NOT NULL	
);
CREATE TABLE productos (
    codigo varchar(10) PRIMARY KEY,
    nombre VARCHAR(20) NOT NULL,
    stock integer NOT NULL,
    valor_unitario number NOT NULL	
);
CREATE TABLE facturas (
    id varchar(10) PRIMARY KEY,
    fecha DATE NOT NULL,
    cantidad integer NOT NULL,
    valor_total number NOT NULL,
    pedido_estado varchar(9) CHECK (pedido_estado IN ('PENDIENTE', 'BLOQUEADO', 'ENTREGADO')), 
    id_cliente varchar(10) NOT NULL,
    id_producto varchar(10) NOT NULL,
 	FOREIGN KEY (id_cliente) REFERENCES clientes(identificacion),
  	FOREIGN KEY (id_producto) REFERENCES productos(codigo)
);

INSERT INTO productos(codigo, nombre, stock, valor_unitario) VALUES ('1', 'pollo', 15, 1200);
INSERT INTO productos(codigo, nombre, stock, valor_unitario) VALUES ('2', 'miel', 50, 120);

INSERT INTO clientes(identificacion, nombre, edad, correo) 
VALUES ('1022322054', 'miguel angel', 19, 'miguel0@gmail.com');

INSERT INTO facturas(id, fecha, cantidad, valor_total, pedido_estado, id_cliente, id_producto) 
VALUES ('1', TO_DATE('2024-09-13', 'YYYY-MM-DD'), 5, 6000, 'PENDIENTE', '1022322054', '1');
INSERT INTO facturas(id, fecha, cantidad, valor_total, pedido_estado, id_cliente, id_producto) 
VALUES ('2', TO_DATE('2024-09-11', 'YYYY-MM-DD'), 1, 600, 'PENDIENTE', '1022322054', '2');
INSERT INTO facturas(id, fecha, cantidad, valor_total, pedido_estado, id_cliente, id_producto) 
VALUES ('3', TO_DATE('2024-09-10', 'YYYY-MM-DD'), 2, 1000, 'BLOQUEADO', '1022322054', '1');
INSERT INTO facturas(id, fecha, cantidad, valor_total, pedido_estado, id_cliente, id_producto) 
VALUES ('4', TO_DATE('2024-09-09', 'YYYY-MM-DD'), 3, 25000, 'ENTREGADO', '1022322054', '2');

CREATE OR REPLACE PROCEDURE verificar_stock(
    p_producto IN VARCHAR2,
    p_cantidad_compra IN INTEGER
)
IS 
    v_total_stock INTEGER := 0;
    v_stock_actual INTEGER;
    v_nombre_producto VARCHAR2(100);
BEGIN
    SELECT stock, nombre INTO v_stock_actual, v_nombre_producto 
    FROM productos 
    WHERE codigo = p_producto;
   
    DBMS_OUTPUT.PUT_LINE('El nombre del producto es: ' || v_nombre_producto);
    DBMS_OUTPUT.PUT_LINE('El stock actual del producto es: ' || v_stock_actual);
   
    IF v_stock_actual >= p_cantidad_compra THEN
        DBMS_OUTPUT.PUT_LINE('Hay suficiente stock para la compra.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('No hay suficiente stock para la compra.');
    END IF;
END;

CALL verificar_stock('1', 12);