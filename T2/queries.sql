--3)
----------------------------------
--freguesia-----------------------
----------------------------------
ALTER TYPE freguesia_t DROP MEMBER FUNCTION total_votos RETURN NUMBER CASCADE;
ALTER TYPE freguesia_t DROP MEMBER FUNCTION partido_vencedor RETURN REF partido_t CASCADE;
ALTER TYPE freguesia_t DROP MEMBER FUNCTION votos_partido(sigla_partido VARCHAR2) RETURN NUMBER CASCADE;

ALTER TYPE freguesia_t ADD MEMBER FUNCTION total_votos RETURN NUMBER CASCADE; 
ALTER TYPE freguesia_t ADD MEMBER FUNCTION partido_vencedor RETURN REF partido_t CASCADE; 
ALTER TYPE freguesia_t ADD MEMBER FUNCTION votos_partido(sigla_partido VARCHAR2) RETURN NUMBER CASCADE;
/
CREATE OR REPLACE TYPE BODY freguesia_t AS
    MEMBER FUNCTION total_votos RETURN NUMBER IS
    ret_variable NUMBER;
    BEGIN
        SELECT SUM(value(v).votos) INTO ret_variable FROM table(SELF.votacoes) v;
        RETURN ret_variable;
    END total_votos;
    
    MEMBER FUNCTION partido_vencedor RETURN REF partido_t IS
    ret_variable REF partido_t;
    BEGIN
        SELECT value(v).partido INTO ret_variable FROM table(SELF.votacoes) v WHERE 
            NOT EXISTS (SELECT * FROM table(SELF.votacoes) v2 WHERE value(v).partido != value(v2).partido AND value(v).votos < value(v2).votos OR(value(v).votos = value(v2).votos AND value(v).partido.sigla > value(v2).partido.sigla));
        RETURN ret_variable;
    END partido_vencedor;
    
    MEMBER FUNCTION votos_partido(sigla_partido VARCHAR2) RETURN NUMBER IS
    ret_variable NUMBER;
    BEGIN
        SELECT SUM(value(v).votos) INTO ret_variable FROM table(SELF.votacoes) v WHERE value(v).partido.sigla = sigla_partido;
        RETURN ret_variable;
    END votos_partido;
END;
/

-- Verification
--total_votos 
SELECT f.nome, SUM(v.votos) FROM GTD7.freguesias f JOIN GTD7.votacoes v ON f.codigo = v.freguesia GROUP BY f.nome ORDER BY f.nome;
--
SELECT f.nome, f.total_votos() FROM freguesia f ORDER BY f.nome;
-- partido vencedor
WITH zonas_partidos AS (SELECT f.codigo AS codigo, f.nome AS nome, v.votos AS votos, v.partido AS partido FROM GTD7.freguesias f,  GTD7.votacoes v WHERE f.codigo = v.freguesia )
SELECT tmp.nome, tmp.partido, tmp.votos FROM zonas_partidos tmp WHERE NOT EXISTS(SELECT * FROM zonas_partidos tmp2 WHERE tmp2.codigo = tmp.codigo AND tmp2.partido != tmp.partido AND tmp.votos < tmp2.votos)ORDER BY tmp.nome;
--
SELECT f.nome, f.partido_vencedor().sigla FROM freguesia f ORDER BY f.nome;
-- votos num determinado partido
WITH zonas_partidos AS (SELECT f.codigo AS codigo, f.nome AS nome, v.votos AS votos, v.partido AS partido FROM GTD7.freguesias f,  GTD7.votacoes v WHERE f.codigo = v.freguesia )
SELECT tmp.nome, tmp.partido, tmp.votos FROM zonas_partidos tmp WHERE tmp.partido = 'PS' ORDER BY tmp.nome;

SELECT f.nome, f.votos_partido('PS') FROM freguesia f ORDER BY f.nome;

----------------------------------
--concelho-----------------------
----------------------------------
ALTER TYPE concelho_t DROP MEMBER FUNCTION total_votos RETURN NUMBER CASCADE;
ALTER TYPE concelho_t DROP MEMBER FUNCTION partido_vencedor RETURN REF partido_t CASCADE;

ALTER TYPE concelho_t ADD MEMBER FUNCTION total_votos RETURN NUMBER CASCADE;
ALTER TYPE concelho_t ADD MEMBER FUNCTION partido_vencedor RETURN REF partido_t CASCADE; 
/
CREATE OR REPLACE TYPE BODY concelho_t AS
    MEMBER FUNCTION total_votos RETURN NUMBER IS
    ret_variable NUMBER;
    BEGIN
        SELECT SUM(value(v).votos) INTO ret_variable FROM table(SELF.freguesias) f, table(value(f).votacoes) v;
        RETURN ret_variable;
    END total_votos;
    
    MEMBER FUNCTION partido_vencedor RETURN REF partido_t IS
    ret_variable REF partido_t;
    BEGIN
        SELECT value(v).partido INTO ret_variable FROM table(SELF.freguesias) f, table(value(f).votacoes) v WHERE 
            NOT EXISTS (SELECT * FROM table(value(f).votacoes) v2 WHERE value(v).partido != value(v2).partido AND value(v).votos < value(v2).votos OR(value(v).votos = value(v2).votos AND value(v).partido.sigla > value(v2).partido.sigla));
        RETURN ret_variable;
    END partido_vencedor;
END;
/
--Verification
--total votes
SELECT c.nome, SUM(v.votos) FROM GTD7.concelhos c, GTD7.freguesias f, GTD7.votacoes v WHERE c.codigo = f.concelho AND f.codigo = v.freguesia GROUP BY c.nome ORDER BY c.nome; 
--
SELECT c.nome, c.total_votos() FROM concelho c ORDER BY c.nome;
-- partido vencedor
WITH zonas_partidos AS (SELECT c.codigo AS codigo, SUM(v.votos) AS votos, v.partido AS partido FROM GTD7.concelhos c, GTD7.freguesias f,  GTD7.votacoes v WHERE c.codigo = f.concelho AND f.codigo = v.freguesia GROUP BY c.codigo, v.partido)
SELECT c.nome, tmp.partido, tmp.votos FROM zonas_partidos tmp, GTD7.concelhos c WHERE c.codigo = tmp.codigo AND NOT EXISTS(SELECT * FROM zonas_partidos tmp2 WHERE tmp2.codigo = tmp.codigo AND tmp2.partido != tmp.partido AND tmp.votos < tmp2.votos)ORDER BY c.nome;
--
SELECT c.nome, c.partido_vencedor().sigla FROM concelho c ORDER BY c.nome;
----------------------------------
--distrito------------------------
----------------------------------
ALTER TYPE distrito_t DROP MEMBER FUNCTION total_votos RETURN NUMBER CASCADE;
ALTER TYPE distrito_t ADD MEMBER FUNCTION total_votos RETURN NUMBER CASCADE;
/
CREATE OR REPLACE TYPE BODY distrito_t AS
    MEMBER FUNCTION total_votos RETURN NUMBER IS
    ret_variable NUMBER;
    BEGIN
        SELECT SUM(value(v).votos) INTO ret_variable FROM table(SELF.concelhos) c, table(value(c).freguesias) f, table(value(f).votacoes) v;
        RETURN ret_variable;
    END total_votos;
END;
/
--Verification
SELECT d.nome, SUM(v.votos) FROM GTD7.distritos d, GTD7.concelhos c, GTD7.freguesias f, GTD7.votacoes v WHERE d.codigo = c.distrito AND c.codigo = f.concelho AND f.codigo = v.freguesia GROUP BY d.nome ORDER BY d.nome; 
SELECT d.nome, d.total_votos() FROM distrito d ORDER BY d.nome;

-----------------------------
--partido vencedor por zona--
-----------------------------

ALTER TYPE freguesia_t ADD MEMBER FUNCTION partido_vencedor RETURN REF partido_t CASCADE;
