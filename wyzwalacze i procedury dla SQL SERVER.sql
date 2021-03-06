CREATE TRIGGER PRZYZNAJRABAT
ON PACZKA 
FOR INSERT
AS
BEGIN 
DECLARE CUR CURSOR FOR SELECT IDNADAWCA FROM INSERTED
DECLARE @ID INT, @IMIE VARCHAR(50), @NAZWISKO VARCHAR(50), @RABAT DECIMAL(2,1);
OPEN CUR
FETCH NEXT FROM CUR INTO @ID
WHILE @@FETCH_STATUS = 0
    BEGIN
        IF (SELECT 1 FROM NADAWCA WHERE IDNADAWCA = @ID) IS NOT NULL
            BEGIN
                UPDATE NADAWCA SET RABAT = RABAT + 0.1 WHERE IDNADAWCA = @ID
                UPDATE NADAWCA SET ILOSCPACZEK = ILOSCPACZEK + 1 WHERE IDNADAWCA = @ID
                SELECT @IMIE = IMIE, @NAZWISKO = NAZWISKO, @RABAT = RABAT FROM KLIENT JOIN NADAWCA ON NADAWCA.IDNADAWCA = KLIENT.IDKLIENT WHERE IDKLIENT = @ID
                SELECT 'PRZYZNANO RABAT DLA: ' + @IMIE +  ' ' + @NAZWISKO + ', W WYSOKOSCI: ' + CAST(@RABAT AS VARCHAR);
            END
        ELSE
            BEGIN                
                INSERT INTO NADAWCA (IDNADAWCA, RABAT, ILOSCPACZEK) VALUES (@ID, 0.1, 1);
                SELECT @IMIE = IMIE, @NAZWISKO = NAZWISKO, @RABAT = RABAT FROM KLIENT JOIN NADAWCA ON NADAWCA.IDNADAWCA = KLIENT.IDKLIENT WHERE IDKLIENT = @ID
                SELECT 'DODANO NOWEGO NADAWCE: ' + @IMIE +  ' ' + @NAZWISKO + ', RABAT NA POCZATEK: ' + CAST(@RABAT AS VARCHAR);
            END
        FETCH NEXT FROM CUR INTO @ID
    END
END

GO


------------------------------------------------------------------------------------

CREATE PROCEDURE ZMIANAPENSJI @BUDZET INT, @AKCJA INT
AS
BEGIN
    DECLARE @ILU INT, @ID INT;
    DECLARE CUR CURSOR FOR SELECT IDPRACOWNIK FROM PRACOWNIK;
    SELECT @ILU = COUNT(*) FROM PRACOWNIK;
    OPEN CUR;    
    FETCH NEXT FROM CUR INTO @ID
    WHILE @@FETCH_STATUS = 0
        BEGIN
            IF @AKCJA >= 0
                UPDATE PRACOWNIK SET wynagrodzenie = wynagrodzenie + @budzet / @ilu where idpracownik = @id
            ELSE
                UPDATE PRACOWNIK SET wynagrodzenie = wynagrodzenie - @budzet / @ilu where idpracownik = @id               
        FETCH NEXT FROM CUR INTO @ID
        END  
    SELECT 'ZMIANA PENSJI WSZYSTKI PRACOWNIKOW O ' +  CAST((@budzet / @ilu) AS VARCHAR)
END

GO

--------------------------------------------------------------------------------------

CREATE PROCEDURE DODAJSAMOCHOD @ID CHAR(10), @MARKA VARCHAR(20) = NULL, @ROK INT = NULL, @KM INT = NULL, @PALIWO VARCHAR(20) = NULL
AS
BEGIN
DECLARE @ILEK INT, @ILEA INT, @IDK INT;
 IF @ID NOT LIKE 'WWW ____' 
    SELECT 'ZLY FORMAT NUMERU REJESTRACYJNEGO, MUSI PASOWAC DO: "WWW xxxx"';
 ELSE    
    BEGIN 
        INSERT INTO SAMOCHOD(NRREJESTRACYJNY, MARKA, ROKPRODUKCJI, PRZEBIEG, RODZAJPALIWA) VALUES (@ID, @MARKA, @ROK, @KM, @PALIWO);
        SELECT @ILEK = COUNT(*) FROM KURIER;
        SELECT @ILEA = COUNT(*) FROM SAMOCHOD;
        IF @ILEK > @ILEA 
            BEGIN 
                SELECT TOP 1 @IDK = IDKURIER FROM KURIER WHERE IDSAMOCHOD IS NULL;
                UPDATE KURIER SET IDSAMOCHOD = @ID WHERE IDKURIER = @IDK;
                SELECT 'NOWY SAMOCHOD PRZYPISANY DO KURIERA: ' + CAST(@IDK AS VARCHAR)
            END
        ELSE 
            BEGIN
                SELECT 'LICZBA SAMOCHODOW PRZEKRACZA LICZBE KURIEROW. ZATRUDNIJ WIECEJ LUDZI"'     
            END          
    END
END;

GO

-------------------------------------------------------------------------------------------


create trigger PRZYPISZ 
on PRACOWNIK
FOR INSERT
AS
BEGIN
DECLARE CUR CURSOR FOR SELECT IDPRACOWNIK FROM INSERTED
DECLARE @ILEK INT, @ILED INT, @ID INT
    SELECT @ILEK = COUNT(*) FROM KURIER;
    SELECT @ILED = COUNT(*) FROM DYSPOZYTOR;
    OPEN CUR
    FETCH NEXT FROM CUR INTO @ID
    WHILE @@FETCH_STATUS = 0
    BEGIN    
        IF @ILEK * 3 < @ILED * 2 
            BEGIN 
                INSERT INTO KURIER(IDKURIER) VALUES (@ID);
                SELECT 'DODANO NOWEGO KURIERA';
            END
        ELSE 
            BEGIN
                INSERT INTO DYSPOZYTOR(IDDYSPOZYTOR) VALUES (@ID);
                SELECT 'DODANO NOWEGO DYSPOZYTORA';
            END
        FETCH NEXT FROM CUR INTO @ID
    END;
END;
