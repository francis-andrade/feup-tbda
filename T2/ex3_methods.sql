----------------------------------
--DROP----------------------------
----------------------------------
ALTER TYPE zona_t DROP MEMBER FUNCTION partido_vencedor RETURN REF partido_t CASCADE;
ALTER TYPE zona_t DROP MEMBER FUNCTION ratio_votos_partido_vencedor RETURN NUMBER CASCADE;

ALTER TYPE distrito_t DROP MEMBER FUNCTION integrity RETURN NUMBER CASCADE;
ALTER TYPE distrito_t DROP MEMBER FUNCTION ratio_mandatos_partido_vencedor RETURN NUMBER CASCADE;

ALTER TYPE partido_t DROP MEMBER FUNCTION total_votos RETURN NUMBER CASCADE;
ALTER TYPE partido_t DROP MEMBER FUNCTION total_mandatos RETURN NUMBER CASCADE;
ALTER TYPE partido_t DROP MEMBER FUNCTION best_ratio_district RETURN best_ratio_ret_t CASCADE;
----------------------------------
--zona-----------------------
----------------------------------
ALTER TYPE zona_t ADD MEMBER FUNCTION partido_vencedor RETURN REF partido_t CASCADE;
ALTER TYPE zona_t ADD MEMBER FUNCTION ratio_votos_partido_vencedor RETURN NUMBER CASCADE;
/
CREATE OR REPLACE TYPE BODY zona_t AS  
    MEMBER FUNCTION partido_vencedor RETURN REF partido_t IS
    ret_variable REF partido_t;
    BEGIN
        SELECT REF(p) INTO ret_variable FROM partido p WHERE 
            NOT EXISTS (SELECT * FROM partido p2 WHERE (p.sigla != p2.sigla AND SELF.votos_partido(p.sigla) < SELF.votos_partido(p2.sigla)) OR (SELF.votos_partido(p.sigla) = SELF.votos_partido(p2.sigla) AND p.sigla > p2.sigla));
        RETURN ret_variable;
    END partido_vencedor;
    
    MEMBER FUNCTION ratio_votos_partido_vencedor RETURN NUMBER IS
    ret_variable NUMBER; tv NUMBER;
    BEGIN
        tv := SELF.total_votos();
        IF tv = 0 THEN
            RETURN 0;
        ELSE
            SELECT MAX(SELF.votos_partido(p.sigla) / tv) INTO ret_variable FROM partido p;
        END IF;
        RETURN ret_variable;
    END ratio_votos_partido_vencedor;
END;
/
----------------------------------
--freguesia-----------------------
----------------------------------
/
CREATE OR REPLACE TYPE BODY freguesia_t AS
    OVERRIDING MEMBER FUNCTION total_votos RETURN NUMBER IS
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
/
CREATE OR REPLACE TYPE BODY concelho_t AS
    OVERRIDING MEMBER FUNCTION total_votos RETURN NUMBER IS
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
ALTER TYPE distrito_t ADD MEMBER FUNCTION integrity RETURN NUMBER CASCADE;
ALTER TYPE distrito_t ADD MEMBER FUNCTION ratio_mandatos_partido_vencedor RETURN NUMBER CASCADE;
/
CREATE OR REPLACE TYPE BODY distrito_t AS
    OVERRIDING MEMBER FUNCTION total_votos RETURN NUMBER IS
    ret_variable NUMBER;
    BEGIN
        SELECT SUM(value(v).votos) INTO ret_variable FROM table(SELF.concelhos) c, table(value(c).freguesias) f, table(value(f).votacoes) v;
        RETURN ret_variable;
    END total_votos;
    
    OVERRIDING MEMBER FUNCTION votos_partido(sigla_partido VARCHAR2) RETURN NUMBER IS
    ret_variable NUMBER;
    BEGIN
        SELECT NVL(SUM(value(v).votos), 0) INTO ret_variable FROM table(SELF.concelhos) c, table(value(c).freguesias) f, table(value(f).votacoes) v WHERE value(v).partido.sigla = sigla_partido;
        RETURN ret_variable;
    END votos_partido;
    
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
    
    MEMBER FUNCTION ratio_mandatos_partido_vencedor RETURN NUMBER IS
    ret_variable NUMBER; tm NUMBER;
    BEGIN
        SELECT SUM(value(l).mandatos) INTO tm FROM table(SELF.listas) l;
        IF tm = 0 THEN
            RETURN 0;
        ELSE
            SELECT MAX(value(l).mandatos / tm) INTO ret_variable FROM partido p JOIN table(SELF.listas) l ON p.sigla = value(l).partido.sigla;
        END IF;
    RETURN ret_variable;
    END ratio_mandatos_partido_vencedor;
    
END;
/
----------------------------------
--partido-------------------------
----------------------------------
ALTER TYPE partido_t ADD MEMBER FUNCTION total_votos RETURN NUMBER CASCADE;
ALTER TYPE partido_t ADD MEMBER FUNCTION total_mandatos RETURN NUMBER CASCADE;
/
CREATE OR REPLACE TYPE best_ratio_ret_t AS OBJECT(
    ratio NUMBER,
    dist REF distrito_t
)
/
ALTER TYPE partido_t ADD MEMBER FUNCTION best_ratio_district RETURN best_ratio_ret_t CASCADE;
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
   
   MEMBER FUNCTION best_ratio_district RETURN best_ratio_ret_t IS
   ret_variable best_ratio_ret_t;

   BEGIN
       ret_variable := best_ratio_ret_t(NULL, NULL);
       SELECT tmp.refr, tmp.ratio INTO ret_variable.dist, ret_variable.ratio 
       FROM
       (SELECT  REF(d) AS refr, d.votos_partido(SELF.sigla) / d.total_votos() AS ratio FROM distrito d ORDER BY ratio DESC FETCH FIRST ROW ONLY)tmp;
       RETURN ret_variable;
   END best_ratio_district;
END;
/