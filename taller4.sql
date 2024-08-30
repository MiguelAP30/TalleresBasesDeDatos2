--TALLER 4
create table clientes ( 
nombre varchar(60) not null,
identificacion varchar(10) primary key,
edad int not null,
correo varchar(64)
);

create table productos(
codigo varchar(8) primary key,
nombre varchar(60) not null,
stock int not null,
valor_unitario float not null
);

create type estado as enum('PENDIENTE','BLOQUEADO','ENTREGADO');

create table facturas(
id SERIAL primary key, 
fecha date not null,
cantidad int not null,
valor_total float not null,
pedido_estado estado not null,
producto_id varchar(8),
cliente_id varchar(10),
foreign key(producto_id)references productos(codigo),
foreign key(cliente_id) references clientes(identificacion)
);

insert into clientes (identificacion, nombre, edad, correo)values('1022322054','miguel angel',20,'miguelonperez300@gmail.com');
insert into clientes (identificacion, nombre, edad, correo)values('1022322055','santiago valencia',18,'miguelonperez300@gmail.com');
insert into clientes (identificacion, nombre, edad, correo)values('1022322056','manuel alejandro',19,'miguelonperez300@gmail.com');

insert into productos(codigo, nombre, stock, valor_unitario)values('1','pollo',50,15000);
insert into productos(codigo, nombre, stock, valor_unitario)values('2','carne',50,20000);
insert into productos(codigo, nombre, stock, valor_unitario)values('3','huevo',50,600);

insert into facturas( fecha, cantidad, valor_total, pedido_estado, producto_id, cliente_id)values('2003-11-12',2,30000,'ENTREGADO','1','1022322054');
insert into facturas( fecha, cantidad, valor_total, pedido_estado, producto_id, cliente_id)values('2003-11-13',4,80000,'PENDIENTE','2','1022322055');
insert into facturas( fecha, cantidad, valor_total, pedido_estado, producto_id, cliente_id)values('2003-11-14',2,1200,'BLOQUEADO','3','1022322056');

--PARTE 1
CREATE OR REPLACE PROCEDURE verificar_stock(
	p_id_producto VARCHAR,
	p_cantidad_compra INTEGER
)
LANGUAGE plpgsql
AS $$
DECLARE
	v_stock_actual INTEGER;
BEGIN
	SELECT stock INTO v_stock_actual FROM productos WHERE codigo = p_id_producto;
	IF v_stock_actual >= p_cantidad_compra THEN
		RAISE NOTICE 'Hay stock suficiente para efectuar la compra';
	ELSE
		RAISE NOTICE 'No hay stock suficiente para efectuar la compra';
	END IF;
END;
$$;

--PARTE 2
CREATE OR REPLACE PROCEDURE actulaizar_estado_pedido(
	p_id_factura INTEGER,
	p_nuevo_estado estado
)
LANGUAGE plpgsql
AS $$
DECLARE
	v_estado_actual estado;
BEGIN
	SELECT pedido_estado INTO v_estado_actual FROM facturas WHERE id = p_id_factura;
	IF v_estado_actual = 'ENTREGADO' THEN
		RAISE NOTICE 'El pedido ya esta entregado';
	ELSE
		UPDATE facturas SET pedido_estado = p_nuevo_estado WHERE id = p_id_factura;
		RAISE NOTICE 'El pedido ha sido actualizado';
	END IF;
END;
$$;

--CALL

call verificar_stock('1',2);
call verificar_stock('1',51);
call actulaizar_estado_pedido(1,'ENTREGADO');
call actulaizar_estado_pedido(2,'ENTREGADO');
