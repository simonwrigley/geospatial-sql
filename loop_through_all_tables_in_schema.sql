DROP FUNCTION IF EXISTS loop_update(text);
CREATE OR REPLACE FUNCTION loop_update(_schema text) RETURNS VOID AS $func$
DECLARE
rec RECORD;

BEGIN

-- Use the information_schema to find out all of the table names in the input schema.
FOR rec IN
  SELECT table_name, column_name
  FROM information_schema.columns
  WHERE (table_schema = _schema)

-- Loop through all of the tables from the above statement renaming the columns:
LOOP
  EXECUTE format('UPDATE %I.%I SET %I = ____', _schema, rec.table_name, rec.column_name);
END LOOP;

END;
$func$
LANGUAGE PLPGSQL;
