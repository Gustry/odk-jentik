CREATE OR REPLACE FUNCTION number_container (n INTEGER)
RETURNS integer AS
$func$
BEGIN
RETURN (SELECT
    (CASE WHEN "bak mandi ember 1" IN ('tidak ada jentik', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "bak mandi ember 2" IN ('tidak ada jentik', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "bak mandi ember 3" IN ('tidak ada jentik', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "bak mandi ember 4" IN ('tidak ada jentik', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "dispenser" IN ('tidak ada jentik', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "tampungan air belakang kulkas" IN ('tidak ada jentik',  'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "vas bunga" IN ('tidak ada jentik', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "pot bunga air" IN ('tidak ada jentik', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "alas pot bunga" IN ('tidak ada jentik', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "kolam" IN ('tidak ada jentik', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "aquarium" IN ('tidak ada jentik', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "gentong" IN ('tidak ada jentik', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "tempat minum hewan peliharaan" IN ('tidak ada jentik', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "kaleng bekas" IN ('tidak ada jentik', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "botol gelas aqua bekas" IN ('tidak ada jentik', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "ban bekas" IN ('tidak ada jentik', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "ketiak bunga" IN ('tidak ada jentik', 'ada jentik') THEN 1 ELSE 0 END)
    AS count
FROM
    jentik_data
WHERE _index = n);
END
$func$  LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION number_infected_container (n INTEGER)
RETURNS integer AS
$func$
BEGIN
RETURN (SELECT
    (CASE WHEN "bak mandi ember 1" IN ('ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "bak mandi ember 2" IN ('ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "bak mandi ember 3" IN ('ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "bak mandi ember 4" IN ('ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "dispenser" IN ('ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "tampungan air belakang kulkas" IN ('ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "vas bunga" IN ('ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "pot bunga air" IN ('ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "alas pot bunga" IN ('ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "kolam" IN ('ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "aquarium" IN ('ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "gentong" IN ('ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "tempat minum hewan peliharaan" IN ('ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "kaleng bekas" IN ('ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "botol gelas aqua bekas" IN ('ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "ban bekas" IN ('ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "ketiak bunga" IN ('ada jentik') THEN 1 ELSE 0 END)
    AS count
FROM
    jentik_data
WHERE _index = n);
END
$func$  LANGUAGE plpgsql;

-- SELECT rw FROM jentik_data WHERE kelurahan IS NULL;

/*
Container Index
*/

DROP TABLE IF EXISTS jentik_ci;
CREATE TABLE jentik_ci AS
SELECT
    "ogc_fid",
    to_char(today, 'YYYY-MM') AS month,
    today,
    "kecamatan",
    "kelurahan",
    "rw",
    "bak mandi ember 1" AS bak_mandi_ember_1,
    "bak mandi ember 2" AS bak_mandi_ember_2,
    "bak mandi ember 3" AS bak_mandi_ember_3,
    "bak mandi ember 4" AS bak_mandi_ember_4,
    "dispenser",
    "tampungan air belakang kulkas" AS tampungan_air_belakang_kulkas,
    "vas bunga" AS vas_bunga,
    "pot bunga air" AS pot_bunga_air,
    "alas pot bunga" AS alas_pot_bunga,
    "kolam",
    "aquarium",
    "gentong",
    "tempat minum hewan peliharaan" AS tempat_minum_hewan_peliharaan,
    "kaleng bekas" AS kaleng_bekas,
    "botol gelas aqua bekas" AS botol_gelas_aqua_bekas,
    "ban bekas" AS ban_bekas,
    "ketiak bunga" AS ketiak_bunga,
    number_infected_container(_index),
    number_container(_index),
    CASE WHEN number_container(_index) <> 0 THEN number_infected_container(_index)/number_container(_index)::float ELSE 0 END AS container_index
FROM jentik_data
WHERE kelurahan != ''
AND rw IS NOT NULL
ORDER BY (kelurahan, rw);

--SELECT to_char(today, 'YYYY-MM') AS date, kecamatan, rw, COUNT(*) AS forms_count
--FROM jentik_ci
--GROUP BY (kecamatan, kelurahan, rw, today)
--ORDER BY today, kecamatan, kelurahan, rw, forms_count;

SELECT * FROM jentik_ci;

/*
RW
*/

DROP TABLE IF EXISTS jentik_rw;
CREATE TABLE jentik_rw AS
WITH data AS (
    SELECT
        MIN(today) AS date_start,
        MAX(today) AS date_last,
        kecamatan, kelurahan, rw,
        SUM(number_infected_container) AS number_infected_container,
        SUM(number_container) AS number_container,
        COUNT(ogc_fid) FILTER (WHERE number_infected_container > 0) AS number_infected_house,
        COUNT(ogc_fid) AS number_house
    FROM jentik_ci
    GROUP BY (kecamatan, kelurahan, rw)
    ORDER BY (kecamatan, kelurahan, rw)
)
SELECT *,
    CASE WHEN number_house <> 0 THEN number_infected_house / number_house::float ELSE 0 END AS house_index,
    CASE WHEN number_container <> 0 THEN number_infected_container / number_container::float ELSE 0 END AS container_index
FROM data;

SELECT * FROM jentik_rw;

/*
RW Monthly index
*/

DROP TABLE IF EXISTS jentik_rw_monthly;
CREATE TABLE jentik_rw_monthly AS
WITH data AS (
    SELECT
        month,
        MIN(today) AS date_start,
        MAX(today) AS date_last,
        kecamatan, kelurahan, rw,
        SUM(number_infected_container) AS number_infected_container,
        SUM(number_container) AS number_container,
        COUNT(ogc_fid) FILTER (WHERE number_infected_container > 0) AS number_infected_house,
        COUNT(ogc_fid) AS number_house
    FROM jentik_ci
    GROUP BY (month, kecamatan, kelurahan, rw)
    ORDER BY (month, kecamatan, kelurahan, rw)
)
SELECT *,
    CASE WHEN number_house <> 0 THEN number_infected_house / number_house::float ELSE 0 END AS house_index,
    CASE WHEN number_container <> 0 THEN number_infected_container / number_container::float ELSE 0 END AS container_index
FROM data;

SELECT * FROM jentik_rw_monthly;

/*
Kelurahan Index
*/

DROP TABLE IF EXISTS jentik_kelurahan;
CREATE TABLE jentik_kelurahan AS
WITH data AS (
    SELECT
        MIN(date_start) AS date_start, MAX(date_last) AS date_last,
        kecamatan, kelurahan,
        SUM(number_infected_container) AS number_infected_container,
        SUM(number_container) AS number_container,
        SUM(number_infected_house) AS number_infected_house,
        SUM(number_house) AS number_house
    FROM jentik_rw
    GROUP BY (kecamatan, kelurahan)
    ORDER BY (kecamatan, kelurahan)
)
SELECT *,
    CASE WHEN number_house <> 0 THEN number_infected_house / number_house::float ELSE 0 END AS house_index,
    CASE WHEN number_container <> 0 THEN number_infected_container / number_container::float ELSE 0 END AS container_index
FROM data;

SELECT * FROM jentik_kelurahan;

/*
Kelurahan index monthly
*/

DROP TABLE IF EXISTS jentik_kelurahan_monthly;
CREATE TABLE jentik_kelurahan_monthly AS
WITH data AS (
    SELECT
        month,
        MIN(today) AS date_start,
        MAX(today) AS date_last,
        kecamatan, kelurahan,
        SUM(number_infected_container) AS number_infected_container,
        SUM(number_container) AS number_container,
        COUNT(ogc_fid) FILTER (WHERE number_infected_container > 0) AS number_infected_house,
        COUNT(ogc_fid) AS number_house
    FROM jentik_ci
    GROUP BY (month, kecamatan, kelurahan)
    ORDER BY (month, kecamatan, kelurahan)
)
SELECT *,
    CASE WHEN number_house <> 0 THEN number_infected_house / number_house::float ELSE 0 END AS house_index,
    CASE WHEN number_container <> 0 THEN number_infected_container / number_container::float ELSE 0 END AS container_index
FROM data;

SELECT * FROM jentik_kelurahan_monthly;

/*
Kecamatan index
*/

DROP TABLE IF EXISTS jentik_kecamatan;
CREATE TABLE jentik_kecamatan AS
WITH data AS (
    SELECT
        MIN(date_start) AS date_start, MAX(date_last) AS date_last,
        kecamatan,
        SUM(number_infected_container) AS number_infected_container,
        SUM(number_container) AS number_container,
        SUM(number_infected_house) AS number_infected_house,
        SUM(number_house) AS number_house
    FROM jentik_kelurahan
    GROUP BY (kecamatan)
    ORDER BY (kecamatan)
)
SELECT *,
    CASE WHEN number_house <> 0 THEN number_infected_house / number_house::float ELSE 0 END AS house_index,
    CASE WHEN number_container <> 0 THEN number_infected_container / number_container::float ELSE 0 END AS container_index
FROM data;

SELECT * FROM jentik_kecamatan;

/*
Kecamatan index monthly
*/

DROP TABLE IF EXISTS jentik_kecamatan_monthly;
CREATE TABLE jentik_kecamatan_monthly AS
WITH data AS (
    SELECT
        month,
        MIN(today) AS date_start,
        MAX(today) AS date_last,
        kecamatan,
        SUM(number_infected_container) AS number_infected_container,
        SUM(number_container) AS number_container,
        COUNT(ogc_fid) FILTER (WHERE number_infected_container > 0) AS number_infected_house,
        COUNT(ogc_fid) AS number_house
    FROM jentik_ci
    GROUP BY (month, kecamatan)
    ORDER BY (month, kecamatan)
)
SELECT *,
    CASE WHEN number_house <> 0 THEN number_infected_house / number_house::float ELSE 0 END AS house_index,
    CASE WHEN number_container <> 0 THEN number_infected_container / number_container::float ELSE 0 END AS container_index
FROM data;

SELECT * FROM jentik_kecamatan_monthly;

/*
Summary
*/

DROP TABLE IF EXISTS jentik_summary;
CREATE TABLE jentik_summary AS
WITH data AS (
    SELECT
        MIN(date_start) AS date_start, MAX(date_last) AS date_last,
        SUM(number_infected_container) AS number_infected_container,
        SUM(number_container) AS number_container,
        SUM(number_infected_house) AS number_infected_house,
        SUM(number_house) AS number_house
    FROM jentik_kelurahan
)
SELECT *,
    CASE WHEN number_house <> 0 THEN number_infected_house / number_house::float ELSE 0 END AS house_index,
    CASE WHEN number_container <> 0 THEN number_infected_container / number_container::float ELSE 0 END AS container_index
FROM data;
SELECT * FROM jentik_summary;

/*
Summary monthly
*/

DROP TABLE IF EXISTS jentik_summary_monthly;
CREATE TABLE jentik_summary_monthly AS
WITH data AS (
    SELECT
        month,
        MIN(today) AS date_start,
        MAX(today) AS date_last,
        SUM(number_infected_container) AS number_infected_container,
        SUM(number_container) AS number_container,
        COUNT(ogc_fid) FILTER (WHERE number_infected_container > 0) AS number_infected_house,
        COUNT(ogc_fid) AS number_house
    FROM jentik_ci
    GROUP BY (month)
    ORDER BY (month)
)
SELECT *,
    CASE WHEN number_house <> 0 THEN number_infected_house / number_house::float ELSE 0 END AS house_index,
    CASE WHEN number_container <> 0 THEN number_infected_container / number_container::float ELSE 0 END AS container_index
FROM data;

SELECT * FROM jentik_summary_monthly;

/*
Export to CSV
*/

COPY jentik_ci TO '/tmp/jentik_ci.csv' WITH (FORMAT CSV, DELIMITER ',', HEADER);
COPY jentik_rw TO '/tmp/jentik_rw.csv' WITH (FORMAT CSV, DELIMITER ',', HEADER);
COPY jentik_rw_monthly TO '/tmp/jentik_rw_monthly.csv' WITH (FORMAT CSV, DELIMITER ',', HEADER);
COPY jentik_kelurahan TO '/tmp/jentik_kelurahan.csv' WITH (FORMAT CSV, DELIMITER ',', HEADER);
COPY jentik_kelurahan_monthly TO '/tmp/jentik_kelurahan_monthly.csv' WITH (FORMAT CSV, DELIMITER ',', HEADER);
COPY jentik_kecamatan TO '/tmp/jentik_kecamatan.csv' WITH (FORMAT CSV, DELIMITER ',', HEADER);
COPY jentik_kecamatan_monthly TO '/tmp/jentik_kecamatan_monthly.csv' WITH (FORMAT CSV, DELIMITER ',', HEADER);
COPY jentik_summary TO '/tmp/jentik_summary.csv' WITH (FORMAT CSV, DELIMITER ',', HEADER);
COPY jentik_summary_monthly TO '/tmp/jentik_summary_monthly.csv' WITH (FORMAT CSV, DELIMITER ',', HEADER);
