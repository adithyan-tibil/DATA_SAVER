def generate_query(num_rows):
    # Generate the array of numbers from 1 to num_rows
    array_values = ", ".join(map(str, range(1, num_rows + 1)))
    
    # Construct the query
    query = f"""
SELECT * FROM registry.sb_iterator(
    ARRAY[{array_values}], -- ROW_ID
    'VPA_DEVICE_BOUND',
    ARRAY[{array_values}], -- VID ARRAY
    ARRAY[{array_values}], -- DID ARRAY
    ARRAY[]::INTEGER[], -- Empty array
    ARRAY[]::INTEGER[], -- Empty array
    ARRAY[]::INTEGER[], -- Empty array
    ARRAY[{array_values}], -- EBY ARRAY
    ARRAY[]::INTEGER[] -- Empty array
);
"""
    return query

# Generate query for 10,000 rows
query = generate_query(5000)
print(query)

# Save to a file (optional)
with open("./sb_iterator_query.sql", "w") as file:
    file.write(query)
