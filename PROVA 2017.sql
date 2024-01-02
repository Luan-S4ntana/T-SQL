USE TREINO

CREATE TABLE TB_LOCAL (
 id_local int not null primary key,
 cidade varchar(100) not null,
 estado char(2) not null
)
CREATE TABLE TB_HOTEL (
 id_hotel int not null primary key,
 nm_hotel varchar(100) not null,
 id_local int not null
)
ALTER TABLE TB_HOTEL ADD CONSTRAINT FK_HOTEL_LOCAL FOREIGN
KEY (id_local) REFERENCES TB_LOCAL (id_local)
CREATE TABLE TB_TIPO_QUARTO (
 id_tipo_quarto int not null primary key,
 nm_tipo_quarto varchar(10) check (nm_tipo_quarto in
 ('simples','duplo','triplo'))
)
CREATE TABLE TB_HOTEL_DIARIAS (
 id_diaria int not null primary key,
 id_hotel int not null,
 id_tipo_quarto int not null,
 valor_diaria numeric(10,2) not null,
 unique(id_hotel, id_tipo_quarto)
)
CREATE TABLE TB_HOTEL_DIARIAS_ESPECIAIS (
 id_hotel int not null,
 id_tipo_quarto int not null,
 mes int not null,
 valor_diaria numeric(10,2) not null,
 primary key (id_hotel, id_tipo_quarto, mes))
CREATE TABLE TB_HOTEIS_LOCALIZADOS (
 id_hotel int not null,
 nm_hotel varchar(100) not null,
 nm_tipo_quarto varchar(10) not null,
 data_entrada datetime not null,
 data_saida datetime not null,
 total_diarias int not null, -- número de diárias
 valor_total_diarias numeric(10,2)
)
CREATE PROCEDURE SP_LOCALIZAR_HOTEIS
    @id_local int,
    @id_tipo_quarto int,
    @dt_entrada datetime,
    @dt_saida datetime
AS
BEGIN
    DECLARE @total_diarias int
    DECLARE @valor_total_diarias numeric(10,2)

    INSERT INTO TB_HOTEIS_LOCALIZADOS (id_hotel, nm_hotel, nm_tipo_quarto, data_entrada, data_saida, total_diarias, valor_total_diarias)
    SELECT H.id_hotel, H.nm_hotel, TQ.nm_tipo_quarto, @dt_entrada, @dt_saida, DATEDIFF(day, @dt_entrada, @dt_saida) as total_diarias, 
           CASE WHEN E.valor_diaria IS NOT NULL THEN E.valor_diaria ELSE D.valor_diaria END * DATEDIFF(day, @dt_entrada, @dt_saida) as valor_total_diarias
    FROM TB_HOTEL H
    INNER JOIN TB_HOTEL_DIARIAS D ON H.id_hotel = D.id_hotel
    LEFT JOIN TB_HOTEL_DIARIAS_ESPECIAIS E
        ON D.id_hotel = E.id_hotel
        AND D.id_tipo_quarto = E.id_tipo_quarto
        AND MONTH(@dt_entrada) = E.mes
    INNER JOIN TB_TIPO_QUARTO TQ
        ON D.id_tipo_quarto = TQ.id_tipo_quarto
    WHERE @id_local = H.id_local AND @id_tipo_quarto = D.id_tipo_quarto
END
