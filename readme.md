```bash
ogr2ogr -f PostgreSQL PG:'dbname=etienne service=localhost' data.csv -oo AUTODETECT_TYPE=YES -lco SCHEMA=public -lco OVERWRITE=YES -nln jentik_data
```


Next form:
* Compute CI at the end
* No space in column name
* no space in result from choices