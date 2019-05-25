import xmltodict
import json
import pymongo

# Parses key to lowercase strings (more conventional for mongo) and parses int values as int (when applicable)
def postprocessor(path, key, value):
    try:
        return key.lower(), int(value)
    except (ValueError, TypeError):
        return key.lower(), value

# Parser when seeing municipalities with one facility parses it as object and not array of object. Same goes for facilities with one activity. This fixes that
def parse_one_item_arrays(m_dict):
    for d in m_dict['data']['districts']:
        for m in d['municipalities']:
            if 'facilities' in m:
                if type(m['facilities']) is not list:
                    m['facilities'] = [m['facilities']]
                for f in m['facilities']:
                    if 'activities' in f:
                        if type(f['activities']) is not list:
                            f['activities'] = [f['activities']]
    return m_dict

XML_DATA = ''.join([line.rstrip('\n\t') for line in open('export.tsv')])
my_dict = xmltodict.parse(XML_DATA, postprocessor=postprocessor)

#client = pymongo.MongoClient("mongodb://tbda:grupoa@vdbase.inesctec.pt:27017/tbda?authSource=admin")
client = pymongo.MongoClient("mongodb://localhost:27017/tbda")
db = client["tbda"]
coll = db["districts"]
try:
    coll.insert_many(parse_one_item_arrays(my_dict)['data']['districts'])
except pymongo.errors.BulkWriteError as e:
    print(e.details)

#print(json.dumps(parse_one_item_arrays(my_dict)['data']['districts'][0], indent=4, ensure_ascii=False))
