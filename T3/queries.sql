SELECT * FROM GTD8.distritos;

SELECT * FROM GTD8.municipalities;

SELECT * FROM GTD8.facilities;

SELECT * FROM GTD8.uses;

SELECT * FROM GTD8.activities;

SELECT * FROM GTD8.roomtypes;

SELECT * FROM GTD8.regions;

SELECT * FROM GTD8.municipalities WHERE region = 3;
----------------------------------
--a)------------------------------
----------------------------------
SELECT f.id AS "Facility ID", f.name AS "Facility Name", r.description AS "Room Type Description", a.activity AS "Activity"
FROM GTD8.facilities f JOIN GTD8.roomtypes r ON f.roomtype = r.roomtype 
JOIN GTD8.uses u ON f.id = u.id JOIN GTD8.activities a ON u.ref = a.ref 
WHERE r.description LIKE '%touros%' AND a.activity = 'teatro'
ORDER BY f.id;
----------------------------------
--b)------------------------------
----------------------------------
SELECT reg.designation AS "Region", COUNT(DISTINCT f.id) AS "No. Facilities"
FROM GTD8.facilities f JOIN GTD8.roomtypes r ON f.roomtype = r.roomtype 
JOIN GTD8.uses u ON f.id = u.id JOIN GTD8.activities a ON u.ref = a.ref 
JOIN GTD8.municipalities m ON f.municipality = m.cod JOIN GTD8.regions reg ON m.region = reg.cod  
WHERE r.description LIKE '%touros%'
GROUP BY reg.designation
ORDER BY reg.designation;
----------------------------------
--c)------------------------------
----------------------------------
SELECT COUNT(*) AS "No. Municipalities" FROM GTD8.municipalities m
WHERE NOT EXISTS (
    SELECT * FROM GTD8.facilities f JOIN GTD8.uses u ON f.id = u.id 
    JOIN GTD8.activities a ON u.ref = a.ref WHERE m.cod = f.municipality AND a.activity = 'cinema' 
);
----------------------------------
--d)------------------------------
----------------------------------
WITH act_facilities AS (
SELECT a.activity AS activity, m.designation AS municipality, COUNT(DISTINCT f.id) AS nr_facilities
FROM GTD8.facilities f JOIN GTD8.roomtypes r ON f.roomtype = r.roomtype 
JOIN GTD8.uses u ON f.id = u.id JOIN GTD8.activities a ON u.ref = a.ref 
JOIN GTD8.municipalities m ON f.municipality = m.cod
GROUP BY a.activity, m.designation )
SELECT aux.activity AS "Activity", aux.municipality AS "Municipality", aux.nr_facilities As "No. Facilities" 
FROM act_facilities aux
WHERE NOT EXISTS 
(SELECT * FROM act_facilities aux2 
WHERE aux2.activity = aux.activity AND aux2.nr_facilities > aux.nr_facilities)
ORDER BY aux.activity;
----------------------------------
--e)------------------------------
----------------------------------
SELECT d.cod AS "Code", d.designacao AS "Designation" 
FROM GTD8.distritos d
WHERE NOT EXISTS (
    SELECT * FROM GTD8.municipalities m WHERE d.cod = m.district AND NOT EXISTS (
        SELECT * FROM GTD8.facilities f WHERE m.cod = f.municipality
    ) 
)
ORDER BY d.cod;