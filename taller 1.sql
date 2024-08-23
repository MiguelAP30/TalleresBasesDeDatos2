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

create table pedidos(
id SERIAL primary key, 
fecha date not null,
cantidad int not null,
valor_total float not null,
producto_id varchar(8),
cliente_id varchar(10),
foreign key(producto_id)references productos(codigo),
foreign key(cliente_id) references clientes(identificacion)
);

begin;
insert into clientes (identificacion, nombre, edad, correo)values('1022322054','miguel angel',20,'miguelonperez300@gmail.com');
insert into clientes (identificacion, nombre, edad, correo)values('1022322055','santiago valencia',18,'miguelonperez300@gmail.com');
insert into clientes (identificacion, nombre, edad, correo)values('1022322056','manuel alejandro',19,'miguelonperez300@gmail.com');

insert into productos(codigo, nombre, stock, valor_unitario)values('1','pollo',50,15000);
insert into productos(codigo, nombre, stock, valor_unitario)values('2','carne',50,20000);
insert into productos(codigo, nombre, stock, valor_unitario)values('3','huevo',50,600);

insert into pedidos( fecha, cantidad, valor_total, producto_id, cliente_id)values('2003-11-12','2','30000','1','1022322054');
insert into pedidos( fecha, cantidad, valor_total, producto_id, cliente_id)values('2003-11-13','4','80000','2','1022322055');
insert into pedidos( fecha, cantidad, valor_total, producto_id, cliente_id)values('2003-11-14','2','1200','3','1022322056');

update clientes set nombre = 'miguel angel perez clavijo' where identificacion = '1022322054';
update clientes set edad = 22 where identificacion = '1022322055';

update productos set stock =48 where productos.codigo = '1';
update productos set stock =20100 where productos.codigo = '2';

update pedidos set fecha ='2024-08-23' where id ='1';
update pedidos set fecha ='2024-08-23' where id ='2';

delete from pedidos where id = '1';
delete from productos where codigo = '1';
delete from clientes where identificacion = '1022322054';

commit;