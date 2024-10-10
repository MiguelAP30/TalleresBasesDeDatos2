create table factura (
	codigo varchar primary key,
	cliente varchar,
	producto varchar,
	descuento numeric,
	valor_total numeric,
	numero_fe varchar
)


CREATE SEQUENCE codigo
    START WITH 1
    INCREMENT BY 1;
    
create sequence numero_fe
	start with 100
	increment by 100;
	

create or replace procedure poblar_factura()
language plpgsql
as $$
declare
	cliente_v text;
	producto_v text;
	descuento_v numeric;
	valor_total_v numeric;
begin
	for i in 1..10 loop
		cliente_v := (ARRAY['miguel', 'juan', 'alejandro'])[TRUNC(RANDOM() * 3 + 1)::INT];
		producto_v := (ARRAY['papitas', 'gaseosa', 'vegetal'])[TRUNC(RANDOM() * 3 + 1)::INT];
		descuento_v := random();
		valor_total_v := (random()*10000 + 5000)::int;
		insert into factura(codigo,cliente,producto,descuento,valor_total,numero_fe) values (nextval('codigo'), cliente_v, producto_v, descuento_v, valor_total_v, nextval('numero_fe'));
	end loop;
end;
$$;

call poblar_factura();
select * from factura;