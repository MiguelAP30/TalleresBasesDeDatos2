create table clientes(
identificacion serial primary key,
nombre varchar(20) not null,
email varchar(64) not null,
direccion varchar(50) not null,
telefono varchar(50)not null
);

create type estado as enum('PAGO','NOPAGO','PENDIENTE');

create table servicios(
codigo serial primary key,
tipo varchar(20) not null,
monto numeric not null,
intereses numeric not null,
valor_total numeric not null,
estado_servicios estado not null,
cliente_id integer,
foreign key(cliente_id) references clientes(identificacion)
);

create table pagos(
codigo serial primary key,
fecha_pago date not null,
total numeric,
servicio_id integer,
foreign key(servicio_id) references servicios(codigo)
);

--PARTE 1

--crear clientes
CREATE OR REPLACE PROCEDURE generar_bd()
LANGUAGE plpgsql
AS $$
DECLARE 
    v_clientes INTEGER := 1;
    v_monto_dato INTEGER := 100;
    v_monto NUMERIC;
    v_intereses NUMERIC;
    v_dato NUMERIC := 0.5;
    v_valor_total NUMERIC;
    i INT;
    v_cliente_id INTEGER;
	v_servicios_id INTEGER;
BEGIN
    WHILE v_clientes <= 50 LOOP
        INSERT INTO clientes(nombre, email, direccion, telefono)
		VALUES('Miguel' || v_clientes, v_clientes || '@gmail.com', 'calle' || v_clientes, '304' || v_clientes)
        RETURNING identificacion INTO v_cliente_id;

        v_clientes := v_clientes + 1;

        FOR i IN 1..3 LOOP
            v_monto := v_monto_dato * i;
            v_intereses := v_monto * v_dato;
            v_valor_total := v_monto + v_intereses;

            INSERT INTO servicios(tipo, monto, intereses, valor_total, estado_servicios, cliente_id)
			VALUES('agua' || v_monto_dato, v_monto, v_intereses, v_valor_total, 'NOPAGO', v_cliente_id)
			RETURNING codigo INTO v_servicios_id;

			INSERT INTO pagos(fecha_pago, total, servicio_id)
            VALUES(CURRENT_DATE, v_valor_total, v_servicios_id);
            v_monto := 0;
            v_intereses := 0;
            v_valor_total := 0;
        END LOOP;
    END LOOP;
    RAISE NOTICE 'Se crearon 50 clientes y sus servicios asociados y sus pagos';
END;
$$;

CALL generar_bd();

--PARTE 2

CREATE OR REPLACE FUNCTION transacciones_total_mes(
	p_mes DATE,
	p_cliente_id INTEGER)
RETURNS NUMERIC AS 
$$
	DECLARE
		v_total NUMERIC := 0;
		v_total_mes NUMERIC := 0;
		v_servicio_id INTEGER;
		v_total_servicio NUMERIC;
		v_fecha_pago DATE;
		v_mes DATE;
	BEGIN
		FOR v_servicio_id IN SELECT codigo FROM servicios WHERE cliente_id = p_cliente_id LOOP
			SELECT total, fecha_pago INTO v_total_servicio, v_fecha_pago FROM pagos WHERE servicio_id = v_servicio_id;
			v_mes := date_trunc('month', v_fecha_pago);
			IF v_mes = p_mes THEN
				v_total_mes := v_total_mes + v_total_servicio;
			END IF;
		END LOOP;
		RETURN v_total_mes;
	END;
$$
LANGUAGE plpgsql;

SELECT transacciones_total_mes('2024-09-01', 11);

