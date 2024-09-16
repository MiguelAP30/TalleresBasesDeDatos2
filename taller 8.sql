create table usuarios(
id serial primary key,
nombre varchar(20) not null,
identificacion varchar(20) not null unique,
edad integer not null,
email varchar(64) not null,
);

create table facturas(
id serial primary key,
fecha date not null,
producto varchar(20) not null,
cantidad integer not null,
valor_unitario numeric not null,
valor_total numeric not null,
usuario_id integer not null,
foreign key(usuario_id) references usuarios(id)
);

--PARTE 1

--POBLAR TABLA 50 USUARIOS
CREATE OR REPLACE PROCEDURE poblar_usuarios()
LANGUAGE plpgsql
AS $$
DECLARE
    v_usuarios INTEGER := 1;
BEGIN
    WHILE v_usuarios <= 50 LOOP
        INSERT INTO usuarios(nombre, identificacion, edad, email)
        VALUES('Usuario' || v_usuarios, '123456' || v_usuarios, 18 + v_usuarios, 'usuario' || v_usuarios || '@gmail.com');
        v_usuarios := v_usuarios + 1;
    END LOOP;
    RAISE NOTICE 'Se crearon 50 usuarios';
END;
$$;

CALL poblar_usuarios();

--POBLAR TABLA 25 FACTURAS
CREATE OR REPLACE PROCEDURE poblar_facturas()
LANGUAGE plpgsql
AS $$
DECLARE
    v_facturas INTEGER := 1;
    v_usuario_id INTEGER;
BEGIN
    WHILE v_facturas <= 25 LOOP
        SELECT id INTO v_usuario_id FROM usuarios ORDER BY RANDOM() LIMIT 1;
        INSERT INTO facturas(fecha, producto, cantidad, valor_unitario, valor_total, usuario_id)
        VALUES(CURRENT_DATE, 'Producto' || v_facturas, v_facturas, 1000 + v_facturas, 1000 + v_facturas, v_usuario_id);
        v_facturas := v_facturas + 1;
    END LOOP;
    RAISE NOTICE 'Se crearon 25 facturas';
END;
$$;

CALL poblar_facturas();

--PARTE 2
