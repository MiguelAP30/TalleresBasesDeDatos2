create table facturas(
	id serial primary key,
	codigo_punto_venta bigint,
	descripcion jsonb
);

create or replace procedure taller16.agregar_factura( p_codigo_punto_venta bigint, p_descripcion jsonb)
as $$
declare
	v_valor_total numeric;
	v_descuento numeric;
begin
	v_valor_total := (p_descripcion->>'total_factura')::numeric;
	v_descuento := (p_descripcion ->>'total_descuento')::numeric;
	if(v_valor_total > 10000) then
		raise exception 'El valor total de la factura excede el límite permitido de 10000 dólares';
	end if;
	v_descuento := (v_descuento / 100) * v_valor_total;
	if(v_descuento > 50) then
		raise exception 'El descuento aplicado no puede superar los 50 dólares';
	end if;
	
	insert into taller16.facturas(codigo_punto_venta, descripcion) values(p_codigo_punto_venta, p_descripcion);
end;
$$ language plpgsql;

create or replace procedure taller16.actualizar_factura(
    p_id bigint, 
    p_descripcion jsonb
)
as $$
begin

    if not exists (select 1 from taller16.facturas where id = p_id) then
        raise exception 'La factura con id % no existe', p_id;
    end if;

    update taller16.facturas
    set descripcion = p_descripcion
    where id = p_id;

end;
$$ language plpgsql;

create or replace function taller16.obtener_nombre_cliente(p_identificacion varchar)
returns varchar
as $$
declare
    v_nombre_cliente varchar;
begin
    select cast(descripcion->>'cliente' as varchar) 
    into v_nombre_cliente
    from taller16.facturas
    where cast(descripcion->>'identificacion' as varchar) = p_identificacion;

    if v_nombre_cliente is null then
        raise notice 'No se encontró un cliente con la identificación %', p_identificacion;
    end if;

    return v_nombre_cliente;
end;
$$ language plpgsql;

create or replace function taller16.obtener_facturas()
returns table(
    p_codigo_factura int, 
    p_nombre_cliente varchar, 
    p_identificacion varchar, 
    p_total_descuento int, 
    p_total_factura numeric
)
as $$
begin
    return query
    select 
        id as p_codigo_factura, 
        cast(descripcion->>'cliente' as varchar) as p_nombre_cliente, 
        cast(descripcion->>'identificacion' as varchar) as p_identificacion, 
        (descripcion->>'total_descuento')::int as p_total_descuento, 
        (descripcion->>'total_factura')::numeric as p_total_factura
    from taller16.facturas;
end;
$$ language plpgsql;

create or replace function taller16.obtener_productos_por_factura(p_id_factura bigint)
returns table(
    p_cantidad int, 
    p_valor numeric, 
    p_nombre varchar, 
    p_descripcion varchar, 
    p_precio numeric
)
as $$
begin
    return query
    select 
        (producto->>'cantidad')::int as p_cantidad,
        (producto->>'valor')::numeric as p_valor,
        cast (producto->>'nombre' as varchar) as p_nombre,
        cast (producto->>'descripcion' as varchar) as p_descripcion,
        (producto->>'precio')::numeric as p_precio
    from 
        taller16.facturas,
        jsonb_array_elements(descripcion->'productos') as producto
    where 
        id = p_id_factura;  
end;
$$ language plpgsql;

call taller16.agregar_factura(
    1, 
    '{
        "cliente": "Miguel Angel", 
        "identificacion": "1022322054", 
        "direccion": "villa carmenza", 
        "codigo": "14", 
        "total_descuento": 0, 
        "total_factura": 9000, 
        "productos": [
            {
                "cantidad": 12, 
                "valor": 1500, 
                "producto": {"nombre": "huevos", "descripcion": "dulce", "precio": 1200, "categorias": ["String1", "String2", "String3"]
                }
            }
        ]
    }'
);

call taller16.actualizar_factura(
    1, 
    '{
        "cliente": "Abelardo", 
        "identificacion": "1022322054", 
        "direccion": "chipre", 
        "codigo": "14", 
        "total_descuento": 10, 
        "total_factura": 9500, 
        "productos": [
            {
                "cantidad": 5, 
                "valor": 1500, 
                "producto": {"nombre": "pollo", "descripcion": "100mg", "precio": 1000, "categorias": ["proteina", "carbohidratos"]
                }
            }
        ]
    }'
);

select taller16.obtener_nombre_cliente('1022322054');

select * from taller16.obtener_facturas();

select * from taller16.obtener_productos_por_factura(1);
