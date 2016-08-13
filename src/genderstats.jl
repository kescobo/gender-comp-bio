using DataFrames,
      Gadfly,
      JSON,
      Colors,
      Plots

include("dataimport.jl")
include("bootstrapping.jl")

impact = readtable("data/pubs/impact.csv")
impactdict = Dict([(impact[i,:Journal], impact[i,:IF]) for i in 1:length(impact[:Journal])])

arxivcs = importauthors("data/pubs/arxivcs.csv", "arxivcs")
arxivbio = importauthors("data/pubs/arxivbio.csv", "arxivbio")

arxiv = vcat(arxivbio, arxivcs)
pool!(arxiv)
arxiv = arxiv[!isna(arxiv[:Author_Name]), :]

arxiv[:Pfemale], arxiv[:Count] = getgenderprob(arxiv, "data/genders/genderAPI_genders.json", :Author_Name)
map(x -> Dates.year(Date(x)), arxiv[:Date])



bio = importauthors("data/pubs/bio.csv", "bio")
comp = importauthors("data/pubs/comp.csv", "comp")
eco = importauthors("data/pubs/eco.csv", "eco")
dev = importauthors("data/pubs/dev.csv", "dev")
alldata = vcat(bio, comp)
alldata[:Pfemale], alldata[:Count] = getgenderprob(alldata, "data/genders/genderAPI_genders.json", :Author_Name)

byposition = bystats(alldata, [:Position, :Dataset])

arxivbyposition = bystats(arxiv, :Position, :Dataset)

writetable("data/graphs/allbyposition.csv", byposition)
writetable("data/graphs/arxivbyposition.csv", arxivbyposition)

pool!(alldata)
alldata = alldata[!isna(alldata[:Journal]), :]

withgender = alldata[!isna(alldata[:Pfemale]), :]
print(withgender)

lastauthors = withgender[(withgender[:Position] .== "last"), :]

femlast = Set(lastauthors[lastauthors[:Pfemale] .> 0.8, :ID])
malelast = Set(lastauthors[lastauthors[:Pfemale] .< 0.2, :ID])

length(femlast)
length(malelast)

by(g->maximum(g[:Pfemale])>0.9 ? g[g[:Position].=="first ",:] : DataFrame(), withgender,:ID)

f = alldata[(Vector{Bool}([in(i, femlast) for i in alldata[:ID]])), :]
m = alldata[(Vector{Bool}([in(i, malelast) for i in alldata[:ID]])), :]

fem = bystats(f, :Dataset, :Position)
mal = bystats(m, :Dataset, :Position)

mean(dropna(f[f[:Dataset] .== "bio", :Pfemale]))
mean(dropna(f[f[:Dataset] .== "comp", :Pfemale]))

mean(dropna(m[m[:Dataset] .== "bio", :Pfemale]))
mean(dropna(m[m[:Dataset] .== "comp", :Pfemale]))

intersect(Set(femlast), Set(firstauthors[:ID]))

###
firsts = df[df[:Position] .== "first", :]
lasts = df[df[:Position] .== "last", :]
meetsthreshold = lasts[lasts[:Probability] .> 0.8, :ID]

final = firsts[[in(i, lasts) for i in firsts[:ID]], :]
###


firstauthors = withgender[
            (withgender[:Dataset] .== "bio")&
            (withgender[:Position] .== "first"), :]

f = firstauthors[map(infemale, firstauthors[:ID]), :]
m = firstauthors[map(inmale, firstauthors[:ID]), :]



length(levels(alldata[alldata[:Dataset] .== "bio", :ID]))
length(alldata[alldata[:Dataset] .== "bio", :Author_Name])

length(levels(alldata[alldata[:Dataset] .== "comp", :ID]))
length(alldata[alldata[:Dataset] .== "comp", :Author_Name])

length(levels(alldata[alldata[:Dataset] .== "comp", :Author_Name]))

length(alldata[(alldata[:Dataset] .== "bio") & (isna(alldata[:Pfemale])), :Author_Name]) /
    length(alldata[alldata[:Dataset] .== "bio", :Author_Name])

names = by(alldata, [:Author_Name], df -> mean(df[:Pfemale]))

mean(isna(names[:x1]))

big3 = alldata[
    (alldata[:Journal] .== utf8("Nature"))|
    (alldata[:Journal] .== utf8("Science"))|
    (alldata[:Journal] .== utf8("Cell")),
    :]

big3bio = big3[big3[:Dataset] .== "bio", :]
big3biobyposition = bystats(big3, :Position, :Dataset)
writetable("data/graphs/big3byposition.csv", big3byposition)




comppubs = alldata[(alldata[:Dataset] .== "bio")&
    ((alldata[:Journal] .== utf8("PLoS Comput. Biol."))|
    (alldata[:Journal] .== utf8("Nucleic Acids Res."))|
    (alldata[:Journal] .== utf8("BMC Bioinformatics"))|
    (alldata[:Journal] .== utf8("Bioinformatics"))), :]


comppubs = alldata[(alldata[:Dataset] .== "bio")&
    ((alldata[:Journal] .== utf8("Proc. Natl. Acad. Sci. U.S.A."))|
    (alldata[:Journal] .== utf8("Biol. Lett."))|
    (alldata[:Journal] .== utf8("PLoS Biol."))|
    (alldata[:Journal] .== utf8("BMC Biol."))), :]

plos = alldata[(alldata[:Dataset] .== "bio")&
    ((alldata[:Journal] .== utf8("PLoS Biol."))|
    (alldata[:Journal] .== utf8("PLoS Comput. Biol."))),
    :]

bmc = alldata[(alldata[:Dataset] .== "bio")&
    ((alldata[:Journal] .== utf8("BMC Biol."))|
    (alldata[:Journal] .== utf8("BMC Bioinformatics"))),
    :]


numperyear = by(alldata, [:Year, :Dataset]) do df
    DataFrame(number = length(levels(df[:ID])))
end
writetable("data/graphs/numperyear.csv", numperyear)


bmcbyposition = bystats(bmc, :Position, :Journal)
writetable("data/graphs/bmcbyposition.csv", bmcbyposition)

jcompare = vcat(plos, bmc)

bystats(jcompare, :Journal)

plosbyposition = bystats(plos, :Position, :Journal)
writetable("data/graphs/plosbyposition.csv", plosbyposition)

medjournals = alldata[(alldata[:Dataset] .== "bio")&
    (alldata[:Position] .== "first")&
    ((alldata[:Journal] .== "Ann. Intern. Med.")|
    (alldata[:Journal] .== "Arch. Intern. Med.")|
    (alldata[:Journal] .== "BMJ")|
    (alldata[:Journal] .== "JAMA")|
    (alldata[:Journal] .== "N. Engl. J. Med.")|
    (alldata[:Journal] .== "Lancet")),
    :]

alldata[:Year] = map(x -> Dates.year(Date(x)), alldata[:Date])

byyear = bystats(alldata, :Year, :Dataset)
byyear[:error] = [byyear[i, :Mean] - byyear[i, :Lower] for i in 1:length(byyear[:Mean])]

arxiv[:Year] = map(x -> Dates.year(Date(x)), arxiv[:Date])
arxivbyyear = bystats(arxiv, :Year, :Dataset)
arxivbyyear[:error] = [arxivbyyear[i, :Mean] - arxivbyyear[i, :Lower] for i in 1:length(arxivbyyear[:Mean])]

writetable("data/graphs/byyear.csv", byyear)
writetable("data/graphs/arxivbyyear.csv", arxivbyyear)


my_colors = [RGB(0.275,0.263,0.29), RGB(0.58, 0.659, 0.82), RGB(0.969,0.635,0.514), RGB(0.388,0.263,0.431), RGB(0.447,0.514,0.294)]

plot(byyear, x=:Year, y=:Pfemale, color=:Dataset,
        Scale.color_discrete_manual(my_colors...),
        Geom.point, Geom.line, Guide.title("Female Authors Over Time"),
        Guide.YLabel("Percent Female"), Guide.XLabel("Year"))

byjournal = by(alldata, [:Journal, :Dataset], df ->
    DataFrame(Pfemale = mean(dropna(df[:Pfemale])), journal_count = length(dropna(df[:Pfemale]))))

sort!(byjournal, cols = [:Pfemale])

writetable("data/graphs/byjournal.csv", byjournal[byjournal[:journal_count] .> 1000,:])
writetable("data/graphs/byjournalimpact.csv", byjournal)

print(levels(byjournal[byjournal[:journal_count] .> 1000, :Journal]))

byjournal = byjournal[byjournal[:journal_count] .> 1000, :]
writetable("data/graphs/byjournalimpact.csv", byjournal)

byjournal[:impact] = [impactdict[i] for i in Vector(byjournal[:Journal])]

journals = Vector(byjournal[:Journal])
impactdict[journals[1]]


plot(byjournal[byjournal[:journal_count] .> 1000,:], x = :Journal, y = :Pfemale,
    Geom.bar())

function f(x)
    if isna(x)
        return NA
    elseif x >=0.8
        return 1
    elseif x<=0.2
        return 0.0
    else
        return NA
    end
end

alldata[:Abs] = @data([f(x) for x in alldata[:Pfemale]])


byposition = by(alldata, [:Position, :Journal], df -> mean(dropna(df[:Abs])))
