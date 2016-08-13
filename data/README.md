# Datasets in Analysis

The xml files containing the data are evidently too large to upload to github. Use the search terms in pubmed, then click `send to` (in the upper right of results page), choose `file` for destination and `XML` for format. Add them to the `data/pubs/` folder.


## Biology pubs 1997-2014 (`bio`)
This dataset contains all english language publications under the MeSH term "Biology" published between 1997 and 2014, excluding many non-primary sources. Search term: `("Biology"[Mesh]) NOT (Review[ptyp] OR Comment[ptyp] OR Editorial[ptyp] OR Letter[ptyp] OR Case Reports[ptyp] OR News[ptyp] OR "Biography" [Publication Type]) AND ("1997/01/01"[PDAT] : "2014/12/31"[PDAT]) AND english[language]`

## Computational Biology pubs 1997-2014 (`comp`)
Same as above, except using MeSH term "Computational Biology". Only uses papers where this is is a major term. Date range was selected because this MeSH term was introduced in 1997, and the assignments of this term seem somewhat sparse in 2015 and 2016. Search term: `("Computational Biology"[Majr]) NOT (Review[ptyp] OR Comment[ptyp] OR Editorial[ptyp] OR Letter[ptyp] OR Case Reports[ptyp] OR News[ptyp] OR "Biography" [Publication Type]) AND ("1997/01/01"[PDAT] : "2014/12/31"[PDAT]) AND english[language]`

## Curated list of authors with known enders (`med`)
Data set of > 3000 authors with known genders from Filardo et. al. *BMJ* (2016) - doi: http://dx.doi.org/10.1136/bmj.i847

## arXiv Quantitative Biology (`q-bio`)
This dataset contains all preprints with the label “q-bio” from 2003 (when the section was introduced) to 2014. Downloaded on 10 June, 2016.

## arXiv CS (`cs`)
This dataset contains all preprints with the label “cs” from 2003 to 2014. Downloaded on 10 June, 2016.
