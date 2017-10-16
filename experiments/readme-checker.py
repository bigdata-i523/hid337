import yaml
import json
import sys
from pprint import pprint

def banner(msg):
    print (79 * '#')
    print ('#', msg)
    print (79 * '#')

# variables/counters declaration
in_yaml = False
content = []
counter = 0

# Read input file
with open('README.yaml', 'r') as f:
    lines = f.readlines()


all_lines = []
for line in lines:
    all_lines.append(line.replace("\n",""))

lines = all_lines

#print(lines)


content = []

# Loop through all the lines
for line in lines:
    counter = counter + 1

    if not in_yaml and line.startswith('```'):
        in_yaml = True
    elif in_yaml and line.startswith("```"):
        in_yaml = False
    elif in_yaml:
        content.append(line)
        
s = '\n'.join(content)

if '\t' in s:
    print("ERROR: your file contains a TAB")
    print(s.replace("\t", "<TAB>"))

try:

    banner('text')
    print (s)
    
    d = yaml.load(s)

    banner('dict')
    pprint (d)

    banner('yaml')
    print (yaml.dump(d, default_flow_style=False))
    
    
    banner('json')
    print(json.dumps(d, indent=4))
    
except Exception as e:
    print ("ERROR: you have a problem in your file")
    print (e)

