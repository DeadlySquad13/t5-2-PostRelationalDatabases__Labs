CREATE TYPE item_price AS (
    name text,
    price int
);

create table super_table (
  id SERIAL PRIMARY KEY,
  item item_price,
  test int[]
);