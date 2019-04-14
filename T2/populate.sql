-- type creation
create or replace type zona_t as object(
    codigo number(6),
    nome varchar2(50)
) not final;

create or replace type participacao_t as object(
    inscritos number(10),
    votantes number(10),
    abstencoes number(10),
    brancos number(10),
    nulos number(10)
);

create or replace type distrito_t under zona_t (
    regiao varchar2(1),
    participacao participacao_t
);

create or replace type concelho_t under zona_t (
    distrito ref distrito_t
);

create or replace type freguesia_t under zona_t (
    concelho ref concelho_t
);

create or replace type partido_t as object (
    sigla varchar2(10),
    designacao varchar2(100)
);

create or replace type lista_t as object (
    distrito ref distrito_t,
    partido ref partido_t,
    mandatos number(3)
);

create or replace type votacao_t as object (
    freguesia ref freguesia_t,
    partido ref partido_t,
    votos number(10)
);

create or replace type freguesia_tab_t as table of ref freguesia_t;
create or replace type concelho_tab_t as table of ref concelho_t;
create or replace type lista_tab_t as table of ref lista_t;
create or replace type votacao_tab_t as table of ref votacao_t;

alter type distrito_t add attribute (listas lista_tab_t, concelhos concelho_tab_t) cascade;
alter type concelho_t add attribute (freguesias freguesia_tab_t) cascade;
alter type freguesia_t add attribute (votacoes votacao_tab_t) cascade;
alter type partido_t add attribute (listas lista_tab_t, votacoes votacao_tab_t) cascade;

-- table creation
create table distrito of distrito_t
    nested table listas store as d_listas_tab
    nested table concelhos store as concelhos_tab;

create table concelho of concelho_t
    nested table freguesias store as freguesias_tab;

create table freguesia of freguesia_t
    nested table votacoes store as f_votacoes_tab;

create table partido of partido_t
    nested table listas store as p_listas_tab
    nested table votacoes store as p_votacoes_tab;

create table lista of lista_t;

create table votacao of votacao_t;

-- populate database

insert into partido (sigla, designacao)
select *
from gtd7.partidos;

insert into distrito (codigo, nome, regiao, participacao)
select d.*, participacao_t(p.inscritos, p.votantes, p.abstencoes, p.brancos, p.nulos)
from gtd7.distritos d 
inner join gtd7.participacoes p on d.codigo = p.distrito;

insert into concelho (codigo, nome, distrito)
select c.codigo, c.nome, ref(d)
from gtd7.concelhos c 
inner join distrito d on c.distrito = d.codigo;

insert into freguesia (codigo, nome, concelho)
select f.codigo, f.nome, ref(c)
from gtd7.freguesias f
inner join concelho c on f.concelho = c.codigo;

insert into lista (distrito, partido, mandatos)
select ref(d), ref(p), l.mandatos
from distrito d
inner join gtd7.listas l on d.codigo = l.distrito
inner join partido p on l.partido = p.sigla;

insert into votacao (freguesia, partido, votos)
select ref(f), ref(p), v.votos
from freguesia f
inner join gtd7.votacoes v on f.codigo = v.freguesia
inner join partido p on v.partido = p.sigla;

-- atualizacoes (devido a referencias circulares)
update distrito d
set d.concelhos = cast(multiset(select ref(c) from concelho c where c.distrito.codigo = d.codigo) as concelho_tab_t),
d.listas = cast(multiset(select ref(l) from lista l where l.distrito.codigo = d.codigo) as lista_tab_t);

update partido p
set p.votacoes = cast(multiset(select ref(v) from votacao v where v.partido.sigla = p.sigla) as votacao_tab_t),
p.listas = cast(multiset(select ref(l) from lista l where l.partido.sigla = p.sigla) as lista_tab_t);

update concelho c
set c.freguesias = cast(multiset(select ref(f) from freguesia f where f.concelho.codigo = c.codigo) as freguesia_tab_t);

-- this one may take a bit (more than 4k parishes (freguesia) to process)
update freguesia f
set f.votacoes = cast(multiset(select ref(v) from votacao v where v.freguesia.codigo = f.codigo) as votacao_tab_t);

