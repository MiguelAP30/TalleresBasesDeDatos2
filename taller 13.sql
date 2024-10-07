--TALLER 13 TRIGGER

CREATE TABLE empleado (
    nombre VARCHAR(100),
    identificacion INT PRIMARY KEY,
    edad INT,
    correo VARCHAR(100),
    salario NUMERIC
);

CREATE TABLE nomina (
    id SERIAL PRIMARY KEY,
    fecha DATE,
    total_ingresos NUMERIC,
    total_deducciones NUMERIC,
    total_neto NUMERIC,
    usuario_id INT,
    FOREIGN KEY (usuario_id) REFERENCES empleado(identificacion)
);

CREATE TABLE detalle_de_nomina (
    id SERIAL PRIMARY KEY,
    concepto VARCHAR(100),
    tipo VARCHAR(50),
    valor NUMERIC,
    nomina_id INT,
    FOREIGN KEY (nomina_id) REFERENCES nomina(id)
);

CREATE TABLE auditoria_nomina (
    id serial PRIMARY KEY,
    fecha DATE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    identificacion INTEGER NOT NULL,
    total_neto NUMERIC(12, 2) NOT NULL
);

CREATE TABLE auditoria_empleado (
    id serial PRIMARY KEY,
    fecha DATE NOT NULL,
    nombre VARCHAR(100) NOT NULL,--TALLER 13 TRIGGER

CREATE TABLE empleado (
    nombre VARCHAR(100),
    identificacion INT PRIMARY KEY,
    edad INT,
    correo VARCHAR(100),
    salario NUMERIC
);

CREATE TABLE nomina (
    id SERIAL PRIMARY KEY,
    fecha DATE,
    total_ingresos NUMERIC,
    total_deducciones NUMERIC,
    total_neto NUMERIC,
    usuario_id INT,
    FOREIGN KEY (usuario_id) REFERENCES empleado(identificacion)
);

CREATE TABLE detalle_de_nomina (
    id SERIAL PRIMARY KEY,
    concepto VARCHAR(100),
    tipo VARCHAR(50),
    valor NUMERIC,
    nomina_id INT,
    FOREIGN KEY (nomina_id) REFERENCES nomina(id)
);

CREATE TABLE auditoria_nomina (
    id serial PRIMARY KEY,
    fecha DATE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    identificacion INTEGER NOT NULL,
    total_neto NUMERIC(12, 2) NOT NULL
);

CREATE TABLE auditoria_empleado (
    id serial PRIMARY KEY,
    fecha DATE NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    identificacion INTEGER NOT NULL,
    concepto VARCHAR(20) NOT NULL,  -- "AUMENTO" o "DISMINUCION"
    valor NUMERIC(12, 2) NOT NULL
);

INSERT INTO empleado (nombre, identificacion, edad, correo, salario)
VALUES 
('Juan Pérez', 123456, 30, 'juan.perez@email.com', 3000000),
('María García', 654321, 28, 'maria.garcia@email.com', 3500000),
('Carlos Martínez', 789123, 35, 'carlos.martinez@email.com', 2800000);

INSERT INTO nomina (fecha, total_ingresos, total_deducciones, total_neto, usuario_id)
VALUES 
('2024-01-01', 3000000, 500000, 2500000, 123456),
('2024-01-01', 3500000, 600000, 2900000, 654321),
('2024-01-01', 2800000, 400000, 2400000, 789123);

-- Intentar insertar una nómina que exceda el presupuesto
INSERT INTO nomina (fecha, total_ingresos, total_deducciones, total_neto, usuario_id)
VALUES ('2024-02-01', 10000000, 1000000, 9000000, 123456);  -- Esto debería ser rechazado si supera el presupuesto

-- Intentar aumentar el salario de un empleado
UPDATE empleado
SET salario = 7000000
WHERE identificacion = 654321;  -- Este aumento será auditado y registrado

--  Realizar un trigger before insert, para que antes de insertar una nomina validar 
--que en el mes en que se está haciendo la nomina de un empleado no supere el 
--presupuesto de nomina de 12.000.000.
CREATE OR REPLACE FUNCTION validar_presupuesto_nomina()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    total_nomina_mes NUMERIC;
BEGIN
    -- Calcular el total de nomina del mes y año del nuevo registro
    SELECT SUM(total_neto) INTO total_nomina_mes
    FROM nomina
    WHERE EXTRACT(MONTH FROM fecha) = EXTRACT(MONTH FROM NEW.fecha)
    AND EXTRACT(YEAR FROM fecha) = EXTRACT(YEAR FROM NEW.fecha)
    AND usuario_id = NEW.usuario_id;

    -- Verificar si la suma supera el presupuesto permitido
    IF (total_nomina_mes + NEW.total_neto) > 12000000 THEN
        RAISE EXCEPTION 'El presupuesto de nómina para este mes ha sido superado.';
    END IF;

    RETURN NEW;
END;
$$;

-- Creación del Trigger
CREATE TRIGGER trg_validar_presupuesto_nomina
BEFORE INSERT ON nomina
FOR EACH ROW
EXECUTE FUNCTION validar_presupuesto_nomina();




-- Realizar un trigger after insert para que después de insertar una nueva nomina, 
--se agrege un registro a una tabla auditoria_nomina (fecha, nombre, identificación, total neto).
CREATE OR REPLACE FUNCTION auditar_nomina()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO auditoria_nomina(fecha, nombre, identificacion, total_neto)
    SELECT NOW(), e.nombre, e.identificacion, NEW.total_neto
    FROM empleado e
    WHERE e.identificacion = NEW.usuario_id;

    RETURN NEW;
END;
$$;

-- Creación del Trigger
CREATE TRIGGER trg_auditar_nomina
AFTER INSERT ON nomina
FOR EACH ROW
EXECUTE FUNCTION auditar_nomina();



-- Realizar un trigger before update para que antes de actualizar a un empleado en su salario 
--no supere el presupuesto de nomina de 12.000.000.
CREATE OR REPLACE FUNCTION validar_actualizacion_salario()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    total_salario NUMERIC;
BEGIN
    -- Sumar todos los salarios excepto el del empleado a actualizar
    SELECT SUM(salario) INTO total_salario
    FROM empleado
    WHERE identificacion != OLD.identificacion;

    -- Verificar si el nuevo salario no supera el presupuesto
    IF (total_salario + NEW.salario) > 12000000 THEN
        RAISE EXCEPTION 'El presupuesto de salarios ha sido superado.';
    END IF;

    RETURN NEW;
END;
$$;

-- Creación del Trigger
CREATE TRIGGER trg_validar_actualizacion_salario
BEFORE UPDATE OF salario ON empleado
FOR EACH ROW
EXECUTE FUNCTION validar_actualizacion_salario();


-- Realizar un trigger after update para que después de actualizar el salario de un empleado 
--guardar un registro en la tabla auditoria_empleado (fecha, nombre, identificación, concepto, valor), 
--donde concepto es si es un "AUMENTO" O "DISMINUCION" al salario y el dato es edl valor aumentado 
--o disminuido.
CREATE OR REPLACE FUNCTION auditar_actualizacion_empleado()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    concepto VARCHAR(20);
    diferencia NUMERIC;
BEGIN
    -- Determinar si es un aumento o disminución
    IF NEW.salario > OLD.salario THEN
        concepto := 'AUMENTO';
        diferencia := NEW.salario - OLD.salario;
    ELSE
        concepto := 'DISMINUCION';
        diferencia := OLD.salario - NEW.salario;
    END IF;

    -- Insertar en auditoria
    INSERT INTO auditoria_empleado(fecha, nombre, identificacion, concepto, valor)
    VALUES(NOW(), NEW.nombre, NEW.identificacion, concepto, diferencia);

    RETURN NEW;
END;
$$;

-- Creación del Trigger
CREATE TRIGGER trg_auditar_actualizacion_empleado
AFTER UPDATE OF salario ON empleado
FOR EACH ROW
EXECUTE FUNCTION auditar_actualizacion_empleado();



    identificacion INTEGER NOT NULL,
    concepto VARCHAR(20) NOT NULL,  -- "AUMENTO" o "DISMINUCION"
    valor NUMERIC(12, 2) NOT NULL
);

--  Realizar un trigger before insert, para que antes de insertar una nomina validar 
--que en el mes en que se está haciendo la nomina de un empleado no supere el 
--presupuesto de nomina de 12.000.000.
CREATE OR REPLACE FUNCTION validar_presupuesto_nomina()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    total_nomina_mes NUMERIC;
BEGIN
    -- Calcular el total de nomina del mes y año del nuevo registro
    SELECT SUM(total_neto) INTO total_nomina_mes
    FROM nomina
    WHERE EXTRACT(MONTH FROM fecha) = EXTRACT(MONTH FROM NEW.fecha)
    AND EXTRACT(YEAR FROM fecha) = EXTRACT(YEAR FROM NEW.fecha)
    AND usuario_id = NEW.usuario_id;

    -- Verificar si la suma supera el presupuesto permitido
    IF (total_nomina_mes + NEW.total_neto) > 12000000 THEN
        RAISE EXCEPTION 'El presupuesto de nómina para este mes ha sido superado.';
    END IF;

    RETURN NEW;
END;
$$;

-- Creación del Trigger
CREATE TRIGGER trg_validar_presupuesto_nomina
BEFORE INSERT ON nomina
FOR EACH ROW
EXECUTE FUNCTION validar_presupuesto_nomina();




-- Realizar un trigger after insert para que después de insertar una nueva nomina, 
--se agrege un registro a una tabla auditoria_nomina (fecha, nombre, identificación, total neto).
CREATE OR REPLACE FUNCTION auditar_nomina()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO auditoria_nomina(fecha, nombre, identificacion, total_neto)
    SELECT NOW(), e.nombre, e.identificacion, NEW.total_neto
    FROM empleado e
    WHERE e.identificacion = NEW.usuario_id;

    RETURN NEW;
END;
$$;

-- Creación del Trigger
CREATE TRIGGER trg_auditar_nomina
AFTER INSERT ON nomina
FOR EACH ROW
EXECUTE FUNCTION auditar_nomina();



-- Realizar un trigger before update para que antes de actualizar a un empleado en su salario 
--no supere el presupuesto de nomina de 12.000.000.
CREATE OR REPLACE FUNCTION validar_actualizacion_salario()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    total_salario NUMERIC;
BEGIN
    -- Sumar todos los salarios excepto el del empleado a actualizar
    SELECT SUM(salario) INTO total_salario
    FROM empleado
    WHERE identificacion != OLD.identificacion;

    -- Verificar si el nuevo salario no supera el presupuesto
    IF (total_salario + NEW.salario) > 12000000 THEN
        RAISE EXCEPTION 'El presupuesto de salarios ha sido superado.';
    END IF;

    RETURN NEW;
END;
$$;

-- Creación del Trigger
CREATE TRIGGER trg_validar_actualizacion_salario
BEFORE UPDATE OF salario ON empleado
FOR EACH ROW
EXECUTE FUNCTION validar_actualizacion_salario();



-- Realizar un trigger after update para que después de actualizar el salario de un empleado 
--guardar un registro en la tabla auditoria_empleado (fecha, nombre, identificación, concepto, valor), 
--donde concepto es si es un "AUMENTO" O "DISMINUCION" al salario y el dato es edl valor aumentado 
--o disminuido.
CREATE OR REPLACE FUNCTION auditar_actualizacion_empleado()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
    concepto VARCHAR(20);
    diferencia NUMERIC;
BEGIN
    -- Determinar si es un aumento o disminución
    IF NEW.salario > OLD.salario THEN
        concepto := 'AUMENTO';
        diferencia := NEW.salario - OLD.salario;
    ELSE
        concepto := 'DISMINUCION';
        diferencia := OLD.salario - NEW.salario;
    END IF;

    -- Insertar en auditoria
    INSERT INTO auditoria_empleado(fecha, nombre, identificacion, concepto, valor)
    VALUES(NOW(), NEW.nombre, NEW.identificacion, concepto, diferencia);

    RETURN NEW;
END;
$$;

-- Creación del Trigger
CREATE TRIGGER trg_auditar_actualizacion_empleado
AFTER UPDATE OF salario ON empleado
FOR EACH ROW
EXECUTE FUNCTION auditar_actualizacion_empleado();



-- PROBAR LOS TRIGGERS

INSERT INTO empleado (nombre, identificacion, edad, correo, salario)
VALUES 
('Juan Pérez', 123456, 30, 'juan.perez@email.com', 3000000),
('María García', 654321, 28, 'maria.garcia@email.com', 3500000),
('Carlos Martínez', 789123, 35, 'carlos.martinez@email.com', 2800000);

INSERT INTO nomina (fecha, total_ingresos, total_deducciones, total_neto, usuario_id)
VALUES 
('2024-01-01', 3000000, 500000, 2500000, 123456),
('2024-01-01', 3500000, 600000, 2900000, 654321),
('2024-01-01', 2800000, 400000, 2400000, 789123);

-- Intentar insertar una nómina que exceda el presupuesto
INSERT INTO nomina (fecha, total_ingresos, total_deducciones, total_neto, usuario_id)
VALUES ('2024-02-01', 10000000, 1000000, 9000000, 123456);  -- Esto debería ser rechazado si supera el presupuesto

-- Intentar aumentar el salario de un empleado
UPDATE empleado
SET salario = 7000000
WHERE identificacion = 654321;  -- Este aumento será auditado y registrado