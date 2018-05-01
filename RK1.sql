\c dblabs

------------------------------------------------------------------------------------
-- LAB5
------------------------------------------------------------------------------------


-- Хранимая процедура для поиска фильма по id рецензента

CREATE OR REPLACE FUNCTION get_films_by_reviewer_id(reviewer_id integer)
RETURNS TABLE (id integer, Title text, FilmYear integer, Name text, Stars integer) 
LANGUAGE SQL
AS $$

    SELECT 
        M.mid, 
        M.title,
        M.year, 
        RE.name, 
        R.stars 
    FROM (
        SELECT * FROM reviewer
        WHERE reviewer.rid = reviewer_id
    ) AS RE
    JOIN rating R ON RE.rid = R.rid
    JOIN movie M ON M.mid = R.mid;
    
$$;

SELECT * FROM get_films_by_reviewer_id(201);

-- Поиск фильма по средней оценке между минимальной и максимальной

CREATE OR REPLACE FUNCTION get_films_by_avg_stars_between(minimal integer, maximal integer)
RETURNS TABLE (id integer, Title text, Rating numeric)
LANGUAGE SQL
AS $$

    SELECT * FROM (
        SELECT
            M.mid,
            M.title,
            AVG(R.stars) AS stars
        FROM movie M
        JOIN rating R ON M.mid = R.mid
        GROUP BY M.mid
    ) AS RES
        WHERE RES.stars >= minimal AND RES.stars <= maximal;

$$;
SELECT * FROM get_films_by_avg_stars_between(4, 5);

-- Триггер на INSERT
-- При добавлении оценки фильму 'Titanic' оценка савится 5 баллов в любом случае
-- Остальным ставится 0

CREATE OR REPLACE FUNCTION rate_for_titanic()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

    IF NEW.mid = 105 THEN
        NEW.stars = 5;
    ELSE
        NEW.stars = 0;
    END IF;

    RETURN NEW;

END;
$$;

CREATE TRIGGER _tr_rate_for_titanic
    BEFORE INSERT
    ON rating
    FOR EACH ROW
    EXECUTE PROCEDURE rate_for_titanic();

-- Проверка
-- Рейтинг сначала
SELECT * FROM get_films_by_avg_stars_between(0, 5);
INSERT INTO rating (rid, mid, stars, ratingdate) VALUES
    (208, 105, 0, NULL),
    (208, 101, 5, NULL);
SELECT * FROM get_films_by_avg_stars_between(0, 5);

-- Триггер на UPDATE
-- При изменении рейтинга обнавляется дата

SELECT now();

CREATE OR REPLACE FUNCTION on_update_rating()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

    NEW.ratingdate = now();
    RETURN NEW;

END;
$$;

CREATE TRIGGER _tr_on_update_rating
    BEFORE UPDATE
    ON rating
    FOR EACH ROW
    EXECUTE PROCEDURE on_update_rating();

SELECT * FROM rating;

UPDATE rating
SET stars = 5;

SELECT * FROM rating;

-- Триггер на каскадное удаление


CREATE OR REPLACE FUNCTION on_delete_movie()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN

    DELETE FROM rating
    WHERE rating.mid = OLD.mid;
    RETURN OLD;

END;
$$;

CREATE TRIGGER _tr_on_delete_movie
    BEFORE DELETE
    ON movie
    FOR EACH ROW
    EXECUTE PROCEDURE on_delete_movie();

SELECT * FROM rating;
DELETE FROM movie
WHERE mid = 101;
SELECT * from movie;
SELECT * FROM rating;