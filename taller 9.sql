create table empleados(
identificacion serial primary key,
nombre varchar(50) not null,
tipo_contrato_id varchar(20) not null,
foreign key(tipo_contrato_id) references tipo_contrato(codigo)
);

create table tipo_contrato(
codigo serial primary key,
cargo varchar(20) not null,
salario_total numeric not null
);

create type nombre_concepto as enum('salario','horas_extra','prestaciones','impuestos');

create table conceptos(
codigo serial primary key,
nombre nombre_concepto not null,
porcentaje numeric not null
);

CREATE TABLE detalles_nomina(
codigo serial primary key,
valor numeric not null,
concepto_id integer,
nomina_id integer,
foreign key(concepto_id) references conceptos(codigo),
foreign key(nomina_id) references nomina(codigo)
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

--Parte 1
-- poblar bd con 10 empleados, 10 tipo_contrato, 15 conceptos, 5 nomina y 15 detalles_nomina

CREATE OR REPLACE PROCEDURE poblar_bd()
LANGUAGE plpgsql
AS $$
DECLARE 
    v_empleados INTEGER := 1;
    v_tipo_contrato INTEGER := 1;
    v_conceptos INTEGER := 1;
    v_nomina INTEGER := 1;
    v_detalles_nomina INTEGER := 1;
    v_salario_total NUMERIC := 1000;
    v_porcentaje NUMERIC := 0.1;
    v_mes INTEGER := 1;
    v_anio INTEGER := 2021;
    v_total_devengado NUMERIC;
    v_total_deducciones NUMERIC;
    v_total NUMERIC;
    v_empleado_id INTEGER;
    v_tipo_contrato_id INTEGER;
    v_concepto_id INTEGER;
    v_nomina_id INTEGER;
BEGIN
    WHILE v_empleados <= 10 LOOP
        INSERT INTO empleados(nombre, tipo_contrato_id)
        VALUES('Empleado' || v_empleados, v_tipo_contrato)
        RETURNING identificacion INTO v_empleado_id;

        v_empleados := v_empleados + 1;
        v_tipo_contrato := v_tipo_contrato + 1;
    END LOOP;

    WHILE v_tipo_contrato <= 10 LOOP
        INSERT INTO tipo_contrato(cargo, salario_total)
        VALUES('Cargo' || v_tipo_contrato, v_salario_total);

        v_tipo_contrato := v_tipo_contrato + 1;
        v_salario_total := v_salario_total + 1000;
    END LOOP;

    WHILE v_conceptos <= 15 LOOP
        INSERT INTO conceptos(nombre, porcentaje)
        VALUES('Concepto' || v_conceptos, v_porcentaje);

        v_conceptos := v_conceptos + 1;
        v_porcentaje := v_porcentaje + 0.1;
    END LOOP;

    WHILE v_nomina <= 5 LOOP
        INSERT INTO nomina(mes, anio, fecha_pago, total_devengado, total_deducciones, total, empleado_id)
        VALUES(v_mes, v_anio, '2021-01-01', 1000, 100, 900, v_nomina)
        RETURNING codigo INTO v_nomina_id;

        v_nomina := v_nomina + 1;
        v_mes := v_mes + 1;
    END LOOP;

    WHILE v_detalles_nomina <= 15 LOOP
        INSERT INTO detalles_nomina(valor, concepto_id, nomina_id)
        VALUES(100, v_concepto_id, v_nomina_id);

        v_detalles_nomina := v_detalles_nomina + 1;
        v_concepto_id := v_concepto_id + 1;
    END LOOP;
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

SELECT * FROM obtener_nomina_empleado(1, 1, 2021);

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

SELECT * FROM total_por_contrato(1);

