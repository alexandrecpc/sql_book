DROP FUNCTION IF EXISTS WEEKOFMONTH;
DELIMITER //
CREATE FUNCTION WEEKOFMONTH(dateValue DATE)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE firstDayOfMonth DATE;
    DECLARE dayOfMonth INT;
    SET firstDayOfMonth = DATE_FORMAT(dateValue, '%Y-%m-01');
    SET dayOfMonth = DAY(dateValue);
    RETURN FLOOR((dayOfMonth - 1) / 7) + 1;
END//
DELIMITER ;

DROP table if exists date_dim;

CREATE table date_dim
as
SELECT date_format(date, '%Y-%m-%d') as date
,cast(date_format(date,'%Y%m%d') as unsigned) as date_key
,day(date) as day_of_month
,dayofyear(date) as day_of_year
,dayofweek(date) as day_of_week
,trim(date_format(date, '%W')) as day_name
,trim(date_format(date, '%a')) as day_short_name
,week(date) as week_number
,WEEKOFMONTH(date) as week_of_month
,date_sub(date, interval weekday(date) day) as week
,month(date) as month_number
,trim(date_format(date, '%M')) as month_name
,trim(date_format(date, '%b')) as month_short_name
,date_format(date_add(date_format(date, '%Y-%m-01'), interval (quarter(date)-1)*3 month), '%Y-%m-01') as first_day_of_quarter
,date_sub(date_add(date_format(date, '%Y-%m-01'), interval quarter(date)*3 month), interval 1 day) as last_day_of_quarter
,quarter(date) as quarter_number
,concat('Q', quarter(date)) as quarter_name
,date_format(date, '%Y-%m-01') as first_day_of_month
,date_sub(date_add(date_format(date, '%Y-%m-01'), interval 1 month), interval 1 day) as last_day_of_month
,year(date) as year
,FLOOR(year(date)/10)*10 as decade
,FLOOR(year(date)/100)+1 as century
FROM (SELECT CAST('1770-01-01' AS DATE) + INTERVAL (a + (10 * b) + (100 * c)) DAY as date
      FROM (
        SELECT 0 AS a UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
        UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9
      ) AS a
      CROSS JOIN (
        SELECT 0 AS b UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
        UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9
      ) AS b
      CROSS JOIN (
        SELECT 0 AS c UNION SELECT 1 UNION SELECT 2 UNION SELECT 3 UNION SELECT 4 UNION SELECT 5
        UNION SELECT 6 UNION SELECT 7 UNION SELECT 8 UNION SELECT 9
      ) AS c
    ) AS dates
WHERE date <= '2030-12-31'
ORDER BY date;
