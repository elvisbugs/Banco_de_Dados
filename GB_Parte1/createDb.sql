DROP DATABASE IF EXISTS MeLeva;
CREATE DATABASE MeLeva;
USE MeLeva;

/*------------TABLES-------------*/
drop table if exists Condutor;
create table Condutor(
    cpf_motorista varchar(11) primary key,
    nome_cond varchar(255) not null,
    telefone_cond varchar(9) not null UNIQUE,
    data_cadastro_cond TIMESTAMP not null,
    CHECK(CHAR_LENGTH(cpf_motorista) = 11),
    CHECK(CHAR_LENGTH(telefone_cond) = 9)
);
SELECT 'Criou Condutor' as '';

drop table if exists veiculo;
create table veiculo(
    renavam varchar(9) PRIMARY KEY,
    placa varchar(7) not null UNIQUE,
    marca varchar(255) not null,
    modelo varchar(255) not null,
    ano int(4),
    CHECK(CHAR_LENGTH(placa) = 7),
    CHECK(CHAR_LENGTH(renavam) = 9),
    CHECK(ano >= 1900)
);
SELECT 'Criou veiculo' as '';

drop table if exists motorista;
create table motorista(
    data_inicio_mot timestamp not null,
    data_fim_mot timestamp not null, 
    renavam varchar(9),
    cpf_motorista varchar(11) not null,
    id_motorista  int PRIMARY KEY auto_increment,
    CONSTRAINT DIRIGE FOREIGN KEY (cpf_motorista) REFERENCES Condutor(cpf_motorista) on update cascade,
    CONSTRAINT ALUGADO FOREIGN KEY (renavam) REFERENCES veiculo(renavam) on update cascade,
    UNIQUE(renavam, cpf_motorista, data_inicio_mot, data_fim_mot),
    check(timediff(data_fim_mot,data_inicio_mot) >= 0)
    
);
SELECT 'Criou motorista' as '';

drop table if exists passageiros;
create table passageiros(
    nome_pass varchar(255) not null,
    telefone_pass varchar(9) not null UNIQUE,
    data_cadastro_pass timestamp not null,
    cpf_passageiro varchar(11) PRIMARY KEY,
    CHECK(CHAR_LENGTH(telefone_pass) = 9)
    
);
SELECT 'Criou passageiros' as '';

drop table if exists corrida;
create table corrida(
    id_corrida integer auto_increment,
    avaliacao_condutor INT UNSIGNED,
    avaliacao_veiculo INT UNSIGNED,
    data_inicio_corr TIMESTAMP not null,
    data_fim_corr TIMESTAMP not null,
    origem varchar(255),
    destino varchar(255),
    tarifa real,
    distancia_km real UNSIGNED,
    id_motorista integer,
    cpf_passageiro varchar(11),
    PRIMARY KEY(id_corrida, id_motorista , cpf_passageiro),
    CONSTRAINT ACEITA FOREIGN KEY (id_motorista) REFERENCES motorista(id_motorista) on update cascade,
    CONSTRAINT SOLICITA FOREIGN KEY (cpf_passageiro) REFERENCES passageiros(cpf_passageiro) on update cascade,
    CHECK( avaliacao_condutor <= 5),
    CHECK( avaliacao_veiculo <= 5),
    check(timediff(data_fim_corr,data_inicio_corr) >= 0)
    
);
SELECT 'Criou corrida' as '';

/*------------VIEWS-------------*/
drop view if exists ResumoCorrida;
create view ResumoCorrida (
        cpf_motorista, 
        Nome_Motorista,
        cpf_passageiro,
        nome_passageiro, 
        origem, 
        destino, 
        distancia_km, 
        valor,
        horario_de_inicio, 
        tempo_de_duracao, 
        id_veiculo, 
        avaliacao_veiculo, 
        avaliacao_condutor) as

    select cpf_motorista, 
    nome_cond,
    cpf_passageiro,
    nome_pass,
    origem, 
    destino, 
    distancia_km,
    ROUND(((5 + distancia_km * 0.8 + ((TIME_TO_SEC(data_fim_corr) - TIME_TO_SEC(data_inicio_corr))/60)*0.2))*tarifa, 2) as valor,
    TIME(data_inicio_corr) as horario_de_inicio,
    DATE_FORMAT(timediff(data_fim_corr,data_inicio_corr),'%Hh:%imin') as tempo_de_duracao,
    renavam as id_veiculo,
    avaliacao_veiculo, 
    avaliacao_condutor
    from Corrida
    natural join motorista
    natural join Condutor
    natural join passageiros;  

drop view if exists ResumoCondutor;
create view ResumoCondutor 
    (Cpf_motorista,
     Nome_Motorista, 
     qtd_aval, 
     media_aval, 
     qtd_corrida, 
     salario) as

    select cpf_motorista, 
    Nome_Motorista, 
    count(avaliacao_condutor) as qtd_aval,
    round(avg(avaliacao_condutor), 2) as media_aval,
    count(cpf_motorista) as qtd_corrida,
    sum(ROUND(valor*0.1, 2)) as valor_receber
    
    from ResumoCorrida
    group by cpf_motorista;

drop view if exists ResumoVeiculo;
create view ResumoVeiculo 
    (renavam,
     placa,
     marca,
     modelo,
     ano,
     qtd_aval,
     qtd_corrida,
     media_aval) as
    
    select renavam,
    placa,
    marca,
    modelo,
    ano,
    count(avaliacao_veiculo) as qtd_aval,
    count(renavam) as qtd_corrida,
    avg(avaliacao_veiculo) as media_aval

    from corrida
    natural join motorista
    natural join veiculo
    group by renavam;

/*------------TRIGGERS-------------*/
source C:\Users\Elvis\Desktop\Banco_de_Dados\GB_Parte1\inserts.sql

/*CHECK(data_cadastro_cond <= now()) fazer numa trigger */

/*CHECK(data_inicio <= now()),
    CHECK(data_fim <= now()) trigger*/

/*CHECK(data_cadastro_pass <= now()) trigger*/

/*CHECK( data_inicio <= now()),
    CHECK( data_fim <= now()) trigger*/