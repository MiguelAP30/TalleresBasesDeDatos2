--Taller 7
create table clientes(
identificacion varchar(10) primary key,
nombre varchar(50),
edad INTEGER,
correo varchar(40)
);

create table productos(
codigo varchar(10) primary key,
nombre varchar(50),
stock INTEGER,
valor_unitario number
);

create table facturas(
id varchar(10) primary key,
cantidad INTEGER,
valor_total number,
fecha date,
pedido_estado varchar(15) not NULL CHECK ((pedido_estado) IN ('PENDIENTE', 'ENTREGADO', 'BLOQUEADO')),
cliente_id varchar(10),
producto_id varchar(10),
foreign key(cliente_id) references clientes(identificacion),
foreign key(producto_id) references productos(codigo)
);

insert into productos(codigo, nombre, stock, valor_unitario) values('001', 'Paleta', 20, 2000);
insert into clientes(identificacion, nombre, edad, correo) values ('1004367717', 'Maria', 25, 'maria@example.com');

INSERT INTO facturas(id, fecha, cantidad, valor_total, pedido_estado, cliente_id, producto_id) 
VALUES ('1', TO_DATE('2024-08-30', 'YYYY-MM-DD'), 5, 6000, 'ENTREGADO', '1004367717', '001');

INSERT INTO facturas(id, fecha, cantidad, valor_total, pedido_estado, cliente_id, producto_id) 
VALUES ('2', TO_DATE('2024-09-30', 'YYYY-MM-DD'), 6, 7000, 'PENDIENTE', '1004367717', '001');

CREATE OR REPLACE PROCEDURE verificar_stock
IS 
    v_total_stock INTEGER := 0;
BEGIN
    FOR producto IN (SELECT nombre, stock FROM productos) LOOP
        DBMS_OUTPUT.PUT_LINE('El nombre del producto es: ' || producto.nombre);
        DBMS_OUTPUT.PUT_LINE('El stock actual del producto es de: ' || producto.stock);
        v_total_stock := v_total_stock + producto.stock;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('El stock total es de: ' || v_total_stock);
END;

call verificar_stock();

