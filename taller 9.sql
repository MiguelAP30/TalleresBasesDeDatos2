create type nombre_concepto as enum('salario','horas_extra','prestaciones','impuestos');

create table conceptos(
codigo serial primary key,
nombre nombre_concepto not null,
porcentaje numeric not null
);

create table tipo_contrato(
codigo serial primary key,
cargo varchar(20) not null,
salario_total numeric not null
);

create table empleados(
identificacion serial primary key,
nombre varchar(50) not null,
tipo_contrato_id INTEGER not null,
foreign key(tipo_contrato_id) references tipo_contrato(codigo)
);

CREATE TABLE nomina(
codigo serial primary key,
mes integer not null,
anio integer not null,
fecha_pago date not null,
total_devengado numeric not null,
total_deducciones numeric not null,
total numeric not null,
empleado_id integer,
foreign key(empleado_id) references empleados(identificacion)
);

CREATE TABLE detalles_nomina(
codigo serial primary key,
valor numeric not null,
concepto_id integer,
nomina_id integer,
foreign key(concepto_id) references conceptos(codigo),
foreign key(nomina_id) references nomina(codigo)
);



--Parte 1
-- poblar bd con 10 empleados, 10 tipo_contrato, 15 conceptos, 5 nomina y 15 detalles_nomina

INSERT INTO tipo_contrato (codigo, cargo, salario_total) VALUES 
(111, 'Cargo1', 1000), 
(112, 'Cargo2', 2000), 
(113, 'Cargo3', 3000), 
(114, 'Cargo4', 4000), 
(115, 'Cargo5', 5000);

CREATE OR REPLACE PROCEDURE poblar_bd()
LANGUAGE plpgsql
AS $$
DECLARE 
    v_empleados INTEGER := 1;
    v_tipo_contrato_id INTEGER;  
    v_conceptos INTEGER := 1;
    v_nomina INTEGER := 1;
    v_detalles_nomina INTEGER;
    v_porcentaje NUMERIC := 0.1;
    v_mes INTEGER := 1;
    v_anio INTEGER := 2021;
    v_empleado_id INTEGER;
    v_concepto_id INTEGER;
    v_nomina_id INTEGER;
BEGIN
    RAISE NOTICE 'Iniciando inserción de empleados...';
    -- Insertar empleados después de insertar tipos de contrato
    v_empleados := 1;
    FOR v_tipo_contrato_id IN SELECT codigo FROM tipo_contrato LOOP  
        INSERT INTO empleados(nombre, tipo_contrato_id)
        VALUES('Empleado ' || v_empleados, v_tipo_contrato_id)
        RETURNING identificacion INTO v_empleado_id;

        RAISE NOTICE 'Insertado empleado: % con tipo_contrato_id: %', v_empleado_id, v_tipo_contrato_id;

        v_empleados := v_empleados + 1;
    END LOOP;

    -- Insertar conceptos
    RAISE NOTICE 'Iniciando inserción de conceptos...';
    v_conceptos := 1;
    WHILE v_conceptos <= 4 LOOP
        CASE v_conceptos
            WHEN 1 THEN
                INSERT INTO conceptos(nombre, porcentaje)
                VALUES('salario', v_porcentaje);
            WHEN 2 THEN
                INSERT INTO conceptos(nombre, porcentaje)
                VALUES('horas_extra', v_porcentaje);
            WHEN 3 THEN
                INSERT INTO conceptos(nombre, porcentaje)
                VALUES('prestaciones', v_porcentaje);
            WHEN 4 THEN
                INSERT INTO conceptos(nombre, porcentaje)
                VALUES('impuestos', v_porcentaje);
        END CASE;

        v_conceptos := v_conceptos + 1;
        v_porcentaje := v_porcentaje + 0.1;
    END LOOP;

    -- Insertar nóminas y detalles de nómina
    RAISE NOTICE 'Iniciando inserción de nóminas...';
    v_nomina := 1;
    FOR v_empleado_id IN SELECT identificacion FROM empleados LOOP
        -- Insertar nómina
        INSERT INTO nomina(mes, anio, fecha_pago, total_devengado, total_deducciones, total, empleado_id)
        VALUES(v_mes, v_anio, '2021-01-01', 1000, 100, 900, v_empleado_id)
        RETURNING codigo INTO v_nomina_id;

        RAISE NOTICE 'Insertada nómina para empleado_id: % con nómina_id: %', v_empleado_id, v_nomina_id;

        -- Insertar detalles de nómina
        v_detalles_nomina := 1;
        FOR v_concepto_id IN SELECT codigo FROM conceptos LOOP
            INSERT INTO detalles_nomina(valor, concepto_id, nomina_id)
            VALUES(100, v_concepto_id, v_nomina_id);

            RAISE NOTICE 'Insertado detalle_nomina con concepto_id: % y nomina_id: %', v_concepto_id, v_nomina_id;

            v_detalles_nomina := v_detalles_nomina + 1;

            -- Salir si ya insertaste 15 detalles (aunque debería ser 4 conceptos)
            IF v_detalles_nomina > 15 THEN
                EXIT;
            END IF;
        END LOOP;

        v_nomina := v_nomina + 1;
        v_mes := v_mes + 1;

        -- Salir si ya insertaste 5 nóminas
        IF v_nomina > 5 THEN
            EXIT;
        END IF;
    END LOOP;

    RAISE NOTICE 'Población de la base de datos completada.';
END;
$$;


CALL poblar_bd();

--Parte 2
-- crear funcion obtener_nomina_empleado que recibe el id de un empleado, mes y anio y retorna el nombre del empleado, el total devengado, total deducciones y total de la nomina

CREATE OR REPLACE FUNCTION obtener_nomina_empleado(
    p_empleado_id INTEGER,
    p_mes INTEGER,
    p_anio INTEGER)
RETURNS TABLE(
    nombre varchar(50),
    total_devengado numeric,
    total_deducciones numeric,
    total numeric)
AS $$
BEGIN
    RETURN QUERY
    SELECT e.nombre, n.total_devengado, n.total_deducciones, n.total
    FROM empleados e
    JOIN nomina n ON e.identificacion = n.empleado_id
    WHERE e.identificacion = p_empleado_id AND n.mes = p_mes AND n.anio = p_anio;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM obtener_nomina_empleado(32, 1, 2021);

-- crear una funcion total_por_contrato que reciba el tipo de contrato y retorne el nombre del empleado, fecha de pago, año, mes, total devengado, total deducciones y total de la nomina

CREATE OR REPLACE FUNCTION total_por_contrato(
    p_tipo_contrato_id INTEGER)
RETURNS TABLE(
    nombre varchar(50),
    fecha_pago date,
    anio integer,
    mes integer,
    total_devengado numeric,
    total_deducciones numeric,
    total numeric)
AS $$
BEGIN
    RETURN QUERY
    SELECT e.nombre, n.fecha_pago, n.anio, n.mes, n.total_devengado, n.total_deducciones, n.total
    FROM empleados e
    JOIN nomina n ON e.identificacion = n.empleado_id
    WHERE e.tipo_contrato_id = p_tipo_contrato_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM total_por_contrato(111);

