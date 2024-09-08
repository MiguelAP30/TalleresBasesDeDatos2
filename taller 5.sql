--TALLER 5
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

create table auditoria(
id serial primary key,
fecha_inicio date not null,
fecha_final date not null,
factura_id integer,
pedido_estado estado,
foreign key(factura_id)references facturas(id)
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
create or replace procedure obtener_total_stock()
language plpgsql
as $$
declare 
    v_total_stock integer:= 0;
    v_stock_actual integer;
    v_nombre_producto varchar;
begin
    for v_nombre_producto, v_stock_actual in select nombre, stock from productos
    loop
		raise notice 'el nombre del producto es: %', v_nombre_producto;
		raise notice 'el stock actual del producto es de: %', v_stock_actual;
		v_total_stock := v_total_stock + v_stock_actual;
    end loop;
	raise notice 'El estock total es de: %', v_total_stock;
END;
$$;

call obtener_total_stock();

--PARTE 2

create or replace procedure generar_auditoria(
	P_fecha_inicio date,
	p_fecha_final date
)
language plpgsql
as $$
declare 
    v_id_factura integer;
    v_estado_factura estado;
	v_fecha date;
begin
    for v_fecha, v_id_factura, v_estado_factura in select fecha, id, pedido_estado from facturas
    loop
		if v_fecha between P_fecha_inicio and p_fecha_final then
			insert into auditoria(fecha_inicio, fecha_final, factura_id, pedido_estado)values(P_fecha_inicio, p_fecha_final, v_id_factura, v_estado_factura);
    		raise notice 'Se ha creado la auditoria';
		end if;
	end loop;
END;

$$;

call generar_auditoria('2000-11-12', '2004-11-12');

--PARTE 3
create or replace procedure simular_ventas_mes()
language plpgsql
as $$
declare 
    v_dia integer :=1 ;
    v_identificacion varchar;
	v_cantidad_random integer;
begin
    while v_dia <= 30 loop
		for	v_identificacion in select identificacion from clientes
		loop
			v_cantidad_random:= floor(1+random()*2);
			insert into facturas( fecha, cantidad, valor_total, pedido_estado, producto_id, cliente_id)values('2024-09-02', v_cantidad_random, 30000,'ENTREGADO','1', v_identificacion);
			raise notice 'se creo una factura';
		end loop;
		v_dia:= v_dia+1; 
	end loop;
END;

$$;

call simular_ventas_mes();
