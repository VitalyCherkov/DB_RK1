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
SELECT * FROM get_films_by_avg_stars_between(4, 5)
