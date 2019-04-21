-- The results of each query in this file must be equal to the results of the corresponding query in the file "ex4_queries.sql"
----------------------------------
--a)------------------------------
----------------------------------
SELECT p.sigla, sum(l.mandatos) FROM GTD7.partidos p, GTD7.listas l WHERE p.sigla = l.partido GROUP BY p.sigla ORDER BY p.sigla;
----------------------------------
--b)------------------------------
----------------------------------
WITH zonas_partidos AS (SELECT d.codigo AS codigo, SUM(v.votos) AS votos, v.partido AS partido FROM GTD7.distritos d, GTD7.concelhos c, GTD7.freguesias f,  GTD7.votacoes v WHERE d.codigo = c.distrito AND c.codigo = f.concelho AND f.codigo = v.freguesia GROUP BY d.codigo, v.partido)
SELECT d.nome, tmp.partido, tmp.votos FROM zonas_partidos tmp, GTD7.distritos d WHERE d.codigo = tmp.codigo ORDER BY d.nome, tmp.partido;
----------------------------------
--c)------------------------------
----------------------------------
WITH zonas_partidos AS (SELECT c.codigo AS codigo, SUM(v.votos) AS votos, v.partido AS partido FROM GTD7.concelhos c, GTD7.freguesias f,  GTD7.votacoes v WHERE c.codigo = f.concelho AND f.codigo = v.freguesia GROUP BY c.codigo, v.partido)
SELECT c.nome, tmp.partido, tmp.votos FROM zonas_partidos tmp, GTD7.concelhos c WHERE c.codigo = tmp.codigo AND NOT EXISTS(SELECT * FROM zonas_partidos tmp2 WHERE tmp2.codigo = tmp.codigo AND tmp2.partido != tmp.partido AND tmp.votos < tmp2.votos)ORDER BY c.nome;
----------------------------------
--d)------------------------------
----------------------------------
select d.nome, pa.votantes, pa.abstencoes, pa.inscritos, 
pa.brancos, pa.nulos, pa.votantes-pa.brancos-pa.nulos, sum(v.votos)
from GTD7.freguesias f, GTD7.concelhos c, GTD7.distritos d, GTD7.votacoes v, GTD7.participacoes pa
where v.freguesia=f.codigo
and f.concelho=c.codigo and c.distrito=pa.distrito
and c.distrito=d.codigo
group by d.nome, pa.votantes, pa.abstencoes, pa.inscritos, pa.brancos, 
pa.nulos
having sum(v.votos)+pa.brancos+pa.nulos+pa.abstencoes<>pa.inscritos;
----------------------------------
--e)------------------------------
----------------------------------
select g.partido, round(100*(votosp/votost), 1), round(100*(mandatosp/mandatost), 1), round((votosp/votost-mandatosp/mandatost)*100,1)
from (select partido, sum(votos) votosp from GTD7.votacoes group by partido) g,
     (select partido, sum(mandatos) mandatosp from GTD7.listas group by partido) m,
     (select sum(votantes) votost from GTD7.participacoes) tv,
     (select sum(mandatos) mandatost from GTD7.listas) tm
where g.partido=m.partido;
----------------------------------
--f)------------------------------
----------------------------------
select sigla
from GTD7.partidos
where sigla not in (
   select sigla
   from GTD7.partidos, GTD7.distritos
   where (sigla,codigo) not in (
       select partido, distrito
       from GTD7.listas
       where mandatos>0));