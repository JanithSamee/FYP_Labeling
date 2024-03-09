import pandas as pd
import sys

if len(sys.argv) != 3:
    print("Usage: python3 main.py data.json converted.json")
    sys.exit(1)

# Extract arguments
arg1 = sys.argv[1]
arg2 = sys.argv[2]

# Use the arguments
print("Input File :", arg1)
print("Output File :", arg2)

try:
    # Read the JSON file
    data = pd.read_json(arg1)
    
    # Process the data
    for item in ["chair","stool","table","wall"]:
        for index, i in enumerate(data[item]):
            if len(i) == 9 and isinstance(i[0], float):
                data.loc[index, item] = [i]
    
    # Write processed data to JSON file
    data.to_json(arg2)
    print(data.head())
    
except FileNotFoundError:
    print("Error: File not found.")
    sys.exit(1)
except Exception as e:
    print("An error occurred:", e)
    sys.exit(1)

print("Conversion successful.")
