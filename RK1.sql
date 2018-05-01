\c dblabs

------------------------------------------------------------------------------------
-- LAB6
------------------------------------------------------------------------------------

-- ПРОТОТИП ЗАДАНИЯ
-- 1. Сохранить первоначальное состояние таблицы Orders
-- 2. Сохранить состояние таблицы Orders без заказов, находящихся в
-- статусе F
-- 3. Сохранить состояние таблицы Orders без заказов, находящихся в
-- статусе F и номера которых меньше 10
-- 4. Произвести возврат в состояние таблицы Orders без находящихся
-- в статусе F и номера которых меньше 10, отменить последнее
-- удаление. Вывести содержимое таблицы.
-- 5. Произвести возврат в исходное состояние таблицы Orders,
-- сохранить его

------------------------------------------------------------------------------------


BEGIN WORK;

    -- Сохраним первоначальное состояние таблицы RATING
    SAVEPOINT initial_state;

----------------------------------------------------------------------
    DECLARE rating_cursor0 CURSOR FOR SELECT * FROM rating;
    FETCH ALL FROM rating_cursor0;
    CLOSE rating_cursor0;

    DELETE FROM
    rating WHERE ratingdate IS NULL;
    SAVEPOINT first_state;

----------------------------------------------------------------------
    DECLARE rating_cursor1 CURSOR FOR SELECT * FROM rating;
    FETCH ALL FROM rating_cursor1;
    CLOSE rating_cursor1;

    DELETE FROM
    rating WHERE stars <= 3;
    SAVEPOINT second_state;

----------------------------------------------------------------------
    DECLARE rating_cursor2 CURSOR FOR SELECT * FROM rating;
    FETCH ALL FROM rating_cursor2;
    CLOSE rating_cursor2;

    DELETE FROM rating;
    ROLLBACK TO SAVEPOINT second_state;

----------------------------------------------------------------------
    DECLARE rating_cursor3 CURSOR FOR SELECT * FROM rating;
    FETCH ALL FROM rating_cursor3;
    CLOSE rating_cursor3;

    ROLLBACK TO first_state;

----------------------------------------------------------------------
    DECLARE rating_cursor4 CURSOR FOR SELECT * FROM rating;
    FETCH ALL FROM rating_cursor4;
    CLOSE rating_cursor4;

    ROLLBACK TO initial_state;

----------------------------------------------------------------------
    DECLARE rating_cursor5 CURSOR FOR SELECT * FROM rating;
    FETCH ALL FROM rating_cursor5;
    CLOSE rating_cursor5;

 COMMIT;