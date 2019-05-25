create or replace package export_cultural_facilities as
procedure export_db;
end export_cultural_facilities;

create or replace package body export_cultural_facilities as
function get_activities(facility_id gtd8.facilities.id%type) return clob is
v_clob clob := '';
begin
for activity in (select a.activity as a_name from gtd8.uses u inner join gtd8.activities a on u.ref = a.ref where u.id = facility_id) loop
v_clob := v_clob || to_clob('<ACTIVITIES>' || activity.a_name || '</ACTIVITIES>');
end loop;
return v_clob;
end get_activities;

function get_facilities(municipality_cod gtd8.municipalities.cod%type) return clob is
v_clob clob := '';
begin
for facility in (select f.id as f_id, f.name as f_name, f.capacity as f_cap, r.description as r_des, f.address as f_addr from gtd8.facilities f inner join gtd8.roomtypes r on f.roomtype = r.roomtype where f.municipality = municipality_cod) loop
v_clob := v_clob || to_clob('<FACILITIES>');
v_clob := v_clob || to_clob('<ID>' || facility.f_id || '</ID>');
v_clob := v_clob || to_clob('<NAME>' || facility.f_name || '</NAME>');
v_clob := v_clob || to_clob('<CAPACITY>' || facility.f_cap || '</CAPACITY>');
v_clob := v_clob || to_clob('<ROOMTYPE>' || facility.r_des || '</ROOMTYPE>');
v_clob := v_clob || to_clob('<ADDRESS>' || facility.f_addr || '</ADDRESS>');
v_clob := v_clob || get_activities(facility.f_id);
v_clob := v_clob || to_clob('</FACILITIES>');
end loop;
return v_clob;
end get_facilities;

function get_municipalities(district_cod gtd8.districts.cod%type) return clob is
v_clob clob := '';
begin
for municipality in (select m.cod as m_cod, m.designation as m_des, r.cod as r_cod, r.designation as r_des, r.nut1 as r_nut1 from gtd8.municipalities m inner join gtd8.regions r on m.region = r.cod where m.district = district_cod) loop
v_clob := v_clob || to_clob('<MUNICIPALITIES>');
v_clob := v_clob || to_clob('<COD>' || municipality.m_cod || '</COD>');
v_clob := v_clob || to_clob('<DESIGNATION>' || municipality.m_des || '</DESIGNATION>');
v_clob := v_clob || to_clob('<REGION>');
v_clob := v_clob || to_clob('<COD>' || municipality.r_cod || '</COD>');
v_clob := v_clob || to_clob('<DESIGNATION>' || municipality.r_des || '</DESIGNATION>');
v_clob := v_clob || to_clob('<NUT1>' || municipality.r_nut1 || '</NUT1>');
v_clob := v_clob || to_clob('</REGION>');
v_clob := v_clob || get_facilities(municipality.m_cod);
v_clob := v_clob || to_clob('</MUNICIPALITIES>');
end loop;
return v_clob;
end get_municipalities;

procedure export_db is
v_clob clob := '';
v_offset number default 1;
v_chunk_size number := 3500;
begin
v_clob := v_clob || to_clob('<?xml version="1.0" encoding="iso-8859-1" ?>');
v_clob := v_clob || to_clob('<DATA>');
for district in (select d.cod as d_cod, d.designation as d_des from gtd8.districts d) loop
v_clob := v_clob || to_clob('<DISTRICTS>');
v_clob := v_clob || to_clob('<_ID>' || district.d_cod || '</_ID>');
v_clob := v_clob || to_clob('<DESIGNATION>' || district.d_des || '</DESIGNATION>');
v_clob := v_clob || get_municipalities(district.d_cod);
v_clob := v_clob || to_clob('</DISTRICTS>');
end loop;
v_clob := v_clob || to_clob('</DATA>');
loop
      exit when v_offset > dbms_lob.getlength(v_clob);
      insert into db_export values (to_clob(dbms_lob.substr(v_clob, v_chunk_size, v_offset)));
      v_offset := v_offset +  v_chunk_size;
end loop;
EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line(SQLERRM); 
end export_db;
end export_cultural_facilities;
