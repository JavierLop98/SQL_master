-- JAVIER LOPEZ BAHON 30/03/2021

-- Se crea un database llamado corrupcion, donde se almacenará la información
drop database if exists corrupcion;
create database corrupcion;

-- ELIMINAR LAS TABLAS
DROP TABLE IF EXISTS implicado;
DROP TABLE IF EXISTS familiar;
DROP TABLE IF EXISTS descubierto;
DROP TABLE IF EXISTS web;

DROP TABLE IF EXISTS caso;
DROP TABLE IF EXISTS juez;
DROP TABLE IF EXISTS persona;
DROP TABLE IF EXISTS periodico;
DROP TABLE IF EXISTS telefono;
DROP TABLE IF EXISTS partido;

/*Tabla con datos de los jueces: 
Clave: codigo juez, que sería el DNI del juez.
*/
CREATE TABLE juez(
			CodJuez char(9),					-- DNI
            nombre_juez VARCHAR(20) NOT NULL,	-- NOMBRE
            direccion_juez VARCHAR(20),			-- DIRECCIÓN
            fecha_naci date,					-- FECHA NACIMIENTO
            fecha_com date,						-- FECHA EN QUE CONMIENZA A EJERCER COMO JUEZ
            numero_casos   SMALLINT DEFAULT 0,	-- NÚMERO DE CASOS DE CORRUPCIÓN QUE LLEVA Y HA LLEVADO (LA SUMA)
            PRIMARY KEY(CodJuez)
);

/*Tabla con datos de los partidos políticos: 
Clave: codigoPartido.
*/
CREATE TABLE partido(
			CodPartido char(4), 				-- KEY
            nombre_partido VARCHAR(20) NOT NULL,-- NOMBRE
            dirección_partido VARCHAR(20),		-- DIRECCION
            PRIMARY KEY(CodPartido)
);

/*
Tabla auxiliar a la de partido para incorporar los diferentes números de teléfono de cada partido
*/
  CREATE TABLE  telefono(
	CodPartido_telefono char(4),				-- KEY PARTIDO
   numTel VARCHAR(9),							-- NUMERO DE TELEFONO
   PRIMARY KEY (numTel),
   FOREIGN KEY (CodPartido_telefono) REFERENCES partido(CodPartido)
  ) ;

CREATE TABLE persona(
			DNI_persona char(9), 				-- DNI (KEY)
            cargo_principal VARCHAR(35), 		-- CARGO PRINCIPAL QUE EJERCE A DÍA DE HOY
            nombre_persona VARCHAR(20),			-- NOMBRE
            apellido_persona VARCHAR(20),		-- APELLIDOS
            dirección_persona VARCHAR(20),		-- DIRECCION
            patrimonio NUMERIC (12,0),			-- PATRIMONIO PERSONAL
            IdPartido_persona char(4) DEFAULT null,-- KEY DEL PARTIDO AL QUE PERTENECE
            FOREIGN KEY (IdPartido_persona) REFERENCES partido(CodPartido)
            ON DELETE CASCADE
			ON UPDATE CASCADE,
            cargo_persona VARCHAR(20) DEFAULT null,-- CARGO QUE TENÍA EN EL PARTIDO CUANDO PRESUNTAMENTE REALIZÓ EL DELITO
            PRIMARY KEY(DNI_persona)
);

/*La relación con la web se introduce dentro de la tabla, porque hoy en día la mayoría de periodicos tienen web y no habría a penas valores NULL
*/
CREATE TABLE periodico(
			CodPeriodico char(5),				-- KEY
			nombre_periodico VARCHAR(20),		-- NOMBRE PERIODICO
            dirección_periodico VARCHAR(20),	-- DIRECCIÓN
            tipo ENUM('papel', 'digital') DEFAULT 'digital', -- TIPO DE PERIÓDICO, PAPEL O DIGITAL, POR DEFECTO DIGITAL
            ambito_periodico ENUM('local', 'comarcal', 'nacional', 'internacional') DEFAULT 'nacional',-- AMBITO EN EL QUE ACTÚA EL PERIÓDICO
            IdPartido_periodico char(4),		-- KEY DEL PARTIDO AL QUE EL PERIÓDICO APOYA
            web_periodico varchar(20) DEFAULT NULL,-- WEB DEL PERIÓDICO
            FOREIGN KEY (IdPartido_periodico) REFERENCES partido(CodPartido)
            ON DELETE CASCADE
			ON UPDATE CASCADE,
            PRIMARY KEY(CodPeriodico)
);

CREATE TABLE caso(
			CodCaso char(9),					-- KEY
            nombre_caso VARCHAR(20),			-- NOMBRE DEL CASO
            descripcion_caso VARCHAR(65),		-- BREVE DESCRIPCIÓN DEL CASO
            dinero_caso NUMERIC (15,0),			-- DINERO PRESUNTAMENTE ROBADO EN EL CASO DE CORRUPCIÓN
            ambito_caso  VARCHAR(20),			-- AMBITO DEL CASO, LOCAL, NACIONAL...
            IdJuez_caso char(9),				-- KEY DEL JUEZ QUE LLEVA EL CASO
            IdPeriodico_caso char(5) DEFAULT NULL,-- KEY DEL PERIODICO QUE DIO A LA LUZ POR PRIMERA VEZ EL CASO
            fecha_caso date DEFAULT NULL,		-- FECHA EN LA QUE EL PERIODICO PUBLICÓ LA NOTICIA
            dictamen varchar(20) default 'Abierto',-- DICTAMEN SOBRE EL CASO, POR DEFECTO EL CASO SEGUIRÁ ABIERTO
            FOREIGN KEY (IdJuez_caso) REFERENCES juez(CodJuez) ON DELETE CASCADE ON UPDATE CASCADE,
            FOREIGN KEY (IdPeriodico_caso) REFERENCES periodico(CodPeriodico) ON DELETE CASCADE ON UPDATE CASCADE,
			PRIMARY KEY(CodCaso)
);

CREATE TABLE implicado(							-- RELACIONA LOS CASOS CON LAS PERSONAS IMPLICADAS
			IdCaso_implicado char(9),			-- KEY DEL CASO
            dni_implicado char(9),				-- KEY DE PERSONA
			FOREIGN KEY (IdCaso_implicado) REFERENCES caso(CodCaso),
            FOREIGN KEY (dni_implicado) REFERENCES persona(DNI_persona),
            PRIMARY KEY(IdCaso_implicado,dni_implicado)
);

CREATE TABLE familiar(
			dni_aparentado_familiar char(9),	-- DNI (KEY) DE LA PERSONA SOBRE LA QUE SE APLICA EL PARENTESCO
            dni_familiar char(9),				-- DNI (KEY) DEL "APARENTADO"
			FOREIGN KEY (dni_familiar) REFERENCES persona(DNI_persona),
			parentesco VARCHAR(20),				-- PARENTESCO ENTRE LAS DOS PERSONAS
            PRIMARY KEY(dni_familiar,dni_aparentado_familiar)
);

-- TRIGGER QUE SUMA UNO AL NÚMERO DE CASOS LLEVADOS POR UN JUEZ CADA VEZ QUE SE LE INCORPORA UN CASO NUEVO
-- drop trigger SumaCasosJuez;
CREATE TRIGGER SumaCasosJuez
AFTER INSERT ON caso
FOR EACH ROW
UPDATE juez
SET numero_casos = numero_casos + 1
WHERE CodJuez  = new.IdJuez_caso ;

-- SE INSERTAN LOS VALORES PARA COMPROBAR EL FUNCIONAMIENTO:

INSERT INTO juez(CodJuez, nombre_juez, direccion_juez, fecha_naci, fecha_com) VALUES ('11111111A', 'Angela', 'C/ Juana la Loca', '1969-7-04', '2008-7-04');
INSERT INTO juez(CodJuez, nombre_juez, direccion_juez, fecha_naci, fecha_com) VALUES ('22222222B', 'Luis Miguel', 'C/ A donde vas', '1975-7-04', '2012-7-04');
INSERT INTO juez(CodJuez, nombre_juez, direccion_juez, fecha_naci, fecha_com) VALUES ('33333333C', 'María', 'C/ Maria vive aqui', '1962-7-04', '2020-7-04');

INSERT INTO partido VALUES ('1234', 'PSOE', 'C/ El robo');
INSERT INTO partido VALUES ('4321', 'PNV', 'C/ Borroca');

INSERT INTO telefono VALUES ('1234','947564821');
INSERT INTO telefono VALUES ('1234','987465183');
INSERT INTO telefono VALUES ('4321','123456789');
INSERT INTO telefono VALUES ('4321','987654321');

INSERT INTO persona VALUES ('12345678A','Ministro de San Queremos', 'Pedrito', 'Picapiedra', 'C/ el progre', '90000000', '1234', 'Becario');
INSERT INTO persona VALUES ('87654321A','Director general de Movilidad', 'Rafael','Chacon', 'C/ Arles', '30000', '1234', 'Concejal Guadalajara');
INSERT INTO persona VALUES ('12222222B','Directora general de Mayores', 'Miriam','Burgos', 'C/ Isar', '20000', '1234', 'Concejal Guadalajara');
INSERT INTO persona VALUES ('22222111A','Diputado nacional', 'Antonio','Limones', 'C/ Del toro', '50000', '1234', 'Alcalde');
INSERT INTO persona VALUES ('66666666A','Comision Ejecutiva', 'M. Camio', 'Uranga','C/ La cueva', '50000', '4321', 'D. Turismo');
INSERT INTO persona VALUES ('55555555A','Arquitecto', 'Julian','Argilagos', 'C/ Badulake', '50000', null, null);

INSERT INTO periodico VALUES ('12345', 'La Razon', 'Plaza España', 'papel', 'nacional','1234','larazon.es');
INSERT INTO periodico VALUES ('54321', 'El Mundo', 'Plaza Mayor', 'digital', 'nacional','1234','elmundo.es');

INSERT INTO caso(CodCaso, nombre_caso,descripcion_caso,dinero_caso,ambito_caso,IdJuez_caso,IdPeriodico_caso,fecha_caso)
VALUES ('44444444D', 'ERE', 'Mucha mano suelta', 444444, 'Nacional','11111111A','12345', '2020-7-04');
INSERT INTO caso(CodCaso, nombre_caso,descripcion_caso,dinero_caso,ambito_caso,IdJuez_caso,IdPeriodico_caso,fecha_caso)
VALUES ('55555555E', 'AVE', 'Todo va rápido menos la obra', 333333, 'Nacional','22222222B','12345','2015-12-05');
INSERT INTO caso(CodCaso, nombre_caso,descripcion_caso,dinero_caso,ambito_caso,IdJuez_caso,IdPeriodico_caso,fecha_caso)
VALUES ('66666666F', 'Astapa', 'Dinero llama dinero', 2000000, 'Local','33333333C','12345','2005-3-22');
INSERT INTO caso(CodCaso, nombre_caso,descripcion_caso,dinero_caso,ambito_caso,IdJuez_caso,IdPeriodico_caso,fecha_caso)
VALUES ('77777777F', 'ACM', 'Consiente un saqueo a las arcas publicas', 222222, 'Comarcal','33333333C','54321','2018-4-19');
INSERT INTO caso(CodCaso, nombre_caso,descripcion_caso,dinero_caso,ambito_caso,IdJuez_caso,IdPeriodico_caso,fecha_caso,dictamen)
VALUES ('88888888X', 'Balenciaga', 'Comisiones por construcción', 111111, 'Comarcal','33333333C','12345','2002-10-12','Culpables');

INSERT INTO implicado VALUES ('77777777F','87654321A');
INSERT INTO implicado VALUES ('77777777F','12222222B');
INSERT INTO implicado VALUES ('77777777F','22222111A');
INSERT INTO implicado VALUES ('88888888X','66666666A');
INSERT INTO implicado VALUES ('88888888X','55555555A');
INSERT INTO implicado VALUES ('55555555E','12345678A');
INSERT INTO implicado VALUES ('44444444D','87654321A');

INSERT INTO familiar VALUES ('55555555A','66666666A','primo');
INSERT INTO familiar VALUES ('66666666A','55555555A','primo');

-- DIFERENTES SELECT PARA VER LAS TABLAS:
	     Select * from juez;
         Select * from caso;
         Select * from partido;
         Select * from persona;
         Select * from periodico;
         select * from implicado;
         select * from familiar;
         select * from telefono;
         
-- 1º Casos donde se han robado más de 1.000.000 €
	-- CON UN WHERE FILTRAMOS LAS FILAS QUE TENGAN MÁS DE 1.000.000 EN LA COLUMNA DINERO_CASO
select nombre_caso as caso_mas_1_mill from caso where dinero_caso > 1000000;

-- 2º Tabla con los casos y el juez que lo lleva
select nombre_caso as caso, nombre_juez as juez from juez inner join caso on juez.CodJuez=caso.IdJuez_caso ;

--  3º Personas implicadas en un caso, Balenciaga
select nombre_persona, DNI_persona as DNI,  cargo_principal as Cargo, nombre_partido as Partido
from partido right join (select nombre_caso, DNI_persona, nombre_persona, patrimonio, cargo_principal, IdPartido_persona
from persona inner join (	select nombre_caso, dni_implicado from caso inner join implicado  on caso.CodCaso=implicado.IdCaso_implicado) as A on persona.DNI_persona = A.dni_implicado) as B on partido.CodPartido = B.IdPartido_persona
where nombre_caso  = 'Balenciaga';

-- 4º Casos ordenados por dinero robado
select nombre_caso as caso, dinero_caso as robado from caso order by dinero_caso desc;

-- 5º Persona y partido al que pertenece
select concat(nombre_persona, ' ', apellido_persona, ' ') as Politico,  nombre_partido  from persona inner join partido on persona.IdPartido_persona=partido.CodPartido;

-- 6º Defraudado por partido
select sum(distinct(dinero_caso)) as Defraudado, nombre_partido as Partido
	from partido right join 
		(select nombre_caso, DNI_persona, cargo_principal, IdPartido_persona, dinero_caso
		from persona inner join 
			(select nombre_caso, dni_implicado, dinero_caso from caso inner join implicado on caso.CodCaso=implicado.IdCaso_implicado)
			as A on persona.DNI_persona = A.dni_implicado) as B 
	on partido.CodPartido = B.IdPartido_persona
    group by nombre_partido
	having nombre_partido is not null
	order by defraudado desc;

-- 7º Numero de casos
select distinct count(*) as NºCasos from caso;

-- 8º Media de dinero estafado
select avg(dinero_caso) as Media_estafado from caso;

-- 9º Nº implicados por caso
select count(dni_implicado) as Implicados, nombre_caso as Caso from implicado inner join caso on implicado.IdCaso_implicado  = caso.CodCaso group by nombre_caso order by implicados desc;

-- 10º Contacto con partido político, teléfonos de los partidos políticos
select nombre_partido as Partido, numTel as Tel from partido as p inner join telefono as t on t.CodPartido_telefono = p.CodPartido
order by nombre_partido;

-- 11º Tabla de casos, con DNI implicados
select nombre_caso, dni_implicado
	from caso inner join implicado  on caso.CodCaso=implicado.IdCaso_implicado 
	order by nombre_caso;
    
-- 11.2º Casos ordenados por orden alfabético, con los datos de los implicados
select nombre_caso as Caso, DNI_persona as DNI, nombre_persona as nombre, patrimonio, cargo_principal as cargo, IdPartido_persona
from persona inner join (	select nombre_caso, dni_implicado from caso inner join implicado  on caso.CodCaso=implicado.IdCaso_implicado) as A on persona.DNI_persona = A.dni_implicado
order by nombre_caso;

-- 11.3º Tabla ordenada por partidos políticos, con los casos y datos de los implicados en dicho caso.
select nombre_partido as Partido, nombre_caso as Caso, DNI_persona as DNI, nombre_persona as Persona, patrimonio, cargo_principal as Cargo
from partido right join (select nombre_caso, DNI_persona, nombre_persona, patrimonio, cargo_principal, IdPartido_persona
from persona inner join (	select nombre_caso, dni_implicado from caso inner join implicado  on caso.CodCaso=implicado.IdCaso_implicado) as A on persona.DNI_persona = A.dni_implicado) as B on partido.CodPartido = B.IdPartido_persona
having nombre_partido is not null
order by nombre_partido;

-- 12º Casos de un partido en concreto: PSOE
select nombre_caso as caso, DNI_persona as DNI, nombre_persona as implicado, patrimonio, cargo_principal as cargo, nombre_partido as partido
from partido right join (select nombre_caso, DNI_persona, nombre_persona, patrimonio, cargo_principal, IdPartido_persona
from persona inner join (	select nombre_caso, dni_implicado from caso inner join implicado  on caso.CodCaso=implicado.IdCaso_implicado) as A on persona.DNI_persona = A.dni_implicado) as B on partido.CodPartido = B.IdPartido_persona
having partido = 'PSOE';

-- 13º Dinero defraudado por el un partido en concreto: PSOE
select nombre_partido as partido, dinero_caso
	from partido right join (select IdPartido_persona, dinero_caso
	from persona inner join (	select nombre_caso, dni_implicado, dinero_caso from caso inner join implicado  on caso.CodCaso=implicado.IdCaso_implicado) as A on persona.DNI_persona = A.dni_implicado) as B on partido.CodPartido = B.IdPartido_persona
	group by partido
    having partido = 'PSOE';

-- 14º  Periódicos ordenados por el Nº de casos que publican la primicia.
select nombre_periodico as Periodico,count(nombre_caso) as Publicaciones from caso inner join periodico on periodico.CodPeriodico = caso.IdPeriodico_caso
group by nombre_periodico;

-- Vista, muestra los periódicos y el partido al que están afiliados
-- drop VIEW afiliciacion_periodico;
CREATE VIEW afiliciacion_periodico(partido, periodico,  web ) as 
select nombre_periodico , nombre_partido, web_periodico  from partido as par inner join periodico as per on par.CodPartido  = per.IdPartido_periodico 
order by nombre_partido;

select * from afiliciacion_periodico;
