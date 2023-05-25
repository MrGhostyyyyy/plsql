SELECT * FROM NIKOVITS.VAGYONOK;
/* START WITH CONNECT BY 
�rjunk meg egy proced�r�t, amelyik a NIKOVITS.VAGYONOK t�bla alapj�n ki�rja azoknak
a szem�lyeknek a nev�t, akikre igaz, hogy van olyan lesz�rmazottjuk, akinek nagyobb
a vagyona, mint az illet� vagyona.
*/
CREATE OR REPLACE PROCEDURE gazdag_leszarmazott IS

    CURSOR parent_curs IS
        SELECT nev FROM nikovits.vagyonok;
        
    PROCEDURE leszarmazott(szulo nikovits.vagyonok.nev%TYPE) IS
        szulo_vagyon NUMBER;
        CURSOR curs IS
            SELECT nev, vagyon FROM nikovits.vagyonok
            START WITH apja=szulo
            CONNECT BY PRIOR nev = apja;
    BEGIN
        select vagyon into szulo_vagyon
        from nikovits.vagyonok
        where nev = szulo;
        
        FOR c_rec IN curs LOOP
            IF szulo_vagyon < c_rec.vagyon THEN
                DBMS_OUTPUT.put_line('     ' || c_rec.nev );
            END IF;
        END LOOP;
    END leszarmazott;
BEGIN
    FOR v_rec IN parent_curs LOOP
        DBMS_OUTPUT.put_line(v_rec.nev || ' gazdagabb lesz?rmazottai:');
        leszarmazott(v_rec.nev);
    END LOOP;
END;
/

set serveroutput on
execute gazdag_leszarmazott();

----------------------------------------

/*
�rjunk meg egy proced�r�t, amelyik a NIKOVITS.VAGYONOK t�bla alapj�n ki�rja azoknak
a szem�lyeknek a nev�t, vagyon�t, valamint lesz�rmazottainak �tlagos vagyon�t, akikre igaz, 
hogy a lesz�rmazottainak �tlagos vagyona nagyobb, mint az illet� vagyona.
A program teh�t soronk�nt 3 adatot �r ki: n�v, vagyon, lesz�rmazottak �tlagos vagyona
*/
CREATE OR REPLACE PROCEDURE gazdag_leszarmazottak IS
    CURSOR outer_cursor IS
        SELECT NEV, VAGYON, APJA 
        FROM NIKOVITS.VAGYONOK;

    PROCEDURE helper(szulo nikovits.vagyonok.nev%TYPE) IS
        szulo_vagyona NUMBER := 0;
        gyerekek_vagyona NUMBER := 0;
        gyerekek_szama NUMBER := 0;
        CURSOR inner_cursor IS
            SELECT VAGYON, nev FROM NIKOVITS.VAGYONOK
            START WITH APJA = SZULO
            CONNECT BY PRIOR NEV = apja;
    BEGIN
        FOR INNER_CURSOR_REC IN INNER_CURSOR LOOP
            SELECT vagyon INTO szulo_vagyona
            FROM nikovits.vagyonok
            WHERE INNER_CURSOR_REC.nev = nev;
            
            if inner_cursor_rec.nev != szulo then
                GYEREKEK_VAGYONA := GYEREKEK_VAGYONA + INNER_CURSOR_REC.VAGYON;
                GYEREKEK_SZAMA := GYEREKEK_SZAMA + 1;
            end if;
        END LOOP;
        IF GYEREKEK_SZAMA != 0 AND SZULO_VAGYONA < GYEREKEK_VAGYONA / GYEREKEK_SZAMA THEN
            DBMS_OUTPUT.PUT_LINE('GYEREKEK ATLAGA: ' || (GYEREKEK_VAGYONA / GYEREKEK_SZAMA));
        END IF;
    END;
BEGIN
    FOR outer_cursor_rec IN outer_cursor LOOP
        helper(outer_cursor_rec.nev);
    END LOOP;
END;
/

set serveroutput on
execute gazdag_leszarmazottak();