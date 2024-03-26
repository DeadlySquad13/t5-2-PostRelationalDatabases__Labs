SELECT json_column->>'age' AS age FROM super_table
where json_column #>> '{address, state}' = 'NY';