create or replace package export_cultural_facilities as
procedure get_municipalities(district_cod gtd8.districts.cod%type);
procedure get_facilities(municipality_cod gtd8.municipalities.cod%type);
procedure get_activities(facility_id gtd8.facilities.id%type);
procedure export_db;
end export_cultural_facilities;

create or replace package body export_cultural_facilities as

procedure get_municipalities(district_cod gtd8.districts.cod%type) is
begin
dbms_output.enable(null);
for municipality in (select m.cod as m_cod, m.designation as m_des, r.cod as r_cod, r.designation as r_des, r.nut1 as r_nut1 from gtd8.municipalities m inner join gtd8.regions r on m.region = r.cod where m.district = district_cod) loop
dbms_output.put_line('<MUNICIPALITIES>');
dbms_output.put_line('<COD>' || municipality.m_cod || '</COD>');
dbms_output.put_line('<DESIGNATION>' || municipality.m_des || '</DESIGNATION>');
dbms_output.put_line('<REGION>');
dbms_output.put_line('<COD>' || municipality.r_cod || '</COD>');
dbms_output.put_line('<DESIGNATION>' || municipality.r_des || '</DESIGNATION>');
dbms_output.put_line('<NUT1>' || municipality.r_nut1 || '</NUT1>');
dbms_output.put_line('</REGION>');

get_facilities(municipality.m_cod);

dbms_output.put_line('</MUNICIPALITIES>');
end loop;
end get_municipalities;

procedure get_facilities(municipality_cod gtd8.municipalities.cod%type) is
begin
dbms_output.enable(null);
for facility in (select f.id as f_id, f.name as f_name, f.capacity as f_cap, r.description as r_des, f.address as f_addr from gtd8.facilities f inner join gtd8.roomtypes r on f.roomtype = r.roomtype where f.municipality = municipality_cod) loop
dbms_output.put_line('<FACILITIES>');
dbms_output.put_line('<ID>' || facility.f_id || '</ID>');
dbms_output.put_line('<NAME>' || facility.f_name || '</NAME>');
dbms_output.put_line('<CAPACITY>' || facility.f_cap || '</CAPACITY>');
dbms_output.put_line('<ROOMTYPE>' || facility.r_des || '</ROOMTYPE>');
dbms_output.put_line('<ADDRESS>' || facility.f_addr || '</ADDRESS>');

get_activities(facility.f_id);

dbms_output.put_line('</FACILITIES>');
end loop;
end get_facilities;

procedure get_activities(facility_id gtd8.facilities.id%type) is
begin
dbms_output.enable(null);
for activity in (select a.activity as a_name from gtd8.uses u inner join gtd8.activities a on u.ref = a.ref where u.id = facility_id) loop
dbms_output.put_line('<ACTIVITIES>' || activity.a_name || '</ACTIVITIES>');
end loop;
end get_activities;

procedure export_db is
begin
dbms_output.enable(null);
dbms_output.put_line('<?xml version="1.0" encoding="iso-8859-1" ?>');
dbms_output.put_line('<DATA>');
for district in (select d.cod as d_cod, d.designation as d_des, r.cod as r_cod, r.designation as r_des, r.nut1 as r_nut1 from gtd8.districts d left join gtd8.regions r on d.region = r.cod offset 19 rows fetch next row only) loop
dbms_output.put_line('<DISTRICTS>');
dbms_output.put_line('<_ID>' || district.d_cod || '</_ID>');
dbms_output.put_line('<DESIGNATION>' || district.d_des || '</DESIGNATION>');

if district.r_cod is not null then
dbms_output.put_line('<REGION>');
dbms_output.put_line('<COD>' || district.r_cod || '</COD>');
dbms_output.put_line('<DESIGNATION>' || district.r_des || '</DESIGNATION>');
dbms_output.put_line('<NUT1>' || district.r_nut1 || '</NUT1>');
dbms_output.put_line('</REGION>');
end if;

get_municipalities(district.d_cod);

dbms_output.put_line('</DISTRICTS>');
end loop;
dbms_output.put_line('</DATA>');

EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line(SQLERRM); 
end export_db;

end export_cultural_facilities;
