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
