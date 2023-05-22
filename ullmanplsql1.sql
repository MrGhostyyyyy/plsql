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
-- procedúra
-- CREATE OR REPLACE PROCEDURE az megcsinálja/felülirja
-- aztán függvény_név(paraméterek)
--  defaultban IN a paraméter (n IN number)
--             IN read only csak beolvassa a procedúra, nem módositja
--  lehet:     OUT csak kimenet, ebbe updatelt értéket visszaadja
--             IN OUT bemenetként megkapja, majd módositva fogja "visszaadni"
-- fontos hogy itt nincs return operátor
-- IS után jöhetnek a segédváltozó deklarációk
-- név tipus := érték
CREATE OR REPLACE PROCEDURE fib(n integer) IS
    a INTEGER := 0;
    b INTEGER := 1;
-- BEGIN ebbe jön a procedúra/függvény implementációja, lehetnek itt ciklusok, if állitások kb minden
BEGIN
    -- IF STATEMENT
    -- SYNTAX: IF akarmi THEN do something END IF;
    IF N = 0 OR N = 1 THEN
        DBMS_OUTPUT.PUT_LINE(n);
    END IF;
    
    -- lehet sima LOOP
    -- WHILE LOOP
    -- rakni labeleket, és azokra a loopban ugrani is lehet
    -- <<outer loop>>
    -- olyan mint egy break
    
    -- FOR LOOP
    -- SYNTAX: FOR valtozo IN (REVERSE (ha visszafele kell)) kezdet .. vég LOOP 
    --      valami
    -- END LOOP;
    FOR i IN 1..n LOOP
        b := b + a;
        a := b - a;
    END LOOP;

    -- script outputra kiiratja azt amit megadunk neki proceduránál jön jól
    DBMS_OUTPUT.PUT_LINE('10th fib num: ' || a);
    
-- kötelezõen END; /-el zárjuk a végét
END;
/

-- sortörés itt fontos am nem fut le
set serveroutput on
execute fib(10);

-- függvény szignatúra
-- CREATE OR REPLACE FUNCTION megcsinálja vagy felülirja a függvényt
-- függvénynév(változók)
-- RETURN tipus IS visszatérés tipusát itt megadjuk
-- az IS után jöhetnek a deklarációk
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

-- tesztelésre egy dummy tábla van "dual" néven
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
        -- ha nincs benne akkor INSTR 0 lesz és kilép
        EXIT WHEN v_index = 0;
        -- mivel benne van countert növeljük
        v_count := v_count + 1;
        -- mivel az INSTR a kezdeti pozira megy ezért ugorni kell
        --annyit amennyi a keresett szó hossza,
        -- hogy ne számolja kétszer
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
  
  -- Eltávolítjuk a felesleges szóközöket
  num_str := REPLACE(num_str, ' ', '');

  -- A '+' karakterrel elválasztott részekre bontjuk a karakterláncot (ha nincs + akkor kilép mert instr 0 lesz)
  WHILE INSTR(num_str, '+') > 0 LOOP
    -- TO_NUMBER átalakitja a stringet numberré
    -- substr megkeresi hogy hol van + és az elõtte lévõ stringet nézi számként (emiatt jó a minusz is, mert 1-tõl + elõtti részig vizsgál)
    num_val := TO_NUMBER(SUBSTR(num_str, 1, INSTR(num_str, '+')-1));
    -- hozzáadja a számot
    sum_val := sum_val + num_val;
    -- kidobja a feldolgozott stringet
    num_str := SUBSTR(num_str, INSTR(num_str, '+')+1);
  END LOOP;
  
  -- A maradék részt is hozzáadjuk az összeghez
  num_val := TO_NUMBER(num_str);
  sum_val := sum_val + num_val;
  
  RETURN sum_val;
END;
/

SELECT osszeg('1 + 4 + 13 + -1 + 0') FROM dual;