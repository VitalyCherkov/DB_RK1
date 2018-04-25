\c unilabs

------------------------------------------------------------------------------------
-- LAB5
------------------------------------------------------------------------------------

--
-- Выбрать список названий фильмов и средний рейтинг, от самого низкого до самого 
-- высокого. Если два или более фильмов имеют одинаковый средний балл, перечислить их в
-- алфавитном порядке.
--
DROP VIEW IF EXISTS filmsStarsView;
CREATE VIEW filmsStarsView AS
    SELECT M.title AS title, RES.stars AS stars
    FROM movie M
    JOIN (
        SELECT R.mid AS movieId, AVG(R.stars) AS stars
        FROM rating R
        GROUP BY R.mid
    ) AS RES
    ON M.mid = RES.movieId
    ORDER BY stars, title;

-- B) Узнать рейтинг фильма
CREATE OR REPLACE FUNCTION get_rating_of_film(filmName TEXT) 
    RETURNS SETOF filmsStarsView
    LANGUAGE SQL
AS $$
    SELECT * FROM filmsStarsView WHERE title = filmName;
$$;

SELECT * FROM get_rating_of_film('E.T.');

-- C) Фильмы с рейтингом в диапазоне от, до
CREATE OR REPLACE FUNCTION get_films_by_rating(NUMERIC, NUMERIC)
    RETURNS SETOF filmsStarsView
    LANGUAGE SQL
AS $$
    SELECT * FROM filmsStarsView WHERE stars >= $1 AND stars <=  $2;
$$;

SELECT * FROM get_films_by_rating(2.5, 3.0);

-- D) Поиск оценок фильма по 

-- Треггер INSERT
