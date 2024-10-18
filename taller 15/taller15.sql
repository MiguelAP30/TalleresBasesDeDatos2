CREATE TABLE libros (
    isbn VARCHAR(13) PRIMARY KEY,
    descripcion XML
);

CREATE OR REPLACE FUNCTION guardar_libro(p_isbn VARCHAR, p_titulo VARCHAR) 
RETURNS VOID AS $$
BEGIN
    INSERT INTO libros (isbn, descripcion)
    VALUES (p_isbn, 
            XMLPARSE(DOCUMENT '<libro><titulo>' || p_titulo || '</titulo></libro>'));
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION actualizar_libro(p_isbn VARCHAR, p_titulo VARCHAR) 
RETURNS VOID AS $$
BEGIN
    UPDATE libros
    SET descripcion = XMLPARSE(DOCUMENT '<libro><titulo>' || p_titulo || '</titulo></libro>')
    WHERE isbn = p_isbn;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION obtener_autor_libro_por_isbn(p_isbn VARCHAR) 
RETURNS TEXT AS $$
DECLARE
    autor TEXT;
BEGIN
    SELECT xpath('string(//autor)', descripcion)
    INTO autor
    FROM libros
    WHERE isbn = p_isbn;

    RETURN autor[1];
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION obtener_autor_libro_por_titulo(p_titulo VARCHAR) 
RETURNS TEXT AS $$
DECLARE
    autor TEXT;
BEGIN
    SELECT xpath('string(//autor)', descripcion)
    INTO autor
    FROM libros
    WHERE xpath('string(//titulo)', descripcion) = p_titulo;

    RETURN autor[1];
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION obtener_libros_por_anio(p_anio VARCHAR) 
RETURNS SETOF TEXT AS $$
BEGIN
    RETURN QUERY 
    SELECT xpath('string(//titulo)', descripcion)
    FROM libros
    WHERE xpath('string(//anio)', descripcion) = p_anio;
END;
$$ LANGUAGE plpgsql;