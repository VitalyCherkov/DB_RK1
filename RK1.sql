--      director     |       name       |          title          | stars |    date    
-- ------------------+------------------+-------------------------+-------+------------
--  Steven Spielberg | Ashley White     | E.T.                    |     3 | 2011-01-02
--  Steven Spielberg | Brittany Harris  | Raiders of the Lost Ark |     2 | 2011-01-30
--  Steven Spielberg | Brittany Harris  | Raiders of the Lost Ark |     4 | 2011-01-12
--  Robert Wise      | Brittany Harris  | The Sound of Music      |     2 | 2011-01-20
--  Steven Spielberg | Chris Jackson    | E.T.                    |     2 | 2011-01-22
--  Steven Spielberg | Chris Jackson    | Raiders of the Lost Ark |     4 | 
--  Robert Wise      | Chris Jackson    | The Sound of Music      |     3 | 2011-01-27
--                   | Daniel Lewis     | Snow White              |     4 | 
--  James Cameron    | Elizabeth Thomas | Avatar                  |     3 | 2011-01-15
--                   | Elizabeth Thomas | Snow White              |     5 | 2011-01-19
--  James Cameron    | James Cameron    | Avatar                  |     5 | 2011-01-20
--  Victor Fleming   | Mike Anderson    | Gone with the Wind      |     3 | 2011-01-09
--  Victor Fleming   | Sarah Martinez   | Gone with the Wind      |     2 | 2011-01-22
--  Victor Fleming   | Sarah Martinez   | Gone with the Wind      |     4 | 2011-01-27


--
-- 1
-- Найти названия всех фильмов снятых ‘Steven Spielberg’, отсортировать по алфавиту.
--
SELECT title FROM movie WHERE director='Steven Spielberg'
    ORDER BY title ASC;

--
-- 2
-- Найти года в которых были фильмы с рейтингом не ниже 4 и отсортировать по возрастанию.
--
SELECT year FROM movie M
    WHERE M.mid IN (SELECT mid FROM rating WHERE stars>=4)
    ORDER BY year ASC;

--
-- 3
-- Найти названия всех фильмов которые не имеют рейтинга, отсортировать по алфавиту.
--
SELECT title FROM movie M
    WHERE M.mid NOT IN (SELECT mid FROM rating)
    ORDER BY title ASC;

--
-- 4
-- Некоторые оценки не имеют даты. Найти имена всех экспертов, имеющих оценки без даты, отсортировать по алфавиту.
--
SELECT name FROM reviewer R
    WHERE R.rid IN (SELECT rid FROM rating WHERE ratingdate IS NULL)
    ORDER BY name ASC;

-- 
-- 5
-- Напишите запрос возвращающий информацию о рейтингах в более читаемом формате: 
-- имя эксперта, название фильма, оценка и дата оценки. 
-- Отсортируйте данные по имени эксперта, затем названию фильма и наконец оценка.
--
SELECT movie.director AS director, reviewer.name AS name, movie.title AS title, rating.stars AS stars, rating.ratingdate AS date
FROM rating
LEFT OUTER JOIN movie ON movie.mid = rating.mid
LEFT OUTER JOIN reviewer ON reviewer.rid = rating.rid
ORDER BY name, title, stars, rating;

--
-- 6
-- Для каждого фильма, выбрать название и “разброс оценок”, то есть, разницу между 
-- самой высокой и самой низкой оценками для этого фильма. Сортировать по 
-- “разбросу оценок” от высшего к низшему, и по названию фильма.
--
SELECT M.title AS title, MAX(R.stars) - MIN(R.stars) AS delta
FROM movie M
JOIN rating R USING (mid)
GROUP BY M.mid
ORDER BY delta;

--
-- 7
-- Найти разницу между средней оценкой фильмов выпущенных до 1980 года, 
-- а средней оценкой фильмов выпущенных после 1980 года 
-- (фильмы выпущенные в 1980 году не учитываются).
-- Убедитесь, что для расчета используете среднюю оценку для каждого фильма. 
-- Не просто среднюю оценку фильмов до и после 1980 года.
--
SELECT
AVG(CASE WHEN R.year > 1980 THEN R.stars ELSE NULL END) -
AVG(CASE WHEN R.year <= 1980 THEN R.stars ELSE NULL END) AS delta
FROM (
    SELECT M.year AS year, AVG(R.stars) as stars
    FROM movie M
    JOIN rating R USING (mid)
    GROUP BY M.mid, M.year
) AS R;

--
-- 8
-- Найти имена всех экспертов, кто оценил “Gone with the Wind”, 
-- отсортировать по алфавиту.
--
SELECT DISTINCT name 
FROM reviewer RE
JOIN rating RA USING (rid)
JOIN movie M USING (mid)
WHERE (M.title = 'Gone with the Wind')
ORDER BY name ASC;

--
-- 9
-- Для каждой оценки, где эксперт тот же человек что и режиссер, выбрать имя, 
-- название фильма и оценку, отсортировать по имени, названию фильма и оценке.
--
SELECT reviewer.name AS name, movie.title AS title, rating.stars AS stars, rating.ratingdate AS date
FROM rating
LEFT OUTER JOIN movie ON movie.mid = rating.mid
LEFT OUTER JOIN reviewer ON reviewer.rid = rating.rid
WHERE (reviewer.name = movie.director)
ORDER BY name, title, stars, rating;

--
-- 10
-- Выберите всех экспертов и названия фильмов в едином списке в алфавитном порядке.
--
SELECT name AS col1
FROM reviewer 
UNION
SELECT director AS col1
FROM movie
UNION
SELECT title AS col1
FROM movie
ORDER BY col1 ASC;

--
-- 11
-- Выберите названия всех фильмов, по алфавиту, которым не поставил оценку ‘Chris Jackson’.
--
SELECT title FROM movie 
WHERE (
    (title, 'Chris Jackson') 
    NOT IN (
        SELECT DISTINCT M.title as title, RE.name as name
        FROM 
        movie M
        LEFT OUTER JOIN rating R ON M.mid = R.mid
        LEFT OUTER JOIN reviewer RE ON RE.rid = R.rid
    )
)
ORDER BY title ASC;

--
-- 12
-- Для всех пар экспертов, если оба оценили один и тот же фильм, выбрать имена обоих. 
-- Устранить дубликаты, проверить отсутствие пар самих с собой и включать каждую пару 
-- только 1 раз. Выбрать имена в паре в алфавитном порядке и отсортировать по именам.
--
SELECT RE1.name AS reviewer1, RE2.name AS reviewer2 
FROM (
    SELECT DISTINCT F.rid AS first, S.rid AS second
    FROM rating F
    INNER JOIN rating S ON F.mid = S.mid
    WHERE F.rid < S.rid
) pairs
INNER JOIN reviewer RE1 ON pairs.first = RE1.rid
INNER JOIN reviewer RE2 ON pairs.second = RE2.rid
ORDER BY reviewer1, reviewer2;

--
-- 13
-- Выбрать список названий фильмов и средний рейтинг, от самого низкого до самого 
-- высокого. Если два или более фильмов имеют одинаковый средний балл, перечислить их в
-- алфавитном порядке.
--
SELECT M.title AS title, RES.stars AS stars
FROM movie M
JOIN (
    SELECT R.mid AS movieId, AVG(R.stars) AS stars
    FROM rating R
    GROUP BY R.mid
) AS RES
ON M.mid = RES.movieId
ORDER BY stars, title;

--
-- 14
-- Найти имена всех экспертов, которые поставили три или более оценок, 
-- сортировка по алфавиту.
--
SELECT name
FROM (
    SELECT R.rid
    FROM rating R
    GROUP BY R.rid
    HAVING COUNT(*) >= 3
) AS res
JOIN reviewer ON reviewer.rid = res.rid
ORDER BY name;

