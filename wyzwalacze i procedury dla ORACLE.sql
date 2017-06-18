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

------------------------------------------------------------------------

create or replace procedure zmianaPensji (v_budzet int, v_akcja int)
as
    v_ilu int;
    v_id pracownik.idpracownik%type;
    cursor cur is select idpracownik from pracownik for update of wynagrodzenie;
begin   
    select count(*) into v_ilu from pracownik;
    open cur;
    loop
        fetch cur into v_id;
        exit when cur%notfound;
        if v_akcja >= 0 then
            update pracownik set wynagrodzenie = wynagrodzenie + v_budzet / v_ilu where idpracownik = v_id;
        else 
            update pracownik set wynagrodzenie = wynagrodzenie - v_budzet / v_ilu where idpracownik = v_id;
        end if;
    end loop;
    close cur;
end;


---------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE DODAJSAMOCHOD (V_ID CHAR, 
                    V_MARKA SAMOCHOD.MARKA%TYPE DEFAULT NULL, 
                    V_ROK SAMOCHOD.ROKPRODUKCJI%TYPE DEFAULT NULL, 
                    V_KM SAMOCHOD.PRZEBIEG%TYPE DEFAULT NULL, 
                    V_PALIWO SAMOCHOD.RODZAJPALIWA%TYPE DEFAULT NULL)
AS
    V_ILEAUT INT;
    V_ILUKURIEROW INT;
    V_IDK INT;
BEGIN
    IF V_ID NOT LIKE 'WWW ____' THEN
        DBMS_OUTPUT.PUT_LINE('ZLY FORMAT NUMERU REJESTRACYJNEGO, MUSI PASOWAC DO: "WWW xxxx"');
    ELSE 
        BEGIN      
            INSERT INTO SAMOCHOD(NRREJESTRACYJNY, MARKA, ROKPRODUKCJI, PRZEBIEG, RODZAJPALIWA) VALUES (V_ID, V_MARKA, V_ROK, V_KM, V_PALIWO);
            SELECT COUNT(*) INTO V_ILUKURIEROW FROM KURIER;
            SELECT COUNT(*) INTO V_ILEAUT FROM SAMOCHOD;
            IF V_ILUKURIEROW >= V_ILEAUT THEN
                SELECT IDKURIER INTO V_IDK FROM KURIER WHERE IDSAMOCHOD IS NULL AND ROWNUM = 1;
                UPDATE KURIER SET IDSAMOCHOD = V_ID WHERE IDKURIER = V_IDK;
                DBMS_OUTPUT.PUT_LINE('NOWY SAMOCHOD PRZYPISANY DO KURIERA: ' || V_IDK);
            ELSE 
                DBMS_OUTPUT.PUT_LINE('LICZBA SAMOCHODOW PRZEKRACZA LICZBE KURIEROW. ZATRUDNIJ WIECEJ LUDZI"');
            END IF;
        END;
    END IF;
END;


----------------------------------------------------------------------------------

create or replace trigger PRZYPISZ
after INSERT 
on PRACOWNIK
FOR EACH ROW
DECLARE 
    V_ILEK INT;
    V_ILED INT;
begin 
    SELECT COUNT(*) INTO V_ILEK FROM KURIER;
    SELECT COUNT(*) INTO V_ILED FROM DYSPOZYTOR;
    IF V_ILEK * 3 > V_ILED * 2 THEN 
        INSERT INTO KURIER(IDKURIER) VALUES (:NEW.IDPRACOWNIK);
        DBMS_OUTPUT.PUT_LINE('DODANO NOWEGO KURIERA');
    ELSE 
        INSERT INTO DYSPOZYTOR(IDDYSPOZYTOR) VALUES (:NEW.IDPRACOWNIK);
        DBMS_OUTPUT.PUT_LINE('DODANO NOWEGO DYSPOZYTORA');
    END IF;
end;
