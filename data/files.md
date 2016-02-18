# Links to datasets

The xml files containing the data are evidently too large to upload to github. Below are links to datasets used in this analysis. Download and unzip in the `data/` folder.


[Biology pubs 1997-2014](https://drive.google.com/file/d/0BxSnFgYDpKq9WWJyTllxLVhKME0/view?usp=sharing)
This dataset contains all english language publications under the MeSH term "Biology" published between 1997 and 2014, excluding many non-primary sources. Search terms: `("Biology"[Mesh]) NOT (Review[ptyp] OR Comment[ptyp] OR Editorial[ptyp] OR Letter[ptyp] OR Case Reports[ptyp] OR News[ptyp] OR "Biography" [Publication Type]) AND ("1997/01/01"[PDAT] : "2014/12/31"[PDAT]) AND english[language]`

[Computational Biology pubs 1997-2014](https://drive.google.com/file/d/0BxSnFgYDpKq9ZXpHVFc4SGpCNmM/view?usp=sharing)
Same as above, except using MeSH term "Computational Biology". Date range was selected because this MeSH term was introduced in 1997, and the assignments of this term seem somewhat sparse in 2015 and 2016. Search terms: `("Computational Biology"[Mesh]) NOT (Review[ptyp] OR Comment[ptyp] OR Editorial[ptyp] OR Letter[ptyp] OR Case Reports[ptyp] OR News[ptyp] OR "Biography" [Publication Type]) AND ("1997/01/01"[PDAT] : "2014/12/31"[PDAT]) AND english[language]`

[Pubs with github](https://drive.google.com/file/d/0BxSnFgYDpKq9Nkd6TFpha3hLR1U/view?usp=sharing)
All publications that contain "github" in the title or abstract, again excluding reviews, news etc. Search term: `github[title/abstract] NOT (Review[ptyp] OR Comment[ptyp] OR Editorial[ptyp] OR Letter[ptyp] OR Case Reports[ptyp] OR News[ptyp] OR "Biography"[Publication Type]) AND ("1997/01/01"[PDAT] : "2014/12/31"[PDAT]) AND english[language]`
