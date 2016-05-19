using DataFrames,
    Gadfly,
    JSON,
    Colors

function importauthors(filename::ASCIIString, setname::ASCIIString)
    df = readtable(filename)
    rename!(df, :x, :PMID)
    df[:Dataset] = @pdata([setname for x in 1:length(df[:PMID])])
    df[:Date] = @data([Date(d) for d in df[:Date]])
    return df
end

bio = importauthors("data/pubs/bio.csv", "bio")
comp = importauthors("data/pubs/comp.csv", "comp")
dev = importauthors("data/pubs/dev.csv", "dev")
eco = importauthors("data/pubs/eco.csv", "eco")
git = importauthors("data/pubs/git.csv", "git")

function getgenderprob(df::DataFrame, s::Symbol)
    genders = JSON.parsefile("data/pubs/gender_dict.json")
    ps = DataArray{Float64}([])
    cs = DataArray{Int32}([])
    for name in df[s]
        if haskey(genders, name)
            gender = genders[name]["gender"]

            if gender == "female"
                p = genders[name]["probability"]
                c = genders[name]["count"]
            elseif gender == "male"
                p = 1 - genders[name]["probability"]
                c = genders[name]["count"]
            else
                p = NA
                c = 0
            end
            push!(ps, p)
            push!(cs, c)
        else
            push!(ps, NA)
            push!(cs, 0)
        end
    end
    return ps, cs
end


alldata = vcat(bio, comp, dev, eco, git)

alldata[:Pfemale], alldata[:Count] = getgenderprob(alldata, :Author_Name)

pool!(alldata)
alldata = alldata[!isna(alldata[:Journal]), :]
bypositon = by(alldata, [:Position, :Dataset], df -> mean(dropna(df[:Pfemale])))


vanity = alldata[(alldata[:Journal] .== utf8("Nature"))|(alldata[:Journal] .== utf8("Science"))|(alldata[:Journal] .== utf8("Cell")), :]
vanity = vanity[vanity[:Dataset] .!= "dev", :]
vanitybyposition = by(vanity, [:Position, :Dataset], df -> mean(dropna(df[:Pfemale])))

vanitybio = vanity[vanity[:Dataset] .== "bio", :]
vanitybiobyposition = by(vanitybio, [:Position, :Journal], df -> mean(dropna(df[:Pfemale])))

function addspacer(df::DataFrame, column::Symbol)
    categories = levels(df[column])
    for c in categories
        push!(df, [c, "space", 0])
    end
end

addspacer(vanitybyposition, :Position)
addspacer(vanitybiobyposition, :Position)

size(vanity[vanity[:Dataset] .== "dev", :])[1]
size(vanity[vanity[:Dataset] .== "eco", :])[1]


plos = alldata[(alldata[:Dataset] .== "bio")&((alldata[:Journal] .== utf8("PLoS Biol."))|(alldata[:Journal] .== utf8("PLoS Comput. Biol."))), :]
plosbyposition = by(plos, [:Position, :Journal], df -> mean(dropna(df[:Pfemale])))


biodata = alldata[alldata[:Dataset] .== "bio", :]
bionames = by(biodata, :Author_Name, nrow)
bionames[:Pfemale], bionames[:Count] = getgenderprob(bionames, :Author_Name)
knownbionames = bionames[!isna(bionames[:Pfemale]), :]
unknownbionames = bionames[isna(bionames[:Pfemale]), :]

sort!(knownbionames, cols = [:x1])

tail(bionames)

compdata = alldata[alldata[:Dataset] .== "comp", :]
compnames = by(compdata, :Author_Name, nrow)
compnames[:Pfemale], compnames[:Count] = getgenderprob(compnames, :Author_Name)
knowncompnames = compnames[!isna(compnames[:Pfemale]), :]


bioquantiles = nquantile(knownbionames[:Count], 1000)
mean(knownbionames[(knownbionames[:Count] .>= bioquantiles[300])&(knownbionames[:Count] .<= bioquantiles[301]), :Pfemale],
        weights(knownbionames[(knownbionames[:Count] .>= bioquantiles[300])&(knownbionames[:Count] .<= bioquantiles[301]), :x1]))

x = [1:10:1000]
y1 = []
for i in 1:10:(length(bioquantiles)-1)
    y = mean(knownbionames[(knownbionames[:Count] .>= bioquantiles[i])&(knownbionames[:Count] .<= bioquantiles[i+10]), :Pfemale],
            weights(knownbionames[(knownbionames[:Count] .>= bioquantiles[i])&(knownbionames[:Count] .<= bioquantiles[i+10]), :x1]))
    push!(y1, y)
end

compquantiles = nquantile(knowncompnames[:Count], 1000)

y2 = []
for i in 1:10:(length(compquantiles)-1)
    y = mean(knowncompnames[(knowncompnames[:Count] .>= compquantiles[i])&(knowncompnames[:Count] .<= compquantiles[i+10]), :Pfemale],
            weights(knowncompnames[(knowncompnames[:Count] .>= compquantiles[i])&(knowncompnames[:Count] .<= compquantiles[i+10]), :x1]))
    push!(y2, y)
end

draw(PNG("data/graphs/gender_certainty2.png", 11inch, 8inch),
    plot(layer(x=x, y=y1, Geom.point, Theme(default_color=colorant"red", highlight_width = 0pt)),
         layer(x=x, y=y2, Geom.point, Theme(default_color=colorant"blue", highlight_width = 0pt)),
         Guide.xticks(ticks=[0:200:1100]),
                 Guide.XLabel("Certainty of Gender"), Guide.YLabel("Weighted %Female"),
                 Guide.title("Percent Female Authorship by Gender Certainty"),
                 Guide.manual_color_key("Dataset", ["All Bio", "Comp Bio"], ["red", "blue"])
         ))

draw(PNG("data/graphs/gender_certainty3.png", 11inch, 8inch),
    plot(layer(x=x, y=(y1-y2), Geom.point, Theme(default_color=colorant"red", highlight_width = 0pt)),
         layer(x=x, y=[0 for y in 1:length(x)], Geom.line),
            Guide.xticks(ticks=[0:200:1100]),
            Guide.XLabel("Certainty of Gender"), Guide.YLabel("Gender Difference"),
            Guide.title("Percent Female Authorship by Gender Certainty"),
      ))

theme1 = Theme(default_color=colorant"red", default_point_size=2px, highlight_width = 0pt)
plot(knownbionames, x=:x1, y=:Pfemale, Geom.point,
        Scale.x_log10(), theme1)


namenumber =  levels(knownbionames[:x1])
x=[1:length(namenumber)]
y3=[]

for i in 1:length(namenumber)
    y = mean(knownbionames[knownbionames[:x1] .>= namenumber[i], :Pfemale],
            weights(knownbionames[knownbionames[:x1] .>= namenumber[i], :x1]))

    push!(y3, y)
end
plot(x=namenumber, y=y3, Geom.point, theme1, Scale.x_log10())

sum(unknownbionames[unknownbionames[:x1] .<= namenumber[40], :Pfemale])

y4=[]
for i in 2:length(namenumber)
    y = length(unknownbionames[(unknownbionames[:x1] .<= namenumber[i])&(unknownbionames[:x1] .>= namenumber[i-1]), :x1])
    push!(y4, y)
end

length(!isna(y4))
x1 = namenumber[2:649]

plot(x=x1[1:100], y=dropna(y4)[1:100], Geom.bar,
        Guide.YLabel("Number of names with unknown gender"), Guide.XLabel("Number of times as author"))


skewfemale = biodata
for i in 1:size(skewfemale)[1]
    if biodata[i, :Count] == 0
        skewfemale[i, :Pfemale] = 1.0
    end
end
skewmiddle = biodata
for i in 1:size(skewmiddle)[1]
    if biodata[i, :Count] == 0
        skewmiddle[i, :Pfemale] = 0.5
    end
end
skewmale = biodata
for i in 1:size(skewmale)[1]
    if biodata[i, :Count] == 0
        skewmale[i, :Pfemale] = 0
    end
end


skewbypositon = by(skewfemale, [:Position], df -> mean(dropna(df[:Pfemale])))
skewmidbypositon = by(skewmiddle, [:Position], df -> mean(dropna(df[:Pfemale])))
skewmalebypositon = by(skewmale, [:Position], df -> mean(dropna(df[:Pfemale])))

skewbypositon[:Skew] = "female"
skewmidbypositon[:Skew] = "middle"
skewmalebypositon[:Skew] = "male"

skews = vcat(skewbypositon, skewmidbypositon, skewmalebypositon)


function hexcolor(c::ASCIIString)

RGB(0x7a, 0x2c, 0xe3)
prettycolors = [RGB(0.275,0.263,0.29), RGB(0.58, 0.659, 0.82), RGB(0.969,0.635,0.514), RGB(0.388,0.263,0.431), RGB(0.447,0.514,0.294)]
pc2 = [RGB(0x7A,0x2C,0xE3),RGB(0x0C,0x98,0xED),RGB(0x00,0xC8,0xD6),RGB(0xBA,0xFF,0x98),RGB(0x00,0xE3,0xA6)]


draw(PNG("data/graphs/skewed_position.png", 11inch, 8inch),
    plot(skews, x=:Position, y=:x1, color=:Skew,
                Scale.discrete_color_manual(pc2...),
                Geom.bar(position = :dodge),
                Scale.x_discrete(levels=["first", "second", "other", "penultimate", "last"]),
                Theme(bar_spacing=2mm)))


draw(PNG("data/graphs/by_position.png", 11inch, 8inch),
    plot(bypositon, x=:Position, y=:x1, color=:Dataset,
                Scale.discrete_color_manual(prettycolors...),
                Geom.bar(position = :dodge),
                Scale.x_discrete(levels=["first", "second", "other", "penultimate", "last"]),
                Theme(bar_spacing=2mm)))

draw(PNG("data/graphs/vanity_position.png", 11inch, 8inch),
    plot(vanitybyposition, x=:Position, y=:x1, color=:Dataset,
            Scale.discrete_color_manual(prettycolors...),
            Geom.bar(position = :dodge), Guide.title("Authors in Nature, Science and Cell"),
            Guide.YLabel("Percent Female"),
            Scale.x_discrete(levels=["first", "second", "other", "penultimate", "last"]),
            Theme(bar_spacing=2mm)))

draw(PNG("data/graphs/plos_position.png", 11inch, 8inch),
    p = plot(plosbyposition, x=:Position, y=:x1, color=:Journal,
                Scale.discrete_color_manual(prettycolors...),
                Geom.bar(position = :dodge), Guide.title("Authors in PLoS Journals"),
                Guide.YLabel("Percent Female"),
                Scale.x_discrete(levels=["first", "second", "other", "penultimate", "last"]),
                Theme(bar_spacing=2mm)))

draw(PNG("data/graphs/vanity_position.png", 11inch, 8inch),
    s = plot(vanitybiobyposition, x=:Position, y=:x1, color=:Journal,
                Scale.discrete_color_manual(prettycolors...),
                Geom.bar(position = :dodge), Guide.title("Nature, Science, Cell - Biology"),
                Guide.YLabel("Percent Female"),
                Scale.x_discrete(levels=["first", "second", "other", "penultimate", "last"]),
                Theme(bar_spacing=2mm)))

draw(PNG("data/graphs/bio_name_stats.png", 11inch, 8inch),
    plot(bionames[bionames[:Count] .!= 0, :], x=:x1, y=:Count, color=:Pfemale,
            Geom.point, Scale.x_log10(), Scale.y_log10(),
            Guide.YLabel("Times in Genderize Database"),
            Guide.XLabel("Times in Dataset"),
            Guide.title("Name Stats in Bio Publications")))

draw(PNG("data/graphs/comp_name_stats.png", 11inch, 8inch),
    plot(compnames[compnames[:Count] .!= 0, :], x=:x1, y=:Count, color=:Pfemale,
            Geom.point, Scale.x_log10(), Scale.y_log10(),
            Guide.YLabel("Times in Genderize Database"),
            Guide.XLabel("Times in Dataset"),
            Guide.title("Name Stats in CompBio Publications")))

draw(PNG("data/graphs/bio_stats_conservative.png", 11inch, 8inch),
    plot(compnames[(compnames[:Count] .!= 0)&((compnames[:Pfemale] .> 0.8)|(compnames[:Pfemale] .< 0.2)), :],
            x=:x1, y=:Count, color=:Pfemale,
            Geom.point, Scale.x_log10(), Scale.y_log10(),
            Guide.YLabel("Times in Genderize Database"),
            Guide.XLabel("Times in Dataset"),
            Guide.title("Name Stats in CompBio Publications")))


vf = mean(dropna(vanity[vanity[:Position] .== "first", :Pfemale]))
pf = mean(dropna(plos[plos[:Position] .== "first", :Pfemale]))
bf = mean(dropna(biodata[biodata[:Position] .== "first", :Pfemale]))
cf = mean(dropna(compdata[compdata[:Position] .== "first", :Pfemale]))


vl = mean(dropna(vanity[vanity[:Position] .== "last", :Pfemale]))
pl = mean(dropna(plos[plos[:Position] .== "last", :Pfemale]))
bl = mean(dropna(biodata[biodata[:Position] .== "last", :Pfemale]))
cl = mean(dropna(compdata[compdata[:Position] .== "last", :Pfemale]))

pc = prettycolors
plot(x=[1,2,3,4,5,6,7,8,9], y=[bf,cf,vf,pf,0,bl,cl,vl,pl], Geom.bar(),
        Scale.discrete_color_manual(pc[1],pc[2],pc[3],pc[4],pc[5],pc[1],pc[2],pc[3],pc[4]),
        )

pca = [RGBA(0.275,0.263,0.29, 0.2), RGBA(0.58, 0.659, 0.82, 0.2), RGBA(0.969,0.635,0.514, 0.2), RGBA(0.388,0.263,0.431, 0.2), RGBA(0.447,0.514,0.294, 0.2)]
plot(x=[1,2,3,4,5,6,7,8,9], y=[4:12], Geom.bar(),
        Scale.discrete_color_manual(prettycolors[1],prettycolors[2],prettycolors[3],prettycolors[4],prettycolors[5],prettycolors[1],prettycolors[2],prettycolors[3],prettycolors[4]),
        Guide.manual_color_key("Legend", ["Points", "Line"], [pca[1], pca[2]])
        )


d = biodata

for i in 1:size(d)[1]
    d[i,:Date] = Dates.year(d[i,:Date])
end

x3 = levels(d[:Date])
y5 = []
for i in 1:length(namenumber)
    y = mean(knownbionames[knownbionames[:x1] .>= namenumber[i], :Pfemale],
            weights(knownbionames[knownbionames[:x1] .>= namenumber[i], :x1]))
    push!(y3, y)
end
