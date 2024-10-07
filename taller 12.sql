-- TALLER 12 CURSORES 

CREATE TABLE envios(
    id serial PRIMARY KEY,
    fecha_envio DATE NOT NULL,
    destino VARCHAR(60) NOT NULL,
    observacion VARCHAR(100),
    estado VARCHAR(10) CHECK (estado IN ('PENDIENTE', 'EN_RUTA', 'ENTREGADO'))
);

-- crear procedimiento poblar_envios
CREATE OR REPLACE PROCEDURE poblar_envios()
LANGUAGE plpgsql
AS $$
DECLARE
    v_destino VARCHAR(60);
    v_fecha_envio DATE := CURRENT_DATE;
BEGIN
    FOR i IN 1..50 LOOP
        v_destino := 'Destino ' || i;

        INSERT INTO envios(fecha_envio, destino, observacion, estado)
        VALUES(v_fecha_envio, v_destino, NULL, 'PENDIENTE');
    END LOOP;
END;
$$;

-- crear procedimiento/funcion primera_fase_envio
-- crear un cursor para recorrer todos los envios pendientes
-- por cada pedido agregar la observacion de "primera etapa de envio"
-- actualizar el estado de cada envio pendiente a "en ruta"
CREATE OR REPLACE PROCEDURE primera_fase_envio()
LANGUAGE plpgsql
AS $$
DECLARE
    envio_cursor CURSOR FOR SELECT id FROM envios WHERE estado = 'PENDIENTE';
    v_id envios.id%TYPE;
BEGIN
    OPEN envio_cursor;

    LOOP
        FETCH envio_cursor INTO v_id;
        EXIT WHEN NOT FOUND;

        -- Actualizar la observación
        UPDATE envios
        SET observacion = 'Primera etapa de envío', estado = 'EN_RUTA'
        WHERE id = v_id;

        RAISE NOTICE 'Actualizado envio id: %', v_id;
    END LOOP;

    CLOSE envio_cursor;
END;
$$;

-- crear procedimiento ultima_fase_envio
-- crear un cursor para actualizar los envios que estén "en ruta" a "entregado" los envios que tengan mas de 5 dias en estado "en ruta"
-- modificar la observacion por "envio realizado con exito"
CREATE OR REPLACE PROCEDURE ultima_fase_envio()
LANGUAGE plpgsql
AS $$
DECLARE
    envio_cursor CURSOR FOR SELECT id FROM envios WHERE estado = 'EN_RUTA';
    v_id envios.id%TYPE;
BEGIN
    OPEN envio_cursor;

    LOOP
        FETCH envio_cursor INTO v_id;
        EXIT WHEN NOT FOUND;

        UPDATE envios
        SET observacion = 'Envío realizado con éxito', estado = 'ENTREGADO'
        WHERE id = v_id;

        RAISE NOTICE 'Actualizado envio id: %', v_id;
    END LOOP;

    CLOSE envio_cursor;
END;
$$;

-- Llamar a los procedimientos
CALL poblar_envios();          
CALL primera_fase_envio();    
CALL ultima_fase_envio(); 


