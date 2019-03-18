DROP TABLE xlics CASCADE CONSTRAINTS;
DROP TABLE xcands CASCADE CONSTRAINTS;
DROP TABLE xalus CASCADE CONSTRAINTS;
DROP TABLE xanos CASCADE CONSTRAINTS;

DROP TABLE ylics CASCADE CONSTRAINTS;
DROP TABLE ycands CASCADE CONSTRAINTS;
DROP TABLE yalus CASCADE CONSTRAINTS;
DROP TABLE yanos CASCADE CONSTRAINTS;

DROP TABLE zlics CASCADE CONSTRAINTS;
DROP TABLE zcands CASCADE CONSTRAINTS;
DROP TABLE zalus CASCADE CONSTRAINTS;
DROP TABLE zanos CASCADE CONSTRAINTS;

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

-- indexes
-- Question 1
--Cost 3 
CREATE INDEX q1_alus ON zalus(estado, a_lect_conclusao - a_lect_matricula, curso);
CREATE INDEX q1_lics ON zlics(codigo, sigla);

/* --Cost 3 
CREATE INDEX q1_alus ON zalus(estado, a_lect_conclusao - a_lect_matricula, curso);
CREATE INDEX q1_lics ON zlics(sigla, codigo);
*/
/* --Cost 5
CREATE INDEX q1_alus ON zalus(estado, a_lect_conclusao - a_lect_matricula);
CREATE INDEX q1_lics ON zlics(sigla);
*/

-- Question 2
-- Reduces cost from 34 (both in X and Y) to 18
create unique index q2_alus on zalus (curso, a_lect_matricula, bi);

SET TIMING ON;
SET AUTOTRACE TRACE EXPLAIN;
SET AUTOTRACE ON EXPLAIN;
