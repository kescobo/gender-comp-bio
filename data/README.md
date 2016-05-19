# Datasets in Analysis

The xml files containing the data are evidently too large to upload to github. Use the search terms in pubmed, then click `send to` (in the upper right of results page), choose `file` for destination and `XML` for format. Add them to the `data/pubs/` folder.


## Biology pubs 1997-2014 (`bio`)
This dataset contains all english language publications under the MeSH term "Biology" published between 1997 and 2014, excluding many non-primary sources. Search term: `("Biology"[Mesh]) NOT (Review[ptyp] OR Comment[ptyp] OR Editorial[ptyp] OR Letter[ptyp] OR Case Reports[ptyp] OR News[ptyp] OR "Biography" [Publication Type]) AND ("1997/01/01"[PDAT] : "2014/12/31"[PDAT]) AND english[language]`

## Computational Biology pubs 1997-2014 (`comp`)
Same as above, except using MeSH term "Computational Biology". Only uses papers where this is is a major term. Date range was selected because this MeSH term was introduced in 1997, and the assignments of this term seem somewhat sparse in 2015 and 2016. Search term: `("Computational Biology"[Majr]) NOT (Review[ptyp] OR Comment[ptyp] OR Editorial[ptyp] OR Letter[ptyp] OR Case Reports[ptyp] OR News[ptyp] OR "Biography" [Publication Type]) AND ("1997/01/01"[PDAT] : "2014/12/31"[PDAT]) AND english[language]`

## Ecology pubs 1997-2014 (`eco`)
Same as above, except using MeSH term "Ecology". Search term: `(Ecology[Mesh]) NOT (Review[ptyp] OR Comment[ptyp] OR Editorial[ptyp] OR Letter[ptyp] OR Case Reports[ptyp] OR News[ptyp] OR "Biography" [Publication Type]) AND ("1997/01/01"[PDAT] : "2014/12/31"[PDAT]) AND english[language]`

## Developmental Biology pubs 1997-2014 (`dev`)
Same as above, except using MeSH term "Developmental Biology". Only uses papers where this is is a major term. Search term: `("Developmental Biology"[Majr]) NOT (Review[ptyp] OR Comment[ptyp] OR Editorial[ptyp] OR Letter[ptyp] OR Case Reports[ptyp] OR News[ptyp] OR "Biography" [Publication Type]) AND ("1997/01/01"[PDAT] : "2014/12/31"[PDAT]) AND english[language]`

## High Impact Biology Papers 1997-2014 (`vanity`)
Biology papers published in prestige journals *Nature*, *Science* or *Cell* between 1997 and 2014. Search term:
`"Biology"[Mesh] AND ("Nature"[Journal] OR "Science"[Journal] OR "Cell"[Journal]) NOT (Review[ptyp] OR Comment[ptyp] OR Editorial[ptyp] OR Letter[ptyp] OR Case Reports[ptyp] OR News[ptyp] OR "Biography"[Publication Type]) AND ("1997/01/01"[PDAT] : "2014/12/31"[PDAT]) AND english[language]`

## High Impact Computational Biology Papers 1997-2014 (`vanitycomp`)
Computational Biology papers published in prestige journals *Nature*, *Science* or *Cell* between 1997 and 2014. Search term:
`"Computational Biology"[Majr] AND ("Nature"[Journal] OR "Science"[Journal] OR "Cell"[Journal]) NOT (Review[ptyp] OR Comment[ptyp] OR Editorial[ptyp] OR Letter[ptyp] OR Case Reports[ptyp] OR News[ptyp] OR "Biography"[Publication Type]) AND ("1997/01/01"[PDAT] : "2014/12/31"[PDAT]) AND english[language]`

## PLoS Comparison
Papers published in specialty PLoS journals:

`plosbio`:
`"PLoS Biol"[Journal] NOT (Review[ptyp] OR Comment[ptyp] OR Editorial[ptyp] OR Letter[ptyp] OR Case Reports[ptyp] OR News[ptyp] OR "Biography"[Publication Type]) AND ("1997/01/01"[PDAT] : "2014/12/31"[PDAT]) AND english[language]`

`ploscomp`:
`"PLoS Comput Biol"[Journal] NOT (Review[ptyp] OR Comment[ptyp] OR Editorial[ptyp] OR Letter[ptyp] OR Case Reports[ptyp] OR News[ptyp] OR "Biography"[Publication Type]) AND ("1997/01/01"[PDAT] : "2014/12/31"[PDAT]) AND english[language]`

## Pubs with github (`git`)
All publications that contain "github" in the title or abstract, again excluding reviews, news etc. Search term: `github[title/abstract] NOT (Review[ptyp] OR Comment[ptyp] OR Editorial[ptyp] OR Letter[ptyp] OR Case Reports[ptyp] OR News[ptyp] OR "Biography"[Publication Type]) AND ("1997/01/01"[PDAT] : "2014/12/31"[PDAT]) AND english[language]`
