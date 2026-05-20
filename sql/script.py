import pandas as pd
import random
from datetime import timedelta
import os

# Get folder where script.py exists
script_dir = os.path.dirname(os.path.abspath(__file__))

# File paths
input_file = os.path.join(script_dir, 'triage.csv')
output_file = os.path.join(script_dir, 'triage_updated.csv')

print("Reading:", input_file)

# Read CSV
df = pd.read_csv(
    input_file,
    sep=';',
    parse_dates=['admission_timestamp'],
    dayfirst=True,
    encoding='utf-8'
)

# Generate discharge timestamp
def generate_discharge(row):

    if row['state'] == 'active':
        return None

    urgency_ranges = {
        1: (40, 50),
        2: (30, 40),
        3: (20, 30),
        4: (10, 20),
        5: (1, 10)
    }

    min_minutes, max_minutes = urgency_ranges[row['urgency']]
    random_minutes = random.randint(min_minutes, max_minutes)

    return row['admission_timestamp'] + timedelta(minutes=random_minutes)

# Add column
df['triage_discharge'] = df.apply(generate_discharge, axis=1)

# Format dates
df['admission_timestamp'] = df['admission_timestamp'].dt.strftime('%d/%m/%Y %H:%M')

df['triage_discharge'] = df['triage_discharge'].apply(
    lambda x: x.strftime('%d/%m/%Y %H:%M') if pd.notnull(x) else ''
)

# Save
df.to_csv(output_file, sep=';', index=False)

print("Done.")
print("Saved to:", output_file)