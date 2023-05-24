-- feladatok: https://people.inf.elte.hu/nikovits/AB1/feladat9_plsql.txt
--CREATE TABLE copy_dolgozo AS 
--(SELECT * FROM NIKOVITS.DOLGOZO);

CREATE OR REPLACE PROCEDURE fiz_mod IS 
    CURSOR osztaly_cursor IS
        SELECT oazon
        FROM nikovits.osztaly;
    
    min_belepes DATE;
    num_of_workers INTEGER;
    
    average_fizetes NUMBER;
BEGIN
    FOR osztaly_rec IN osztaly_cursor LOOP
        SELECT MIN(BELEPES) INTO min_belepes
        FROM copy_dolgozo
        WHERE oazon = osztaly_rec.oazon;
    
        SELECT COUNT(BELEPES) INTO num_of_workers
        FROM copy_dolgozo
        WHERE belepes != min_belepes 
        AND oazon = osztaly_rec.oazon;
        
        UPDATE copy_dolgozo
        SET fizetes = fizetes + (100 * num_of_workers)
        WHERE oazon = osztaly_rec.oazon AND belepes = min_belepes;
    END LOOP;
    
    SELECT ROUND(AVG(fizetes), 2) INTO average_fizetes
    FROM copy_dolgozo;
    
    DBMS_OUTPUT.PUT_LINE('Átlag: ' || average_fizetes);
    
    ROLLBACK;
END;
/

set serveroutput on
execute fiz_mod();

-----------------------------------------------
CREATE OR REPLACE FUNCTION count_maganhangzo(nev VARCHAR2) RETURN INTEGER IS
    charValue VARCHAR2(1);
    counter INTEGER := 0;
BEGIN 
    FOR i IN 1..LENGTH(nev) LOOP
        charValue := SUBSTR(nev, i, 1);
        IF charValue IN ('A', 'E', 'I', 'O', 'U') THEN
            counter := counter + 1;
        END IF;
    END LOOP;
    RETURN counter;
END;
/
    
CREATE OR REPLACE PROCEDURE fiz_mod2(p_oazon INTEGER) IS 
    CURSOR cursor_m IS
        SELECT DNEV, FIZETES, DKOD
        FROM copy_dolgozo
        WHERE oazon = p_oazon
        FOR UPDATE NOWAIT;
        
    CURSOR print_cursor IS
        SELECT DNEV, FIZETES
        FROM copy_dolgozo
        WHERE oazon = p_oazon;
    
    counter_for_maganhangzo INTEGER;
    
BEGIN
    FOR m_record IN cursor_m LOOP
        counter_for_maganhangzo := count_maganhangzo(m_record.dnev);
    
        UPDATE copy_dolgozo
        SET fizetes = fizetes + (counter_for_maganhangzo * 10000)
        WHERE dkod = m_record.dkod;
    
    END LOOP;
    
    FOR p_record IN print_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('Dolgozo: ' || p_record.dnev || ' Fizetese: ' || p_record.fizetes);
    END LOOP;
    
    ROLLBACK;
END;
/

set serveroutput on
execute fiz_mod2(10);

----------------------------------------

CREATE OR REPLACE FUNCTION nap_nev(p_kar VARCHAR2) RETURN VARCHAR2 IS
    wrong_date EXCEPTION;
    PRAGMA EXCEPTION_INIT(wrong_date, -2292);
    day_name VARCHAR2(255);
BEGIN
    IF p_kar LIKE '____.__.__' THEN
        day_name := TO_CHAR(TO_DATE(p_kar, 'yyyy.mm.dd'), 'Day', 'nls_date_language=hungarian');
    ELSIF p_kar LIKE '__.__.____' THEN
        day_name := TO_CHAR(TO_DATE(p_kar, 'dd.mm.yyyy'), 'Day', 'nls_date_language=hungarian');
    ELSE 
        RAISE wrong_date;
    END IF;
    
    RETURN day_name;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 'rossz dátum';
END;
/

SELECT nap_nev('2017.05.01'), nap_nev('02.05.2017'), nap_nev('2017.13.13') FROM dual;

---------------------------------------------

CREATE OR REPLACE PROCEDURE szamok(n number) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Reciprok: ' || 1/n);
    DBMS_OUTPUT.PUT_LINE('SQRT: ' || SQRT(n));
    DBMS_OUTPUT.PUT_LINE('FACTORIAL: ' || faktor(n));
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE(SQLCODE);
END;
/

set serveroutput on
execute szamok(0);
execute szamok(-2);
execute szamok(40);

--------------------------------------------

-- UTOLSÓ ELENGEDVE MERT NEM TUDOM XD