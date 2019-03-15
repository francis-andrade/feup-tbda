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

