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
    