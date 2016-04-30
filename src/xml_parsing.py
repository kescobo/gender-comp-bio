import os
import datetime
from lxml.etree import iterparse
import pandas as pd
from genderize import Genderize

os.listdir()
os.chdir("../data/")

class Article(object):
    """Container for publication info"""
    def __init__(self, pmid, pubdate, journal, title, abstract, authors):
        self.pmid = pmid
        self.pubdate = pubdate
        self.journal = journal
        self.title = title
        self.abstract = abstract
        self.authors = authors
    def __repr__(self):
        return "<Article PMID: {}>".format(self.pmid)

    def get_authors(self):
        for author in self.authors:
            yield author


class Author(object):
    def __init__(self, last_name, first_name):
        assert type(last_name) == str
        assert type(first_name) == str

        self.last_name = last_name
        self.first_name = first_name.split()[0]
        try:
            self.initials = " ".join(first_name.split()[1:])
        except IndexError:
            self.initials = None


def iter_parse_pubmed(xml_file):
    # get an iterable
    for event, element in iterparse(xml_file, tag="PubmedArticle", events=("end",)):
        element.xpath('.//DateCreated/Year')[0].text

        pmid = element.xpath('.//PMID')[0].text
        pubdate = datetime.date(
            int(element.xpath('.//DateCreated/Year')[0].text), # year
            int(element.xpath('.//DateCreated/Month')[0].text), # month
            int(element.xpath('.//DateCreated/Day')[0].text), #day
            )


        journal = element.xpath('.//Journal//ISOAbbreviation')
        if journal:
            journal = journal[0].text
        else:
            journal = None

        title = element.xpath('.//Article/ArticleTitle')
        if title:
            title = title[0].text
        else:
            title = None

        abstract = element.xpath('.//Article/Abstract')
        if abstract:
            abstract = abstract[0].text
        else:
            abstract = None

        author_records = element.xpath('.//Article/AuthorList/Author')
        authors = []
        for name in author_records:
            try:
                authors.append(Author(name[0].text, name[1].text))
            except IndexError:
                pass

        element.clear()

        yield Article(pmid, pubdate, journal, title, abstract, authors)


def score_authors(author_list):
    if not author_list:
        first = None
    else:
        first = author_list[0]
    others, penultimate, second, last = None, None, None, None

    list_length = len(author_list)
    if list_length > 4:
        others = [author for author in author_list[2:-2]]
    if list_length > 3:
        penultimate = author_list[-2]
    if list_length > 2:
        second = author_list[1]
    if list_length > 1:
        last = author_list[-1]


    return first, last, second, penultimate, others


col_names = ["Date", "Journal", "First Author", "Last Author", "Second Author", "Penultimate Author", "Other Authors"]

df = pd.DataFrame()

for article in iter_parse_pubmed('github_pubs.xml'):
    first, last, second, penultimate, others = score_authors(article.authors)
    first = first.first_name
    try:
        last = last.first_name
    except:
        pass
    try:
        second = second.first_name
    except:
        pass
    try:
        penultimate = penultimate.first_name
    except:
        pass
    try:
        others = [x.first_name for x in others]
    except:
        pass

    row = pd.Series([article.pubdate, article.journal, first, last, second, penultimate, others],
                    name=article.pmid, index=col_names)
    df = df.append(row)

print(df)

unique_names = set([])

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

unique_names = get_unique_names("/Users/KBLaptop/computation/gender-comp-bio/data/biology-1997-2014.xml", unique_names)
len(unique_names)

fixed_names = []
for name in unique_names:
    if name:
        if len(name) > 1:
            fixed_names.append(name)
fixed_names.sort()
print(len(fixed_names))

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
