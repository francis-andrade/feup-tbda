SET TIMING OFF;
SELECT a.numero AS "Aluno (BI)", a.a_lect_conclusao - a.a_lect_matricula AS "Anos Demorados" 
FROM zalus a JOIN zlics l  ON a.curso = l.codigo 
WHERE a.estado = 'C' AND a.a_lect_conclusao - a.a_lect_matricula < 5 AND l.sigla = 'EIC';
