-- import tables
CREATE TABLE xlics AS (SELECT * FROM gtd2.lics);
CREATE TABLE xcands AS (SELECT * FROM gtd2.cands);
CREATE TABLE xalus AS (SELECT * FROM gtd2.alus);
CREATE TABLE xanos AS (SELECT * FROM gtd2.anos);
 
CREATE TABLE ylics AS (SELECT * FROM gtd2.lics);
CREATE TABLE ycands AS (SELECT * FROM gtd2.cands);
CREATE TABLE yalus AS (SELECT * FROM gtd2.alus);
CREATE TABLE yanos AS (SELECT * FROM gtd2.anos);
 
CREATE TABLE zlics AS (SELECT * FROM gtd2.lics);
CREATE TABLE zcands AS (SELECT * FROM gtd2.cands);
CREATE TABLE zalus AS (SELECT * FROM gtd2.alus);
CREATE TABLE zanos AS (SELECT * FROM gtd2.anos);
 
-- primary keys
ALTER TABLE ylics ADD CONSTRAINT ylics_pk PRIMARY KEY (codigo);
ALTER TABLE ycands ADD CONSTRAINT ycands_pk PRIMARY KEY (bi,curso,ano_lectivo);
ALTER TABLE yalus ADD CONSTRAINT yalus_pk  PRIMARY KEY (numero);
 
ALTER TABLE zlics ADD CONSTRAINT zlics_pk PRIMARY KEY (codigo);
ALTER TABLE zcands ADD CONSTRAINT zcands_pk PRIMARY KEY (bi,curso,ano_lectivo);
ALTER TABLE zalus ADD CONSTRAINT zalus_pk  PRIMARY KEY (numero);
 
 
-- foreign keys
ALTER TABLE ycands ADD CONSTRAINT ycands_fk_curso FOREIGN KEY (curso) REFERENCES ylics (codigo);
ALTER TABLE yalus ADD CONSTRAINT yalus_fk_curso FOREIGN KEY (curso) REFERENCES ylics(codigo);
ALTER TABLE yalus ADD CONSTRAINT yalus_fk_cands FOREIGN KEY (bi, curso, a_lect_matricula) REFERENCES ycands(bi, curso, ano_lectivo);
 
ALTER TABLE zcands ADD CONSTRAINT zcands_fk_curso FOREIGN KEY (curso) REFERENCES zlics (codigo);
ALTER TABLE zalus ADD CONSTRAINT zalus_fk_curso FOREIGN KEY (curso) REFERENCES zlics(codigo);
ALTER TABLE zalus ADD CONSTRAINT zalus_fk_cands FOREIGN KEY (bi, curso, a_lect_matricula) REFERENCES zcands(bi, curso, ano_lectivo);

/*
Question 1 
*/
/* X*/
SELECT a.numero, a.a_lect_conclusao - a.a_lect_matricula AS "Número de Anos Demorado" FROM xalus a JOIN xlics l  ON a.curso = l.codigo WHERE a.estado = 'C' AND l.sigla = 'EIC' AND a.a_lect_conclusao - a.a_lect_matricula < 5;
/* Y*/
SELECT a.numero, a.a_lect_conclusao - a.a_lect_matricula AS "Número de Anos Demorado" FROM yalus a JOIN ylics l  ON a.curso = l.codigo WHERE a.estado = 'C' AND l.sigla = 'EIC' AND a.a_lect_conclusao - a.a_lect_matricula < 5;
/* Z*/
SELECT a.numero, a.a_lect_conclusao - a.a_lect_matricula AS "Número de Anos Demorado" FROM zalus a JOIN zlics l  ON a.curso = l.codigo AND a.estado = 'C' AND l.sigla = 'EIC' AND a.a_lect_conclusao - a.a_lect_matricula < 5;

/*
Question 2
*/
/* X*/
select c.curso, c.ano_lectivo as ano, min(c.media) as media
from xcands c inner join xalus a on c.bi = a.bi and c.ano_lectivo = a.a_lect_matricula and c.curso = a.curso
where c.media is not null
group by c.curso, c.ano_lectivo
/* Y*/
select c.curso, c.ano_lectivo as ano, min(c.media) as media
from ycands c inner join yalus a on c.bi = a.bi and c.ano_lectivo = a.a_lect_matricula and c.curso = a.curso
where c.media is not null
group by c.curso, c.ano_lectivo
/* Z*/
select c.curso, c.ano_lectivo as ano, min(c.media) as media
from zcands c inner join zalus a on c.bi = a.bi and c.ano_lectivo = a.a_lect_matricula and c.curso = a.curso
where c.media is not null
group by c.curso, c.ano_lectivo

/*
Question 3 (constant subquery)
*/
/* X*/
/* Y*/
/* Z*/

/*
Question 3 (variable subquery)
*/
/* X*/
/* Y*/
/* Z*/

/*
Question 4 (first way - using a subquery to select value equal to max)
*/
/* X*/
with media_curso_ano as (
select curso, a_lect_conclusao as ano, round(avg(med_final),2) as media --max or avg?
from xalus
where a_lect_conclusao is not null
group by curso, a_lect_conclusao
order by a_lect_conclusao)
select *
from media_curso_ano t1
where media = (select max(media) from media_curso_ano t2 where t2.ano = t1.ano)
/* Y*/
with media_curso_ano as (
select curso, a_lect_conclusao as ano, round(avg(med_final),2) as media --max or avg?
from yalus
where a_lect_conclusao is not null
group by curso, a_lect_conclusao
order by a_lect_conclusao)
select *
from media_curso_ano t1
where media = (select max(media) from media_curso_ano t2 where t2.ano = t1.ano)
/* Z*/
with media_curso_ano as (
select curso, a_lect_conclusao as ano, round(avg(med_final),2) as media --max or avg?
from yalus
where a_lect_conclusao is not null
group by curso, a_lect_conclusao
order by a_lect_conclusao)
select *
from media_curso_ano t1
where media = (select max(media) from media_curso_ano t2 where t2.ano = t1.ano)

/*
Question 4 (second way - using left outer join on lower averages and filter for unmatched (aka highest))
*/
/* X*/
with media_curso_ano as (
select curso, a_lect_conclusao as ano, round(avg(med_final),2) as media --max or avg?
from xalus
where a_lect_conclusao is not null
group by curso, a_lect_conclusao
order by a_lect_conclusao)
select t1.*
from media_curso_ano t1 left outer join media_curso_ano t2
on t1.ano = t2.ano and t1.media < t2.media
where t2.ano is null
order by t1.ano
/* Y*/
with media_curso_ano as (
select curso, a_lect_conclusao as ano, round(avg(med_final),2) as media --max or avg?
from yalus
where a_lect_conclusao is not null
group by curso, a_lect_conclusao
order by a_lect_conclusao)
select t1.*
from media_curso_ano t1 left outer join media_curso_ano t2
on t1.ano = t2.ano and t1.media < t2.media
where t2.ano is null
order by t1.ano
/* Z*/
with media_curso_ano as (
select curso, a_lect_conclusao as ano, round(avg(med_final),2) as media --max or avg?
from yalus
where a_lect_conclusao is not null
group by curso, a_lect_conclusao
order by a_lect_conclusao)
select t1.*
from media_curso_ano t1 left outer join media_curso_ano t2
on t1.ano = t2.ano and t1.media < t2.media
where t2.ano is null
order by t1.ano

/*
Question 5 (B-tree)
*/
/* X*/
/* Y*/
/* Z*/

/*
Question 5 (Bitmap)
*/
/* X*/
/* Y*/
/* Z*/

/*
Question 6 (double negation)
*/
/* X*/
with aceites_nao_matriculados as(
select c.curso, c.ano_lectivo as ano
from xcands c
where c.resultado='C' and not exists (select 1 from xalus a where a.a_lect_matricula = c.ano_lectivo and a.curso = c.curso and c.bi = a.bi)
group by c.curso, c.ano_lectivo)
select l.sigla, l.nome, c.ano_lectivo as ano
from xlics l inner join xcands c
on l.codigo = c.curso
where c.resultado = 'C' and not exists (select 1 from aceites_nao_matriculados anm where anm.curso = c.curso and anm.ano = c.ano_lectivo)
group by l.sigla, l.nome, c.ano_lectivo
/* Y*/
with aceites_nao_matriculados as(
select c.curso, c.ano_lectivo as ano
from ycands c
where c.resultado='C' and not exists (select 1 from xalus a where a.a_lect_matricula = c.ano_lectivo and a.curso = c.curso and c.bi = a.bi)
group by c.curso, c.ano_lectivo)
select l.sigla, l.nome, c.ano_lectivo as ano
from ylics l inner join ycands c
on l.codigo = c.curso
where c.resultado = 'C' and not exists (select 1 from aceites_nao_matriculados anm where anm.curso = c.curso and anm.ano = c.ano_lectivo)
group by l.sigla, l.nome, c.ano_lectivo
/* Z*/
with aceites_nao_matriculados as(
select c.curso, c.ano_lectivo as ano
from zcands c
where c.resultado='C' and not exists (select 1 from xalus a where a.a_lect_matricula = c.ano_lectivo and a.curso = c.curso and c.bi = a.bi)
group by c.curso, c.ano_lectivo)
select l.sigla, l.nome, c.ano_lectivo as ano
from zlics l inner join zcands c
on l.codigo = c.curso
where c.resultado = 'C' and not exists (select 1 from aceites_nao_matriculados anm where anm.curso = c.curso and anm.ano = c.ano_lectivo)
group by l.sigla, l.nome, c.ano_lectivo

/*
Question 6 (counting)
*/
/* X*/
select l.sigla, l.nome, c.curso, c.ano_lectivo as ano
from xcands c inner join xlics l
on l.codigo = c.curso
where c.resultado='C'
group by l.sigla, l.nome, c.curso, c.ano_lectivo
having count(*) = (select count(*) from xalus a where a.a_lect_matricula = c.ano_lectivo and a.curso = c.curso)
/* Y*/
select l.sigla, l.nome, c.curso, c.ano_lectivo as ano
from ycands c inner join ylics l
on l.codigo = c.curso
where c.resultado='C'
group by l.sigla, l.nome, c.curso, c.ano_lectivo
having count(*) = (select count(*) from yalus a where a.a_lect_matricula = c.ano_lectivo and a.curso = c.curso)
/* Z*/
select l.sigla, l.nome, c.curso, c.ano_lectivo as ano
from zcands c inner join zlics l
on l.codigo = c.curso
where c.resultado='C'
group by l.sigla, l.nome, c.curso, c.ano_lectivo
having count(*) = (select count(*) from zalus a where a.a_lect_matricula = c.ano_lectivo and a.curso = c.curso)
