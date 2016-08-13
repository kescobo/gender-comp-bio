import json
import urllib2
from api_keys import *
from genderize import Genderize

def get_unique_names(pubs_csv):
    names = []
    with open(pubs_csv, "r") as infile:
        for line in infile:
            names.append(line.split(",")[3])

    return set(names)


def get_gender_detector(names, outfile):
    gender_dict = {}
    for name in names:
        try:
            gender = detector.guess(name)
            gender_dict[name] = gender
        except:
            print(name)

    with open(outfile, "w+") as f:
        f.write(json.dumps(gender_dict, indent=4))


def get_genderize(names, outfile):
    genderize = Genderize(
        user_agent='Kevin_Bonham',
        api_key=genderize_key)

    for i in range(0, len(fixed_names), 10):
        query = fixed_names[i:i+10]
        genders = genderize.get(query)

    names_dict = {}

    for gender in genders:
        n = gender["name"]
        g = gender["gender"]
        if g != None:
            p = gender["probability"]
            c = gender["count"]
        else:
            p = None
            c = None
        n = gender["name"]
        g = gender["gender"]

        names_dict[n] = {"gender":g, "probability":p, "count": c}



    with open(outfile, "w+") as f:
        f.write(json.dumps(names_dict, indent=4))


def get_genderAPI(names, outfile):
    genderAPI_dict = {}
    counter = 0

    for i in range(counter, len(names), 20):
        counter += 20
        if counter %1000 == 0:
            print counter
        n = names[i:i+20]
        query = ";".join(n)

        data = json.load(urllib2.urlopen("https://gender-api.com/get?key={}&name={}".format(genderAPI_key, query)))
        for r in data['result']:
            n = r["name"]
            g = r["gender"]

            if g != u"unknown":
                p = float(r["accuracy"]) / 100
                c = r["samples"]
            else:
                p = None
                c = 0

            genderAPI_dict[n] = {"gender":g, "probability":p, "count": c}


    with open(outfile, "w+") as f:
        f.write(json.dumps(genderAPI_dict, indent=4))


if __name__ == '__main__':
    import sys
    method = sys.argv[1]
    outfile = sys.argv[2]
    name_files = sys.argv[3:]

    all_names = set([])
    for n in name_files:
        all_names = all_names.union(get_unique_names(n))

    if method == "genderize":
        get_genderize(all_names, outfile)
    elif method == "genderapi":
        get_genderAPI(all_names, outfile)
    else:
        from gender_detector import GenderDetector
        get_gender_detector(all_names, outfile)
