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


def write_names_to_file(in_file, out_file):
    col_names = ["Date", "Journal", "Author Name", "Position"]
    df = pd.DataFrame(columns=col_names)

    with open(out_file, 'a+') as out:
        df.to_csv(out, columns = col_names)

    counter = 0
    for article in iter_parse_pubmed(in_file):
        first, last, second, penultimate, others = score_authors(article.authors)
        if first:
            row = pd.Series([article.pubdate, article.journal, first.first_name, "first"], name=article.pmid, index=col_names)
            df = df.append(row)
        else:
            continue
        try:
            row = pd.Series([article.pubdate, article.journal, last.first_name, "last"], name=article.pmid, index=col_names)
            df = df.append(row)
        except:
            pass
        try:
            row = pd.Series([article.pubdate, article.journal, second.first_name, "second"], name=article.pmid, index=col_names)
            df = df.append(row)
        except:
            pass
        try:
            row = pd.Series([article.pubdate, article.journal, penultimate.first_name, "penultimate"], name=article.pmid, index=col_names)
            df = df.append(row)
        except:
            pass
        try:
            for x in others:
                row = pd.Series([article.pubdate, article.journal, x.first_name, "other"], name=article.pmid, index=col_names)
                df = df.append(row)
        except:
            pass


        if counter % 1000 == 0:
            print(counter)
            with open(out_file, 'a+') as out:
                df.to_csv(out, columns = col_names, header=False)
            df = pd.DataFrame(columns=col_names)
        counter +=1
    with open(out_file, 'a+') as out:
        df.to_csv(out, columns = col_names, header=False)



# write_names_to_file("git.xml", "git_authors2.csv")
# write_names_to_file("comp.xml", "comp_authors2.csv")
# write_names_to_file("bio.xml", "bio_authors2.csv")
# write_names_to_file("dev.xml", "dev_authors.csv")
# write_names_to_file("eco.xml", "eco_authors.csv")
write_names_to_file("vanity.xml", "vanity.csv")
write_names_to_file("vanitycomp.xml", "vanitycomp.csv")
write_names_to_file("plosbio.xml", "plosbio.csv")
write_names_to_file("ploscomp.xml", "ploscomp.csv")
