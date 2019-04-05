

/*
Question 1 
*/
/* X*/
SELECT a.numero AS "Aluno (BI)", a.a_lect_conclusao - a.a_lect_matricula AS "Anos Demorados" 
FROM xalus a JOIN xlics l  ON a.curso = l.codigo 
WHERE a.estado = 'C' AND a.a_lect_conclusao - a.a_lect_matricula < 5 AND l.sigla = 'EIC';
/* Y*/
SELECT a.numero AS "Aluno (BI)", a.a_lect_conclusao - a.a_lect_matricula AS "Anos Demorados" 
FROM yalus a JOIN ylics l  ON a.curso = l.codigo 
WHERE a.estado = 'C' AND a.a_lect_conclusao - a.a_lect_matricula < 5 AND l.sigla = 'EIC';
/* Z*/
SELECT a.numero AS "Aluno (BI)", a.a_lect_conclusao - a.a_lect_matricula AS "Anos Demorados" 
FROM zalus a JOIN zlics l  ON a.curso = l.codigo 
WHERE a.estado = 'C' AND a.a_lect_conclusao - a.a_lect_matricula < 5 AND l.sigla = 'EIC';

/*
Question 2
*/
/* X*/
select c.curso, c.ano_lectivo as ano, min(c.media) as media
from xcands c inner join xalus a on c.bi = a.bi and c.ano_lectivo = a.a_lect_matricula and c.curso = a.curso
where c.media is not null
group by c.curso, c.ano_lectivo;
/* Y*/
select c.curso, c.ano_lectivo as ano, min(c.media) as media
from ycands c inner join yalus a on c.bi = a.bi and c.ano_lectivo = a.a_lect_matricula and c.curso = a.curso
where c.media is not null
group by c.curso, c.ano_lectivo;
/* Z*/
select c.curso, c.ano_lectivo as ano, min(c.media) as media
from zcands c inner join zalus a on c.bi = a.bi and c.ano_lectivo = a.a_lect_matricula and c.curso = a.curso
where c.media is not null
group by c.curso, c.ano_lectivo;

/*
Question 3 (constant subquery)
*/
/* X*/
SELECT c.ano_lectivo AS "Ano Letivo", COUNT(c.bi) AS "Número de Alunos não Matriculados"
FROM xcands c WHERE c.resultado = 'C'
AND (c.bi, c.curso, c.ano_lectivo) NOT IN(SELECT a.bi, a.curso, a.a_lect_matricula FROM xalus a)
GROUP BY c.ano_lectivo
ORDER BY c.ano_lectivo;
/* Y*/
SELECT c.ano_lectivo AS "Ano Letivo", COUNT(c.bi) AS "Número de Alunos não Matriculados"
FROM ycands c WHERE c.resultado = 'C'
AND (c.bi, c.curso, c.ano_lectivo) NOT IN(SELECT a.bi, a.curso, a.a_lect_matricula FROM yalus a)
GROUP BY c.ano_lectivo
ORDER BY c.ano_lectivo;
/* Z*/
SELECT c.ano_lectivo AS "Ano Letivo", COUNT(*) AS "Número de Alunos não Matriculados"
FROM zcands c WHERE c.resultado = 'C'
AND (c.bi, c.curso, c.ano_lectivo) NOT IN(SELECT a.bi, a.curso, a.a_lect_matricula FROM zalus a)
GROUP BY c.ano_lectivo
ORDER BY c.ano_lectivo;

/*
Question 3 (variable subquery)
*/
/* X*/
SELECT c.ano_lectivo AS "Ano Letivo", COUNT(c.bi) AS "Número de Alunos não Matriculados"
FROM xcands c WHERE c.resultado = 'C'
AND NOT EXISTS (SELECT * FROM xalus a WHERE a.bi = c.bi AND a.curso = c.curso AND a.a_lect_matricula = c.ano_lectivo)
GROUP BY c.ano_lectivo
ORDER BY c.ano_lectivo;
/* Y*/
SELECT c.ano_lectivo AS "Ano Letivo", COUNT(c.bi) AS "Número de Alunos não Matriculados"
FROM ycands c WHERE c.resultado = 'C'
AND NOT EXISTS (SELECT * FROM yalus a WHERE a.bi = c.bi AND a.curso = c.curso AND a.a_lect_matricula = c.ano_lectivo)
GROUP BY c.ano_lectivo
ORDER BY c.ano_lectivo;
/* Z*/
SELECT c.ano_lectivo AS "Ano Letivo", COUNT(c.bi) AS "Número de Alunos não Matriculados"
FROM zcands c WHERE c.resultado = 'C'
AND NOT EXISTS (SELECT * FROM zalus a WHERE a.bi = c.bi AND a.curso = c.curso AND a.a_lect_matricula = c.ano_lectivo)
GROUP BY c.ano_lectivo
ORDER BY c.ano_lectivo;

/*
Question 4 (first way - using a subquery to select value equal to max)
*/
/* X*/
with media_curso_ano as (
select curso, a_lect_conclusao as ano, round(avg(med_final),2) as media --max or avg?
from xalus
where a_lect_conclusao is not null
group by curso, a_lect_conclusao)
select *
from media_curso_ano t1
where media = (select max(media) from media_curso_ano t2 where t2.ano = t1.ano);
/* Y*/
with media_curso_ano as (
select curso, a_lect_conclusao as ano, round(avg(med_final),2) as media --max or avg?
from yalus
where a_lect_conclusao is not null
group by curso, a_lect_conclusao)
select *
from media_curso_ano t1
where media = (select max(media) from media_curso_ano t2 where t2.ano = t1.ano);
/* Z*/
with media_curso_ano as (
select curso, a_lect_conclusao as ano, round(avg(med_final),2) as media --max or avg?
from zalus
where a_lect_conclusao is not null
group by curso, a_lect_conclusao)
select *
from media_curso_ano t1
where media = (select max(media) from media_curso_ano t2 where t2.ano = t1.ano);

/*
Question 4 (second way - using left outer join on lower averages and filter for unmatched (aka highest))
*/
/* X*/
with media_curso_ano as (
select curso, a_lect_conclusao as ano, round(avg(med_final),2) as media --max or avg?
from xalus
where a_lect_conclusao is not null
group by curso, a_lect_conclusao)
select t1.*
from media_curso_ano t1 left outer join media_curso_ano t2
on t1.ano = t2.ano and t1.media < t2.media
where t2.ano is null
order by t1.ano;
/* Y*/
with media_curso_ano as (
select curso, a_lect_conclusao as ano, round(avg(med_final),2) as media --max or avg?
from yalus
where a_lect_conclusao is not null
group by curso, a_lect_conclusao)
select t1.*
from media_curso_ano t1 left outer join media_curso_ano t2
on t1.ano = t2.ano and t1.media < t2.media
where t2.ano is null
order by t1.ano;
/* Z*/
with media_curso_ano as (
select curso, a_lect_conclusao as ano, round(avg(med_final),2) as media --max or avg?
from zalus
where a_lect_conclusao is not null
group by curso, a_lect_conclusao)
select t1.*
from media_curso_ano t1 left outer join media_curso_ano t2
on t1.ano = t2.ano and t1.media < t2.media
where t2.ano is null
order by t1.ano;

/*
Question 5
*/
/* X*/
SELECT COUNT(DISTINCT c.bi) AS "Número de Candidatos != (C | E)"
FROM xcands c 
WHERE c.resultado <> 'C' AND c.resultado <> 'E'; 
/* Y*/
SELECT COUNT(DISTINCT c.bi) AS "Número de Candidatos != (C | E)"
FROM ycands c 
WHERE c.resultado <> 'C' AND c.resultado <> 'E'; 
/* Z*/
SELECT COUNT(c.bi) AS "Número de Candidatos != (C | E)"
FROM zcands c 
WHERE c.resultado <> 'C' AND c.resultado <> 'E'; 


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
group by l.sigla, l.nome, c.ano_lectivo;
/* Y*/
with aceites_nao_matriculados as(
select c.curso, c.ano_lectivo as ano
from ycands c
where c.resultado='C' and not exists (select 1 from yalus a where a.a_lect_matricula = c.ano_lectivo and a.curso = c.curso and c.bi = a.bi)
group by c.curso, c.ano_lectivo)
select l.sigla, l.nome, c.ano_lectivo as ano
from ylics l inner join ycands c
on l.codigo = c.curso
where c.resultado = 'C' and not exists (select 1 from aceites_nao_matriculados anm where anm.curso = c.curso and anm.ano = c.ano_lectivo)
group by l.sigla, l.nome, c.ano_lectivo;
/* Z*/
with aceites_nao_matriculados as(
select c.curso, c.ano_lectivo as ano
from zcands c
where c.resultado='C' and not exists (select 1 from zalus a where a.a_lect_matricula = c.ano_lectivo and a.curso = c.curso and c.bi = a.bi)
group by c.curso, c.ano_lectivo)
select l.sigla, l.nome, c.ano_lectivo as ano
from zlics l inner join zcands c
on l.codigo = c.curso
where c.resultado = 'C' and not exists (select 1 from aceites_nao_matriculados anm where anm.curso = c.curso and anm.ano = c.ano_lectivo)
group by l.sigla, l.nome, c.ano_lectivo;

/*
Question 6 (counting)
*/
/* X*/
select l.sigla, l.nome, c.curso, c.ano_lectivo as ano
from xcands c inner join xlics l
on l.codigo = c.curso
where c.resultado='C'
group by l.sigla, l.nome, c.curso, c.ano_lectivo
having count(*) = (select count(*) from xalus a where a.a_lect_matricula = c.ano_lectivo and a.curso = c.curso);
/* Y*/
select l.sigla, l.nome, c.curso, c.ano_lectivo as ano
from ycands c inner join ylics l
on l.codigo = c.curso
where c.resultado='C'
group by l.sigla, l.nome, c.curso, c.ano_lectivo
having count(*) = (select count(*) from yalus a where a.a_lect_matricula = c.ano_lectivo and a.curso = c.curso);
/* Z*/
select l.sigla, l.nome, c.curso, c.ano_lectivo as ano
from zcands c inner join zlics l
on l.codigo = c.curso
where c.resultado='C'
group by l.sigla, l.nome, c.curso, c.ano_lectivo
having count(*) = (select count(*) from zalus a where a.a_lect_matricula = c.ano_lectivo and a.curso = c.curso);
