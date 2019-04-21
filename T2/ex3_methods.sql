--3)
----------------------------------
--DROP----------------------------
----------------------------------
ALTER TYPE zona_t DROP MEMBER FUNCTION partido_vencedor RETURN REF partido_t CASCADE;

ALTER TYPE freguesia_t DROP MEMBER FUNCTION total_votos RETURN NUMBER CASCADE;

ALTER TYPE concelho_t DROP MEMBER FUNCTION total_votos RETURN NUMBER CASCADE;

ALTER TYPE distrito_t DROP MEMBER FUNCTION total_votos RETURN NUMBER CASCADE;
ALTER TYPE distrito_t DROP MEMBER FUNCTION integrity RETURN NUMBER CASCADE;

ALTER TYPE partido_t DROP MEMBER FUNCTION total_votos RETURN NUMBER CASCADE;
ALTER TYPE partido_t DROP MEMBER FUNCTION total_mandatos RETURN NUMBER CASCADE;
----------------------------------
--zona-----------------------
----------------------------------
ALTER TYPE zona_t ADD MEMBER FUNCTION partido_vencedor RETURN REF partido_t CASCADE;
/
CREATE OR REPLACE TYPE BODY zona_t AS  
    MEMBER FUNCTION partido_vencedor RETURN REF partido_t IS
    ret_variable REF partido_t;
    BEGIN
        SELECT REF(p) INTO ret_variable FROM partido p WHERE 
            NOT EXISTS (SELECT * FROM partido p2 WHERE (p.sigla != p2.sigla AND SELF.votos_partido(p.sigla) < SELF.votos_partido(p2.sigla)) OR (SELF.votos_partido(p.sigla) = SELF.votos_partido(p2.sigla) AND p.sigla > p2.sigla));
        RETURN ret_variable;
    END partido_vencedor;
END;
/
----------------------------------
--freguesia-----------------------
----------------------------------
ALTER TYPE freguesia_t ADD MEMBER FUNCTION total_votos RETURN NUMBER CASCADE; 
/
CREATE OR REPLACE TYPE BODY freguesia_t AS
    MEMBER FUNCTION total_votos RETURN NUMBER IS
    ret_variable NUMBER;
    BEGIN
        SELECT SUM(value(v).votos) INTO ret_variable FROM table(SELF.votacoes) v;
        RETURN ret_variable;
    END total_votos;
    
    OVERRIDING MEMBER FUNCTION votos_partido(sigla_partido VARCHAR2) RETURN NUMBER IS
    ret_variable NUMBER;
    BEGIN
        SELECT NVL(SUM(value(v).votos), 0) INTO ret_variable FROM table(SELF.votacoes) v WHERE value(v).partido.sigla = sigla_partido;
        RETURN ret_variable;
    END votos_partido;
END;
/

----------------------------------
--concelho------------------------
----------------------------------
ALTER TYPE concelho_t ADD MEMBER FUNCTION total_votos RETURN NUMBER CASCADE;
/
CREATE OR REPLACE TYPE BODY concelho_t AS
    MEMBER FUNCTION total_votos RETURN NUMBER IS
    ret_variable NUMBER;
    BEGIN
        SELECT SUM(value(v).votos) INTO ret_variable FROM table(SELF.freguesias) f, table(value(f).votacoes) v;
        RETURN ret_variable;
    END total_votos;
    
    OVERRIDING MEMBER FUNCTION votos_partido(sigla_partido VARCHAR2) RETURN NUMBER IS
    ret_variable NUMBER;
    BEGIN
        SELECT NVL(SUM(value(v).votos), 0) INTO ret_variable FROM table(SELF.freguesias) f, table(value(f).votacoes) v WHERE value(v).partido.sigla = sigla_partido;
        RETURN ret_variable;
    END votos_partido;

END;
/

----------------------------------
--distrito------------------------
----------------------------------
ALTER TYPE distrito_t ADD MEMBER FUNCTION total_votos RETURN NUMBER CASCADE;
ALTER TYPE distrito_t ADD MEMBER FUNCTION integrity RETURN NUMBER CASCADE;
/
CREATE OR REPLACE TYPE BODY distrito_t AS
    MEMBER FUNCTION total_votos RETURN NUMBER IS
    ret_variable NUMBER;
    BEGIN
        SELECT SUM(value(v).votos) INTO ret_variable FROM table(SELF.concelhos) c, table(value(c).freguesias) f, table(value(f).votacoes) v;
        RETURN ret_variable;
    END total_votos;
    
    MEMBER FUNCTION integrity RETURN NUMBER IS
    ret_variable NUMBER;
    BEGIN
        IF SELF.total_votos() + SELF.participacao.abstencoes + SELF.participacao.brancos + SELF.participacao.nulos !=  SELF.participacao.inscritos THEN
            ret_variable := 0;
        ELSE
            ret_variable := 1;
        END IF;
        RETURN ret_variable;
    END integrity;
    
    OVERRIDING MEMBER FUNCTION votos_partido(sigla_partido VARCHAR2) RETURN NUMBER IS
    ret_variable NUMBER;
    BEGIN
        SELECT NVL(SUM(value(v).votos), 0) INTO ret_variable FROM table(SELF.concelhos) c, table(value(c).freguesias) f, table(value(f).votacoes) v WHERE value(v).partido.sigla = sigla_partido;
        RETURN ret_variable;
    END votos_partido;
    
END;
/
----------------------------------
--partido-------------------------
----------------------------------
ALTER TYPE partido_t ADD MEMBER FUNCTION total_votos RETURN NUMBER CASCADE;
ALTER TYPE partido_t ADD MEMBER FUNCTION total_mandatos RETURN NUMBER CASCADE;
/
CREATE OR REPLACE TYPE BODY partido_t AS
    MEMBER FUNCTION total_votos RETURN NUMBER IS
    ret_variable NUMBER;
    BEGIN
        SELECT NVL(SUM(value(v).votos), 0) INTO ret_variable FROM table(SELF.votacoes) v;
        RETURN ret_variable;
    END total_votos;
    
   MEMBER FUNCTION total_mandatos RETURN NUMBER IS
    ret_variable NUMBER;
    BEGIN
        SELECT NVL(SUM(value(l).mandatos), 0) INTO ret_variable FROM table(SELF.listas) l;
        RETURN ret_variable;
    END total_mandatos;
    
END;
/

