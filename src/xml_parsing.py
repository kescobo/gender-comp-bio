import os
import datetime
from lxml.etree import iterparse
import pandas as pd

class Article(object):
    """Container for publication info"""
    def __init__(self, article_id, pubdate, journal, title, abstract, authors):
        self.article_id = article_id
        self.pubdate = pubdate
        self.journal = journal
        self.title = title
        self.abstract = abstract
        self.authors = authors
    def __repr__(self):
        return "<Article ID: {}>".format(self.article_id)

    def get_authors(self):
        for author in self.authors:
            yield author


class Author(object):
    def __init__(self, last_name, first_name=None):
        assert type(last_name) == str
        self.last_name = last_name

        if first_name:
            assert type(first_name) == str
            self.first_name = first_name.split()[0]
            try:
                self.initials = " ".join(first_name.split()[1:])
            except IndexError:
                self.initials = None
        else:
            self.first_name = None
            self.initials = None



def iter_parse_pubmed(xml_file):
    # get an iterable
    for event, element in iterparse(xml_file, tag="PubmedArticle", events=("end",)):

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


def iter_parse_arxiv(xml_file):
    print("parsing!")
    ns = {
        "a":"http://arxiv.org/OAI/arXiv/",
        "o":"http://www.openarchives.org/OAI/2.0/"}
    for event, element in iterparse(xml_file, tag= "{http://www.openarchives.org/OAI/2.0/}record", events=("end",)):
        ident = element.xpath('./o:header/o:identifier', namespaces = ns)[0].text

        pubdate = element.xpath('.//o:datestamp', namespaces = ns)[0].text.split("-")
        pubdate = datetime.date(*[int(d) for d in pubdate])

        author_records = element.xpath('.//o:metadata//a:authors/a:author', namespaces = ns)
        authors = []
        for name in author_records:
            last_name = name.xpath('./a:keyname', namespaces = ns)[0].text
            try:
                first_name = name.xpath('./a:forenames', namespaces = ns)[0].text
            except IndexError:
                first_name = None
            try:
                authors.append(Author(last_name, first_name))
            except IndexError:
                pass

        try:
            title = element.xpath('.//o:metadata//a:title', namespaces = ns)[0].text
        except IndexError:
            title = None
        try:
            abstract = element.xpath('.//o:metadata//a:abstract', namespaces = ns)[0].text
        except IndexError:
            abstract = None
        try:
            cat = element.xpath('.//o:metadata//a:categories', namespaces = ns)[0].text.split(" ")
        except IndexError:
            cat = None

        element.clear()
        yield Article(ident, pubdate, cat, title, abstract, authors)

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


def write_names_to_file(in_file, out_file, pub_type="pubmed"):
    col_names = ["Date", "Journal", "Author Name", "Position"]
    df = pd.DataFrame(columns=col_names)

    with open(out_file, 'w+') as out:
        df.to_csv(out, columns = col_names)

    counter = 0

    if pub_type == "arxiv":
        articles = iter_parse_arxiv(in_file)
    elif pub_type == "pubmed":
        articles = iter_parse_pubmed(in_file)
    else:
        raise IndexError

    for article in articles:
        first, last, second, penultimate, others = score_authors(article.authors)
        if first:
            row = pd.Series([article.pubdate, article.journal, first.first_name, "first"], name=article.article_id, index=col_names)
            df = df.append(row)
        else:
            continue
        try:
            row = pd.Series([article.pubdate, article.journal, last.first_name, "last"], name=article.article_id, index=col_names)
            df = df.append(row)
        except:
            pass
        try:
            row = pd.Series([article.pubdate, article.journal, second.first_name, "second"], name=article.article_id, index=col_names)
            df = df.append(row)
        except:
            pass
        try:
            row = pd.Series([article.pubdate, article.journal, penultimate.first_name, "penultimate"], name=article.article_id, index=col_names)
            df = df.append(row)
        except:
            pass
        try:
            for x in others:
                row = pd.Series([article.pubdate, article.journal, x.first_name, "other"], name=article.article_id, index=col_names)
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


if __name__ == '__main__':
    import sys
    if sys.argv[1] == "--arxiv":
        write_names_to_file(sys.argv[2], sys.argv[3], "arxiv")
    elif sys.argv[1] == "--pubmed":
        write_names_to_file(sys.argv[2], sys.argv[3])
    else:
        write_names_to_file(sys.argv[1], sys.argv[2])
