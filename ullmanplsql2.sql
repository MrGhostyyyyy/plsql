-- feladatok: https://people.inf.elte.hu/nikovits/AB1/feladat8_plsql.txt

CREATE OR REPLACE FUNCTION kat_atlag(n integer) RETURN number IS
    average_fiz number;
BEGIN
    SELECT AVG(fizetes) INTO average_fiz
    FROM nikovits.dolgozo, nikovits.fiz_kategoria
    WHERE kategoria = n AND fizetes >= also 
    AND fizetes <= felso;
    return average_fiz;
END;
/

SELECT kat_atlag(2) FROM dual;

----------------------------------

CREATE OR REPLACE PROCEDURE nap_atl(d varchar2) IS
    count_of_employees number;
    average_fiz number;
BEGIN
    SELECT AVG(FIZETES), COUNT(DKOD) INTO average_fiz, count_of_employees 
    FROM nikovits.dolgozo
    WHERE TRIM(TO_CHAR(belepes, 'Day', 'nls_date_language=hungarian')) = d;
    dbms_output.put_line('Atlag: ' || average_fiz || ' Mennyi ember: ' || count_of_employees);
END;
/

set serveroutput on
call nap_atl('Csütörtök');

------------------------------------
CREATE OR REPLACE FUNCTION min_fizetes_in_oazon(oaz NUMBER)RETURN NUMBER IS
    min_fiz number;
BEGIN
    SELECT MIN(FIZETES) INTO min_fiz
    FROM NIKOVITS.DOLGOZO
    WHERE OAZON = oaz;
    
    return min_fiz;
END;
/

CREATE OR REPLACE PROCEDURE kat_novel(p_kategoria NUMBER) IS
    atlag number;
BEGIN
    UPDATE DOLGOZO
    SET fizetes = fizetes + (SELECT min_fizetes_in_oazon(oazon) from dual)
    WHERE dnev IN           (SELECT dnev FROM NIKOVITS.dolgozo, nikovits.fiz_kategoria
                             WHERE fizetes between also and felso and kategoria = p_kategoria);
    SELECT ROUND(AVG(FIZETES), 2) INTO atlag FROM DOLGOZO;
    DBMS_OUTPUT.PUT_LINE('Átlag: ' || atlag);
    ROLLBACK;    
END;
/

set serveroutput on
execute kat_novel(2);

------------------------------
SELECT DISTINCT FOGLALKOZAS, DNEV
FROM NIKOVITS.DOLGOZO
NATURAL JOIN NIKOVITS.OSZTALY
WHERE ONEV = 'ACCOUNTING'
ORDER BY DNEV;

CREATE OR REPLACE PROCEDURE print_foglalkozas(o_nev varchar2) IS 
    text_ varchar2(255):= '';
    temp varchar2(255) := '';
    
    CURSOR dolg_cursor IS        
        SELECT DISTINCT FOGLALKOZAS, DNEV
        FROM NIKOVITS.DOLGOZO
        NATURAL JOIN NIKOVITS.OSZTALY
        WHERE ONEV = o_nev
        ORDER BY DNEV;
BEGIN
    FOR dolg_record IN dolg_cursor LOOP
        text_ := text_ || temp || dolg_record.foglalkozas;            
        temp := '-';
    END LOOP;
    DBMS_OUTPUT.PUT_LINE(text_);
END;
/

set serveroutput on
call print_foglalkozas('ACCOUNTING');

----------------------------

CREATE OR REPLACE FUNCTION get_foglalkozas(o_nev varchar2) RETURN varchar2 IS
    text_ varchar2(255):= '';
    temp varchar2(255) := '';
    
    CURSOR dolg_cursor IS        
        SELECT DISTINCT FOGLALKOZAS, DNEV
        FROM NIKOVITS.DOLGOZO
        NATURAL JOIN NIKOVITS.OSZTALY
        WHERE ONEV = o_nev
        ORDER BY DNEV;
BEGIN
    FOR dolg_record IN dolg_cursor LOOP
        text_ := text_ || temp || dolg_record.foglalkozas;            
        temp := '-';
    END LOOP;
    RETURN text_;
END;
/

SELECT get_foglalkozas('ACCOUNTING') FROM dual;

-----------------------------------------
create or replace FUNCTION prim(n integer)
RETURN number IS
BEGIN
    IF n = 0 OR n = 1 THEN
        return 0;
    END IF;

    FOR i IN 2..SQRT(n-1) LOOP
        IF n MOD i = 0 THEN
            RETURN 0;
        END IF;
    END LOOP;

    RETURN 1;
END;
/

CREATE OR REPLACE PROCEDURE primes(n integer) IS
    TYPE prime_table_type IS TABLE OF INTEGER
    INDEX BY BINARY_INTEGER;
    
    prime_table prime_table_type;
    prime_index integer := 2;
    prime_counter integer := 0;
    
    is_prime boolean;
BEGIN
    FOR i IN 0..n-1 LOOP
        is_prime := false;
        WHILE NOT is_prime LOOP
            IF prim(prime_index) = 1 THEN
                prime_table(i) := prime_index;
                prime_counter := prime_counter + prime_index;
                is_prime := true;
            END IF;
            prime_index := prime_index + 1;
        END LOOP;
    END LOOP;
    DBMS_OUTPUT.PUT_LINE('last elem: ' || prime_table(prime_table.LAST));
    DBMS_OUTPUT.PUT_LINE('SUM: ' || prime_counter);
END;
/

set serveroutput on
execute primes(100);

----------------------------

CREATE OR REPLACE PROCEDURE curs_tomb IS
    TYPE odd_workers_type IS TABLE OF INTEGER
    INDEX BY VARCHAR2(255);
    
    odd_workers odd_workers_type;
    
    CURSOR dolg_cursor IS
        SELECT dnev, fizetes
        FROM NIKOVITS.DOLGOZO
        ORDER BY DNEV;
        
    index_ integer := 1;
    
    last_key varchar(255);
    current_key varchar(255);
BEGIN
    FOR DOLG_RECORD IN DOLG_CURSOR LOOP
        IF index_ mod 2 <> 0 THEN
            odd_workers(dolg_record.dnev) := dolg_record.fizetes;
        END IF;
        index_ := index_ + 1;
    END LOOP;
    
    current_key := odd_workers.FIRST;
    WHILE current_key IS NOT NULL LOOP
        IF odd_workers.NEXT(current_key) IS NOT NULL THEN
            last_key := current_key;
        END IF;
        current_key := odd_workers.NEXT(current_key);
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('utolsó elõtti ember: ' || last_key);
    DBMS_OUTPUT.PUT_LINE('utolsó elõtti ember fizetése: ' || odd_workers(last_key));
END;
/

set serveroutput on
execute curs_tomb();