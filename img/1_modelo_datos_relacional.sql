--- Crear Tablas ---

-- DROP TABLE public.clientes;
CREATE TABLE public.clientes (
	id varchar NOT NULL,
	nombre varchar NOT NULL,
	email varchar NOT NULL,
	direccion varchar NOT NULL,
	CONSTRAINT clientes_pk PRIMARY KEY (id)
);

-- DROP TABLE public.libros;
CREATE TABLE public.libros (
	id varchar NOT NULL,
	titulo varchar NOT NULL,
	autor varchar NOT NULL,
	isbn varchar NOT NULL,
	precio int8 NOT NULL,
	CONSTRAINT libros_pk PRIMARY KEY (id)
);

-- DROP TABLE public.pedidos;
CREATE TABLE public.pedidos (
	id varchar NOT NULL,
	id_cliente varchar NOT NULL,
	fecha date NOT NULL,
	CONSTRAINT pedidos_pk PRIMARY KEY (id),
	CONSTRAINT pedidos_clientes_fk FOREIGN KEY (id_cliente) REFERENCES public.clientes(id)
);

-- DROP TABLE public.detalle_pedidos;
CREATE TABLE public.detalle_pedidos (
	id_pedido varchar NOT NULL,
	id_libro varchar NOT NULL,
	cantidad int8 NOT NULL,
	CONSTRAINT detalle_pedidos_pk PRIMARY KEY (id_pedido, id_libro),
    CONSTRAINT detalle_pedidos_pedidos_fk FOREIGN KEY (id_pedido) REFERENCES public.pedidos(id),
	CONSTRAINT detalle_pedidos_libros_fk FOREIGN KEY (id_libro) REFERENCES public.libros(id)
);

-- DROP TABLE public.resenias;
CREATE TABLE public.resenias (
	id varchar NOT NULL,
	id_libro varchar NOT NULL,
	id_cliente varchar NOT NULL,
	texto_resenia varchar NOT NULL,
	calificacion int4 NOT NULL,
	CONSTRAINT resenias_pk PRIMARY KEY (id),
	CONSTRAINT resenias_libros_fk FOREIGN KEY (id_libro) REFERENCES public.libros(id),
    CONSTRAINT resenias_clientes_fk FOREIGN KEY (id_cliente) REFERENCES public.clientes(id)
);


--- Poblar Tablas ---

-- Poblar tabla clientes
INSERT INTO public.clientes (id, nombre, email, direccion) VALUES
('C001', 'Ana Ruiz', 'ana.ruiz@mail.com', '123 Avenida Ficticia'),
('C002', 'Luis Martínez', 'luis.mtz@mail.com', '456 Avenida Inventada'),
('C003', 'Maria López', 'maria.lopez@mail.com', '789 Camino Sintético'),
('C004', 'Sara Conde', 'sara.conde@mail.com', '1010 Boulevard Imaginario'),
('C005', 'Carlos Esteban', 'carlos.esteban@mail.com', '2020 Calle del Olvido'),
('C006', 'Lucía Fernández', 'lucia.fernandez@mail.com', '3030 Avenida de la Luz');

-- Poblar tabla libros
INSERT INTO public.libros (id, titulo, autor, isbn, precio) VALUES
('L001', 'El Principito', 'Antoine de Saint-Exupéry', '978-3-16-148410-0', 20990),
('L002', '1984', 'George Orwell', '978-3-16-148411-7', 15990),
('L003', 'Cien años de soledad', 'Gabriel García Márquez', '978-3-16-148412-4', 25490),
('L004', 'La sombra del viento', 'Carlos Ruiz Zafón', '978-3-16-148413-1', 30000),
('L005', 'El juego del ángel', 'Carlos Ruiz Zafón', '978-3-16-148414-8', 30490),
('L006', 'El laberinto de los espíritus', 'Carlos Ruiz Zafón', '978-3-16-148415-5', 35990);

-- Poblar tabla pedidos
INSERT INTO public.pedidos (id, id_cliente, fecha) VALUES
('P001', 'C001', '2024-05-05'),
('P002', 'C002', '2024-05-06'),
('P003', 'C003', '2024-05-07'),
('P004', 'C004', '2024-05-08'),
('P005', 'C005', '2024-05-09');

-- Poblar tabla detalle_pedidos
INSERT INTO public.detalle_pedidos (id_pedido, id_libro, cantidad) VALUES
('P001', 'L001', 1),
('P001', 'L003', 2),
('P002', 'L002', 1),
('P003', 'L004', 1),
('P003', 'L005', 1),
('P004', 'L001', 1),
('P005', 'L006', 2);

-- Poblar tabla resenias
INSERT INTO public.resenias (id, id_libro, id_cliente, texto_resenia, calificacion) VALUES
('R001', 'L001', 'C003', 'Encantadora y profunda historia para todas las edades.', 5),
('R002', 'L002', 'C001', 'Un clásico distópico imprescindible.', 4),
('R003', 'L004', 'C004', 'Un misterio absorbente ambientado en la Barcelona de posguerra.', 5),
('R004', 'L005', 'C005', 'Continuación fascinante de la saga del Cementerio de los Libros Olvidados.', 4);


--- Consultar Tablas ---

--- Detalle de Pedidos con Información de Clientes y Libros
SELECT 
    clientes.nombre AS cliente,
    libros.titulo AS libro,
    pedidos.fecha AS fecha_pedido,
    detalle_pedidos.cantidad AS cantidad
FROM 
    detalle_pedidos
JOIN 
    pedidos ON detalle_pedidos.id_pedido = pedidos.id
JOIN 
    clientes ON pedidos.id_cliente = clientes.id
JOIN 
    libros ON detalle_pedidos.id_libro = libros.id
WHERE 
    clientes.nombre = 'Ana Ruiz';

--- Análisis de Reseñas y Calificaciones de Libros
SELECT 
    libros.titulo,
    AVG(resenias.calificacion) AS calificacion_promedio,
    COUNT(resenias.id) AS total_resenas
FROM 
    libros
JOIN 
    resenias ON libros.id = resenias.id_libro
GROUP BY 
    libros.titulo
ORDER BY 
    calificacion_promedio DESC, total_resenas DESC;


--- Transacción ACID ---

/*
Este ejemplo utiliza las tablas pedidos, detalle_pedidos, y clientes para demostrar una transacción que incluye
varias inserciones y una actualización. La transacción asegura que todas las operaciones se ejecuten juntas como
una sola unidad de trabajo y que, en caso de cualquier fallo, los cambios no se apliquen, manteniendo la integridad
de los datos.
*/

-- Iniciar la transacción COMMIT
BEGIN;

-- Insertar un nuevo pedido
INSERT INTO public.pedidos (id, id_cliente, fecha) VALUES ('P006', 'C002', CURRENT_DATE);

-- Insertar detalles del nuevo pedido
INSERT INTO public.detalle_pedidos (id_pedido, id_libro, cantidad) VALUES ('P006', 'L001', 1), ('P006', 'L003', 2);

-- Actualizar la dirección del cliente
UPDATE public.clientes SET direccion = '111 Nueva Dirección' WHERE id = 'C002';

-- Finalizar la transacción confirmando los cambios
COMMIT;

/*
Para verificar que la transacción se llevó a cabo satisfactoriamente, la siguiente consulta reune información relevante
sobre el pedido insertado, los detalles del pedido, y la actualización de la dirección del cliente. Asegurando que todos
los elementos de la transacción se reflejen correctamente en la base de datos.
*/

SELECT
    ped.id AS pedido_id,
    ped.fecha AS fecha_pedido,
    cli.nombre AS cliente_nombre,
    cli.direccion AS cliente_direccion_actualizada,
    det.id_libro,
    det.cantidad,
    lib.titulo AS libro_titulo,
    lib.precio AS libro_precio
FROM
    public.pedidos ped
JOIN
    public.detalle_pedidos det ON ped.id = det.id_pedido
JOIN
    public.libros lib ON det.id_libro = lib.id
JOIN
    public.clientes cli ON ped.id_cliente = cli.id
WHERE
    ped.id = 'P006';  -- Asegurar que se está usando el ID correcto del pedido

-- Iniciar la transacción ROLLBACK
BEGIN;

-- Insertar un nuevo pedido
INSERT INTO public.pedidos (id, id_cliente, fecha) VALUES ('P007', 'C001', CURRENT_DATE);

-- Insertar detalles del nuevo pedido
INSERT INTO public.detalle_pedidos (id_pedido, id_libro, cantidad) VALUES ('P007', 'L001', 1), ('P007', 'L003', 2);

-- Actualizar la dirección del cliente
UPDATE public.clientes SET direccion = '222 Nueva Dirección' WHERE id = 'C001';

-- Finalizar la transacción descartando los cambios
ROLLBACK;

-- Verificar la transacción ROLLBACK
SELECT
    ped.id AS pedido_id,
    ped.fecha AS fecha_pedido,
    cli.nombre AS cliente_nombre,
    cli.direccion AS cliente_direccion_actualizada,
    det.id_libro,
    det.cantidad,
    lib.titulo AS libro_titulo,
    lib.precio AS libro_precio
FROM
    public.pedidos ped
JOIN
    public.detalle_pedidos det ON ped.id = det.id_pedido
JOIN
    public.libros lib ON det.id_libro = lib.id
JOIN
    public.clientes cli ON ped.id_cliente = cli.id
WHERE
    ped.id = 'P007';  -- Asegurar que se está usando el ID correcto del pedido
