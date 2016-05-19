from xml_parsing import *


def get_unique_names(xml_file, name_set=None):
    new_names = []
    if not name_set:
        name_set = set([])

    for article in iter_parse_pubmed(xml_file):
        first, last, second, penultimate, others = score_authors(article.authors)

        if first:
            fa = first.first_name
        else:
            fa = None
        if last:
            la = last.first_name
        else:
            la = None
        if second:
            sa = second.first_name
        else:
            sa = None
        if penultimate:
            pa = penultimate.first_name
        else:
            pa = None
        if others:
            oa = [o.first_name for o in others]
        else:
            oa = []

        new_names.extend([fa, la, sa, pa, *oa])

    return name_set.union(set(new_names))


def run_unique_names():
    unique_names = set([])
    unique_names = get_unique_names("/Users/KBLaptop/computation/gender-comp-bio/data/biology-1997-2014.xml", unique_names)
    len(unique_names)

    fixed_names = []
    for name in unique_names:
        if name:
            if len(name) > 1:
                fixed_names.append(name)
    fixed_names.sort()
    print(len(fixed_names))


def get_genderize():
    genders = []

    os.chdir("../src")
    from genderize_key import my_key
    genderize = Genderize(
        user_agent='Kevin_Bonham',
        api_key=my_key)

    for i in range(0, len(fixed_names), 10):
        query = fixed_names[i:i+10]
        genders.extend(genderize.get(query))

    genders
    with open("../data/genderize_data.txt", "w+") as outfile:
        for gender in genders:
            outfile.write(str(gender))
            outfile.write("\n")

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

    import json

    with open("../data/gender_dict.json", "w+") as outfile:
        outfile.write(json.dumps(names_dict, indent=4))
