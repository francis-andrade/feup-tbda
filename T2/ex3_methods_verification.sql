----------------------------------
--freguesia-----------------------
----------------------------------
--total_votos 
SELECT f.nome, SUM(v.votos) FROM GTD7.freguesias f JOIN GTD7.votacoes v ON f.codigo = v.freguesia GROUP BY f.nome ORDER BY f.nome;
--
SELECT f.nome, f.total_votos() FROM freguesia f ORDER BY f.nome;
-- partido vencedor
WITH zonas_partidos AS (SELECT f.codigo AS codigo, f.nome AS nome, v.votos AS votos, v.partido AS partido FROM GTD7.freguesias f,  GTD7.votacoes v WHERE f.codigo = v.freguesia )
SELECT tmp.nome, tmp.partido, tmp.votos FROM zonas_partidos tmp WHERE NOT EXISTS(SELECT * FROM zonas_partidos tmp2 WHERE tmp2.codigo = tmp.codigo AND tmp2.partido != tmp.partido AND tmp.votos < tmp2.votos)ORDER BY tmp.nome;
--
SELECT f.nome, f.partido_vencedor().sigla FROM freguesia f  ORDER BY f.nome;
-- votos num determinado partido
WITH zonas_partidos AS (SELECT f.codigo AS codigo, f.nome AS nome, v.votos AS votos, v.partido AS partido FROM GTD7.freguesias f,  GTD7.votacoes v WHERE f.codigo = v.freguesia )
SELECT tmp.nome, tmp.partido, tmp.votos FROM zonas_partidos tmp WHERE tmp.partido = 'PS' ORDER BY tmp.nome;
--
SELECT f.nome, f.votos_partido('PS') FROM freguesia f ORDER BY f.nome;


----------------------------------
--concelho-----------------------
----------------------------------
--total votes
SELECT c.nome, SUM(v.votos) FROM GTD7.concelhos c, GTD7.freguesias f, GTD7.votacoes v WHERE c.codigo = f.concelho AND f.codigo = v.freguesia GROUP BY c.nome ORDER BY c.nome; 
--
SELECT c.nome, c.total_votos() FROM concelho c ORDER BY c.nome;
-- partido vencedor
WITH zonas_partidos AS (SELECT c.codigo AS codigo, SUM(v.votos) AS votos, v.partido AS partido FROM GTD7.concelhos c, GTD7.freguesias f,  GTD7.votacoes v WHERE c.codigo = f.concelho AND f.codigo = v.freguesia GROUP BY c.codigo, v.partido)
SELECT c.nome, tmp.partido, tmp.votos FROM zonas_partidos tmp, GTD7.concelhos c WHERE c.codigo = tmp.codigo AND NOT EXISTS(SELECT * FROM zonas_partidos tmp2 WHERE tmp2.codigo = tmp.codigo AND tmp2.partido != tmp.partido AND tmp.votos < tmp2.votos)ORDER BY c.nome;
--
SELECT c.nome, c.partido_vencedor().sigla FROM concelho c ORDER BY c.nome;

-- votos num determinado partido
WITH zonas_partidos AS (SELECT c.codigo AS codigo, SUM(v.votos) AS votos, v.partido AS partido FROM GTD7.concelhos c, GTD7.freguesias f,  GTD7.votacoes v WHERE c.codigo = f.concelho AND f.codigo = v.freguesia GROUP BY c.codigo, v.partido)
SELECT c.nome, tmp.partido, tmp.votos FROM zonas_partidos tmp, GTD7.concelhos c WHERE c.codigo = tmp.codigo AND tmp.partido = 'PS' ORDER BY c.nome;
--
SELECT c.nome, c.votos_partido('PS') FROM concelho c ORDER BY c.nome;

----------------------------------
--distrito------------------------
----------------------------------
-- total de votos
SELECT d.nome, SUM(v.votos) FROM GTD7.distritos d, GTD7.concelhos c, GTD7.freguesias f, GTD7.votacoes v WHERE d.codigo = c.distrito AND c.codigo = f.concelho AND f.codigo = v.freguesia GROUP BY d.nome ORDER BY d.nome; 
--
SELECT d.nome, d.total_votos() FROM distrito d ORDER BY d.nome;
-- partido vencedor
WITH zonas_partidos AS (SELECT d.codigo AS codigo, SUM(v.votos) AS votos, v.partido AS partido FROM GTD7.distritos d, GTD7.concelhos c, GTD7.freguesias f,  GTD7.votacoes v WHERE d.codigo = c.distrito AND c.codigo = f.concelho AND f.codigo = v.freguesia GROUP BY d.codigo, v.partido)
SELECT d.nome, tmp.partido, tmp.votos FROM zonas_partidos tmp, GTD7.distritos d WHERE d.codigo = tmp.codigo AND NOT EXISTS(SELECT * FROM zonas_partidos tmp2 WHERE tmp2.codigo = tmp.codigo AND tmp2.partido != tmp.partido AND tmp.votos < tmp2.votos) ORDER BY d.nome;
--
SELECT d.nome, d.partido_vencedor().sigla FROM distrito d ORDER BY d.nome;
-- votos num determinado partido
WITH zonas_partidos AS (SELECT d.codigo AS codigo, SUM(v.votos) AS votos, v.partido AS partido FROM GTD7.distritos d, GTD7.concelhos c, GTD7.freguesias f,  GTD7.votacoes v WHERE d.codigo = c.distrito AND c.codigo = f.concelho AND f.codigo = v.freguesia GROUP BY d.codigo, v.partido)
SELECT d.nome, tmp.partido, tmp.votos FROM zonas_partidos tmp, GTD7.distritos d WHERE d.codigo = tmp.codigo AND tmp.partido = 'PS' ORDER BY d.nome;
--
SELECT d.nome, d.votos_partido('PS') FROM distrito d ORDER BY d.nome;
-- integrity rule
select d.nome, pa.votantes, pa.abstencoes, pa.inscritos, 
pa.brancos, pa.nulos, pa.votantes-pa.brancos-pa.nulos, sum(v.votos)
from GTD7.freguesias f, GTD7.concelhos c, GTD7.distritos d, GTD7.votacoes v, GTD7.participacoes pa
where v.freguesia=f.codigo
and f.concelho=c.codigo and c.distrito=pa.distrito
and c.distrito=d.codigo
group by d.nome, pa.votantes, pa.abstencoes, pa.inscritos, pa.brancos, 
pa.nulos
having sum(v.votos)+pa.brancos+pa.nulos+pa.abstencoes<>pa.inscritos;
--
SELECT d.nome FROM distrito d WHERE d.integrity() = 0;
----------------------------------
--partido-------------------------
----------------------------------
-- total de votos
SELECT p.sigla, sum(v.votos) FROM GTD7.votacoes v, GTD7.partidos p WHERE p.sigla = v.partido GROUP BY p.sigla ORDER BY p.sigla;
--
SELECT p.sigla, p.total_votos() FROM partido p ORDER BY p.sigla;
-- total de mandatos
SELECT p.sigla, sum(l.mandatos) FROM GTD7.partidos p, GTD7.listas l WHERE p.sigla = l.partido GROUP BY p.sigla ORDER BY p.sigla;
--
SELECT p.sigla, p.total_mandatos() FROM partido p ORDER BY p.sigla;
