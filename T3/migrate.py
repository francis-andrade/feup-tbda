import xmltodict
import json
from pymongo import MongoClient

# Parses key to lowercase strings (more conventional for mongo) and parses int values as int (when applicable)
def postprocessor(path, key, value):
    try:
        return key.lower(), int(value)
    except (ValueError, TypeError):
        return key.lower(), value

# Parser when seeing municipalities with one facility parses it as object and not array of object. Same goes for facilities with one activity. This fixes that
def parse_one_item_arrays(m_dict):
    for d in m_dict['data']['district']:
        for m in d['municipalities']:
            if 'facilities' in m:
                if type(m['facilities']) is not list:
                    m['facilities'] = [m['facilities']]
                for f in m['facilities']:
                    if 'activities' in f:
                        if type(f['activities']) is not list:
                            f['activities'] = [f['activities']]
    return m_dict

MY_XML_HERE = """..."""

my_dict = xmltodict.parse(MY_XML_HERE, postprocessor=postprocessor, encoding='ISO-8859-1')

client = MongoClient("mongodb://tbda:grupoa@vdbase.inesctec.pt:27017/tbda?authSource=admin")
db = client["tbda"]
coll = db["districts"]
coll.insert_many(parse_one_item_arrays(my_dict)['data']['district'])

#print(json.dumps(parse_one_item_arrays(my_dict), indent=4, ensure_ascii=False))
