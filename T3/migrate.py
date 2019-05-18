import xmltodict
import json

# Parses key to lowercase strings (more conventional for mongo) and parses int values as int (when applicable)
def postprocessor(path, key, value):
    try:
        return key.lower(), int(value)
    except (ValueError, TypeError):
        return key.lower(), value

MY_XML_HERE = """..."""

my_dict = xmltodict.parse(MY_XML_HERE, postprocessor=postprocessor, encoding='ISO-8859-1')

for d in my_dict['data']['district']:
    for m in d['municipalities']:
        if 'facilities' in m:
            if type(m['facilities']) is not list:
                m['facilities'] = [m['facilities']]
            for f in m['facilities']:
                if 'activity' in f:
                    if type(f['activity']) is not list:
                        f['activity'] = [f['activity']]

print(json.dumps(my_dict, indent=4, ensure_ascii=False))
