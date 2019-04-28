CREATE OR REPLACE FUNCTION number_container (n INTEGER)
RETURNS integer AS
$func$
BEGIN
RETURN (SELECT
    (CASE WHEN "bak mandi ember 1" IN ('tidak ada jentik', 'punya tidak diizinkan', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "bak mandi ember 2" IN ('tidak ada jentik', 'punya tidak diizinkan', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "bak mandi ember 3" IN ('tidak ada jentik', 'punya tidak diizinkan', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "bak mandi ember 4" IN ('tidak ada jentik', 'punya tidak diizinkan', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "dispenser" IN ('tidak ada jentik', 'punya tidak diizinkan', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "tampungan air belakang kulkas" IN ('tidak ada jentik', 'punya tidak diizinkan', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "vas bunga" IN ('tidak ada jentik', 'punya tidak diizinkan', 'ada jentik') THEN 1 ELSE 0 END +
	CASE WHEN "pot bunga air" IN ('tidak ada jentik', 'punya tidak diizinkan', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "alas pot bunga" IN ('tidak ada jentik', 'punya tidak diizinkan', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "kolam" IN ('tidak ada jentik', 'punya tidak diizinkan', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "aquarium" IN ('tidak ada jentik', 'punya tidak diizinkan', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "gentong" IN ('tidak ada jentik', 'punya tidak diizinkan', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "tempat minum hewan peliharaan" IN ('tidak ada jentik', 'punya tidak diizinkan', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "kaleng bekas" IN ('tidak ada jentik', 'punya tidak diizinkan', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "botol gelas aqua bekas" IN ('tidak ada jentik', 'punya tidak diizinkan', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "ban bekas" IN ('tidak ada jentik', 'punya tidak diizinkan', 'ada jentik') THEN 1 ELSE 0 END +
    CASE WHEN "ketiak bunga" IN ('tidak ada jentik', 'punya tidak diizinkan', 'ada jentik') THEN 1 ELSE 0 END)
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

DROP TABLE IF EXISTS jentik_ci;
CREATE TABLE jentik_ci AS
SELECT
	"ogc_fid",
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

SELECT * FROM jentik_ci;

SELECT to_char(today, 'YYYY-MM') AS date, kecamatan, rw, COUNT(*) AS forms_count
FROM jentik_ci
GROUP BY (kecamatan, kelurahan, rw, today)
ORDER BY today, kecamatan, kelurahan, rw, forms_count;

DROP TABLE IF EXISTS jentik_hi;
CREATE TABLE jentik_hi AS
WITH data AS (
	SELECT
		kelurahan, rw,
		SUM(number_infected_container) AS sum_infected_container,
		SUM(number_container) AS sum_container,
		COUNT(ogc_fid) FILTER (WHERE number_infected_container > 0) AS number_infected_house ,
		COUNT(ogc_fid) AS number_house
	FROM jentik_ci
	GROUP BY (kelurahan, rw)
	ORDER BY (kelurahan, rw)
)
SELECT *,
	CASE WHEN number_house <> 0 THEN number_infected_house / number_house::float ELSE 0 END AS house_index
FROM data;

