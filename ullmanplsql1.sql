CREATE OR REPLACE FUNCTION prim(n integer)
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

SELECT prim(26388279066623) from dual;
-- proced�ra
-- CREATE OR REPLACE PROCEDURE az megcsin�lja/fel�lirja
-- azt�n f�ggv�ny_n�v(param�terek)
--  defaultban IN a param�ter (n IN number)
--             IN read only csak beolvassa a proced�ra, nem m�dositja
--  lehet:     OUT csak kimenet, ebbe updatelt �rt�ket visszaadja
--             IN OUT bemenetk�nt megkapja, majd m�dositva fogja "visszaadni"
-- fontos hogy itt nincs return oper�tor
-- IS ut�n j�hetnek a seg�dv�ltoz� deklar�ci�k
-- n�v tipus := �rt�k
CREATE OR REPLACE PROCEDURE fib(n integer) IS
    a INTEGER := 0;
    b INTEGER := 1;
-- BEGIN ebbe j�n a proced�ra/f�ggv�ny implement�ci�ja, lehetnek itt ciklusok, if �llit�sok kb minden
BEGIN
    -- IF STATEMENT
    -- SYNTAX: IF akarmi THEN do something END IF;
    IF N = 0 OR N = 1 THEN
        DBMS_OUTPUT.PUT_LINE(n);
    END IF;
    
    -- lehet sima LOOP
    -- WHILE LOOP
    -- rakni labeleket, �s azokra a loopban ugrani is lehet
    -- <<outer loop>>
    -- olyan mint egy break
    
    -- FOR LOOP
    -- SYNTAX: FOR valtozo IN (REVERSE (ha visszafele kell)) kezdet .. v�g LOOP 
    --      valami
    -- END LOOP;
    FOR i IN 1..n LOOP
        b := b + a;
        a := b - a;
    END LOOP;

    -- script outputra kiiratja azt amit megadunk neki procedur�n�l j�n j�l
    DBMS_OUTPUT.PUT_LINE('10th fib num: ' || a);
    
-- k�telez�en END; /-el z�rjuk a v�g�t
END;
/

-- sort�r�s itt fontos am nem fut le
set serveroutput on
execute fib(10);

-- f�ggv�ny szignat�ra
-- CREATE OR REPLACE FUNCTION megcsin�lja vagy fel�lirja a f�ggv�nyt
-- f�ggv�nyn�v(v�ltoz�k)
-- RETURN tipus IS visszat�r�s tipus�t itt megadjuk
-- az IS ut�n j�hetnek a deklar�ci�k
CREATE OR REPLACE FUNCTION lnko(p1 integer, p2 integer)
RETURN number IS
    temp integer;
    a integer := p1;
    b integer := p2;
BEGIN
    WHILE b > 0 LOOP
        temp := b;
        b := a mod b;
        a := temp;
    END LOOP;
    RETURN a;
END;
/

-- tesztel�sre egy dummy t�bla van "dual" n�ven
SELECT lnko(3570,7293) FROM dual;

CREATE OR REPLACE FUNCTION faktor(n integer)
RETURN integer IS
    a integer := 1;
BEGIN
    IF n = 0 THEN
        RETURN 1;
    END IF;
    
    FOR i IN 1..n LOOP
        a := a * i;
    END LOOP;
    
    RETURN a;
END;
/

SELECT faktor(10) FROM dual;

CREATE OR REPLACE FUNCTION hanyszor(p1 VARCHAR2, p2 VARCHAR2)
RETURN INTEGER IS
    v_count INTEGER := 0;
    v_index INTEGER := 1;
BEGIN
    LOOP
        -- ha benne van akkor arra az indexre megy
        v_index := INSTR(p1, p2, v_index);
        -- ha nincs benne akkor INSTR 0 lesz �s kil�p
        EXIT WHEN v_index = 0;
        -- mivel benne van countert n�velj�k
        v_count := v_count + 1;
        -- mivel az INSTR a kezdeti pozira megy ez�rt ugorni kell
        --annyit amennyi a keresett sz� hossza,
        -- hogy ne sz�molja k�tszer
        v_index := v_index + LENGTH(p2);
    END LOOP;
    RETURN v_count;
END;
/

SELECT hanyszor('ab c ab ab de ab fg', 'ab') FROM dual;

CREATE OR REPLACE FUNCTION osszeg(p_char VARCHAR2) RETURN NUMBER IS
  sum_val NUMBER := 0;
  num_str VARCHAR2(100);
  num_val NUMBER;
BEGIN
  num_str := p_char;
  
  -- Elt�vol�tjuk a felesleges sz�k�z�ket
  num_str := REPLACE(num_str, ' ', '');

  -- A '+' karakterrel elv�lasztott r�szekre bontjuk a karakterl�ncot (ha nincs + akkor kil�p mert instr 0 lesz)
  WHILE INSTR(num_str, '+') > 0 LOOP
    -- TO_NUMBER �talakitja a stringet numberr�
    -- substr megkeresi hogy hol van + �s az el�tte l�v� stringet n�zi sz�mk�nt (emiatt j� a minusz is, mert 1-t�l + el�tti r�szig vizsg�l)
    num_val := TO_NUMBER(SUBSTR(num_str, 1, INSTR(num_str, '+')-1));
    -- hozz�adja a sz�mot
    sum_val := sum_val + num_val;
    -- kidobja a feldolgozott stringet
    num_str := SUBSTR(num_str, INSTR(num_str, '+')+1);
  END LOOP;
  
  -- A marad�k r�szt is hozz�adjuk az �sszeghez
  num_val := TO_NUMBER(num_str);
  sum_val := sum_val + num_val;
  
  RETURN sum_val;
END;
/

SELECT osszeg('1 + 4 + 13 + -1 + 0') FROM dual;