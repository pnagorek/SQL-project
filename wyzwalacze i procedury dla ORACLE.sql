create or replace trigger udzielRabatu 
after insert 
on paczka
for each row
declare 
    v_nid klient.idklient%type;
    v_change boolean := false;
    v_imie klient.imie%type;
    v_nazwisko klient.nazwisko%type;
    v_rabat nadawca.rabat%type;
    v_z number;
begin 
    select idklient into v_nid from klient where idklient = :new.idnadawca;
    select count(*) into v_z from nadawca where idnadawca = v_nid;
    if v_z > 0 then 
        update nadawca set rabat = rabat + 0.1 where idnadawca = v_nid;
        update nadawca set iloscpaczek = iloscpaczek + 1 where idnadawca = v_nid;
        v_change := true;
    end if;     
    select imie, nazwisko into v_imie, v_nazwisko from klient where idklient = v_nid;   
    if(v_change) then
        select rabat into v_rabat from nadawca where idnadawca = v_nid;
        dbms_output.put_line('Zwiekszono rabat dla ' || v_imie || ' ' || v_nazwisko || ', który wynosi obecnie: ' || v_rabat);
    else 
        insert into nadawca(idnadawca, rabat, iloscpaczek) values (v_nid, 0.1, 1);
        dbms_output.put_line('Dodano nowego nadawce: ' || v_imie || ' ' || v_nazwisko);
    end if;
end;