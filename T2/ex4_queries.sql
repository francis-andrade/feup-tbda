----------------------------------
--a)------------------------------
----------------------------------
SELECT p.sigla AS "Partido", p.total_mandatos() AS "Mandatos" FROM partido p ORDER BY p.sigla;
----------------------------------
--b)------------------------------
----------------------------------
SELECT d.nome AS "Distrito", p.sigla AS "Partido", d.votos_partido(p.sigla) AS "Votos" FROM distrito d, partido p ORDER BY d.nome, p.sigla;
----------------------------------
--c)------------------------------
----------------------------------
SELECT c.nome AS "Concelho", c.partido_vencedor().sigla AS "Partido Vencedor" FROM concelho c ORDER BY c.nome;
----------------------------------
--d)------------------------------
----------------------------------
SELECT d.nome AS "Distrito", d.participacao.votantes AS "Votantes", d.participacao.abstencoes AS "Abstencoes", d.participacao.inscritos AS "Inscritos", 
d.participacao.brancos AS "Brancos", d.participacao.nulos AS "Nulos", 
d.participacao.votantes - d.participacao.brancos - d.participacao.nulos AS "Votantes - Brancos - Nulos", d.total_votos() AS "Total Votos"
FROM distrito d WHERE d.integrity() = 0;
----------------------------------
--e)------------------------------
----------------------------------
SELECT perc.sigla AS "Partido", perc.votos AS "Perc. Votos", perc.mandatos AS "Perc. Mandatos", perc.votos - perc.mandatos AS "Votos - Mandatos"
FROM 
(SELECT p.sigla AS sigla, ROUND(100*(p.total_votos() / tv.total_votos), 1) AS votos, ROUND(100*(p.total_mandatos() / tm.total_mandatos), 1) AS mandatos FROM 
    partido p,
    (SELECT SUM(d.participacao.votantes) AS total_votos FROM distrito d) tv,
    (SELECT SUM(l.mandatos) AS total_mandatos FROM lista l) tm
    ) perc
ORDER BY perc.sigla;
----------------------------------
--f)------------------------------
----------------------------------
SELECT p.sigla AS "Partido" FROM partido p
WHERE NOT EXISTS 
    (SELECT * FROM distrito d WHERE d.codigo 
        NOT IN (SELECT value(l).distrito.codigo FROM table(p.listas) l) 
        OR d.codigo IN (SELECT value(l).distrito.codigo FROM table(p.listas) l WHERE value(l).mandatos = 0)
    ); 
-------------------------------------------------------------------
--g1)-Partido Vencedor por Distrito--------------------------------
-------------------------------------------------------------------
SELECT d.nome, d.partido_vencedor().sigla AS "Partido Vencedor" FROM distrito d ORDER BY d.nome;
-------------------------------------------------------------------
--g21)--Freguesia onde houve maioria absoluta----------------------
-------------------------------------------------------------------
SELECT freg.nome AS "Freguesia", freg.partido_vencedor AS "Partido Vencedor", ROUND(100*freg.ratio, 1) AS "Perc. Votos Partido Vencedor"
FROM 
(SELECT f.nome AS nome, f.partido_vencedor().sigla AS partido_vencedor, f.ratio_votos_partido_vencedor() AS ratio FROM freguesia f) freg
WHERE freg.ratio > 0.5
ORDER BY freg.nome;
/*
SELECT f.nome AS "Freguesia", f.partido_vencedor().sigla AS "Partido Vencedor", ROUND(100*f.ratio_votos_partido_vencedor(),1) AS "Perc. Votos Partido Vencedor" FROM freguesia f 
WHERE"Perc. Votos Partido Vencedor" > 50
ORDER BY "Freguesia;
*/
SELECT COUNT(*) FROM(
SELECT freg.nome AS "Freguesia", freg.partido_vencedor AS "Partido Vencedor", ROUND(100*freg.ratio, 1) AS "Perc. Votos Partido Vencedor"
FROM 
(SELECT f.nome AS nome, f.partido_vencedor().sigla AS partido_vencedor, f.ratio_votos_partido_vencedor() AS ratio FROM freguesia f) freg
WHERE freg.ratio > 0.5);
-------------------------------------------------------------------
--g22)--Concelho onde houve maioria absoluta-----------------------
-------------------------------------------------------------------
SELECT concl.nome AS "Concelho", concl.partido_vencedor AS "Partido Vencedor", ROUND(100*concl.ratio, 1) AS "Perc. Votos Partido Vencedor"
FROM 
(SELECT c.nome AS nome, c.partido_vencedor().sigla AS partido_vencedor, c.ratio_votos_partido_vencedor() AS ratio FROM concelho c) concl
WHERE concl.ratio > 0.5
ORDER BY concl.nome;
-------------------------------------------------------------------
--g23)--Distrito onde houve maioria absoluta-----------------------
-------------------------------------------------------------------
SELECT dist.nome AS "Distrito", dist.partido_vencedor AS "Partido Vencedor", ROUND(100*dist.ratio, 1) AS "Perc. Votos Partido Vencedor"
FROM 
(SELECT d.nome AS nome, d.partido_vencedor().sigla AS partido_vencedor, d.ratio_votos_partido_vencedor() AS ratio FROM distrito d) dist
WHERE dist.ratio > 0.5
ORDER BY dist.nome;
-------------------------------------------------------------------
--g3)--Distrito onde houve maioria absoluta por mandatos----------
-------------------------------------------------------------------
SELECT dist.nome AS "Distrito", dist.partido_vencedor AS "Partido Vencedor", ROUND(100*dist.ratio, 1) AS "Perc. Mandatos Partido Vencedor"
FROM 
(SELECT d.nome AS nome, d.partido_vencedor().sigla AS partido_vencedor, d.ratio_mandatos_partido_vencedor() AS ratio FROM distrito d) dist
WHERE dist.ratio > 0.5
ORDER BY dist.nome;
-------------------------------------------------------------------
--g4)--Distrito com o melhor rácio por partido--------------------
-------------------------------------------------------------------
SELECT tmp.sigla AS "Partido", tmp.ret.dist.nome AS "Melhor distrito", ROUND(100*tmp.ret.ratio, 1) AS "Perc. Votos"  
FROM 
(SELECT p.sigla AS sigla, p.best_ratio_district() AS ret FROM  partido p) tmp 
ORDER BY tmp.sigla;
-----------------------------------------------------------------------------
--g5)--Percentagem de votos em cada partido ordenado pelo número de votos----
-----------------------------------------------------------------------------
SELECT p.sigla AS "Partido", ROUND(100*p.total_votos()/tv.total_votos, 1) AS "Perc. Votos"
FROM
partido p,
(SELECT SUM(d.participacao.votantes) AS total_votos FROM distrito d) tv
ORDER BY value(p) DESC;