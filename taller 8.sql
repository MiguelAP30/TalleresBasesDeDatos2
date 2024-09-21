CREATE TABLE usuarios (
	id int primary key,
    identificacion varchar not null unique,
    nombre VARCHAR NOT NULL,
    edad INT NOT NULL,
    correo VARCHAR NOT null
);
create table facturas(
	id int primary key,
	fecha date,
	producto varchar not null,
	cantidad int,
	valor_unitario numeric,
	valor_total numeric,
	usuario_id int not null,
	foreign key(usuario_id) references usuarios(id)
);

create or replace procedure poblar_base()
language plpgsql
as $$
declare 
	v_edad_cliente int;
	i int;
	v_valor_unitario_producto int;
	v_valor_total_producto int;
	v_cantidad_producto int;
	v_id_random int;
begin

	FOR i IN 1..50 
	LOOP
		v_edad_cliente := FLOOR(RANDOM() * 20) + 1;
		insert into usuarios(id, identificacion, nombre, edad, correo) values(i, 'identificacion' || i,  'miguel ' || i , v_edad_cliente, 'miguel' || i ||'@gmail.com');
	END LOOP;
	
	FOR i IN 1..25
	LOOP
		v_cantidad_producto := FLOOR(RANDOM() * 20) + 1;
		v_valor_unitario_producto := FLOOR(RANDOM() * (5000 - 500 + 1)) + 500;
		v_valor_total_producto := v_cantidad_producto * v_valor_unitario_producto;
		v_id_random := FLOOR(RANDOM() * 50) +1;
		insert into facturas(id, fecha, producto, cantidad, valor_unitario, valor_total, usuario_id) values(i, '2024-12-01', 'Arepas' , v_cantidad_producto, v_valor_unitario_producto, v_valor_total_producto, v_id_random);
	END LOOP;

end;
$$

create or replace procedure prueba_cliente_debe_existir()
language plpgsql
as $$
declare 
begin
	--Usuario existente
	insert into facturas(id, fecha, producto, cantidad, valor_unitario, valor_total, usuario_id) values(1003, '2024-12-01', 'Leche' , 2, 5500, 11000, 1);
	
	--Usuario inexistente
	insert into facturas(id, fecha, producto, cantidad, valor_unitario, valor_total, usuario_id) values(1014, '2024-12-01', 'Leche' , 2, 5500, 11000, 10012);

	exception 

	when foreign_key_violation then
		rollback;
		raise notice 'Error: no existe un usuario con ese id';
		raise notice 'Detalle: %', SQLERRM;
		insert into usuarios(id, identificacion, nombre, edad, correo) values(10012, 'identificacion100121' ,  'miguel 100'  , 28, 'miguel@gmail.com');
end;
$$

create or replace procedure prueba_producto_vacio()
language plpgsql
as $$
declare 
begin
	insert into facturas(id, fecha, producto, cantidad, valor_unitario, valor_total, usuario_id) values(1000, '2024-12-01', 'Huevos' , 18, 600, 10800, 1);
	
	--Usuario inexistente
	insert into facturas(id, fecha, producto, cantidad, valor_unitario, valor_total, usuario_id) values(1001, '2024-12-01', null , 0, 0, 0, 2);

	exception 
	when others then
		rollback;
		raise notice 'Error: producto no puede ser nulo';
		raise notice 'Detalle: %', SQLERRM;
end;
$$

create or replace procedure prueba_identificacion_unica()
language plpgsql
as $$
declare 
begin

	insert into usuarios(id, identificacion, nombre, edad, correo) values(1001, 'identificacion5' ,  'miguel 500'  , 28, 'miguel@gmail.com');

	exception 
	when unique_violation then
		rollback;
		raise notice 'Error: ya existe un usuario con esta identificacion';
		raise notice 'Detalle: %', SQLERRM;
		insert into usuarios(id, identificacion, nombre, edad, correo) values(1001, 'identificacion300' ,  'miguel 500'  , 28, 'miguel@gmail.com');
end;
$$

call poblar_base();
call prueba_cliente_debe_existir();
call prueba_producto_vacio();
call prueba_identificacion_unica();