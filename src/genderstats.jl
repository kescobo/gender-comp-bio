using DataFrames,
    Gadfly

function getgenders(datafile::ASCIIString)
    df = readtable(datafile)

    df[:First_Author] = map(1:length(df[:First_Author])) do i
        if typeof(df[:First_Author][i]) == NAtype
            return "none"
        else
            return df[:First_Author][i]
        end
    end
    df[:Last_Author] = map(1:length(df[:Last_Author])) do i
        if typeof(df[:Last_Author][i]) == NAtype
            return "none"
        else
            return df[:Last_Author][i]
        end
    end
    df[:Second_Author] = map(1:length(df[:Second_Author])) do i
        if typeof(df[:Second_Author][i]) == NAtype
            return "none"
        else
            return df[:Second_Author][i]
        end
    end
    df[:Penultimate_Author] = map(1:length(df[:Penultimate_Author])) do i
        if typeof(df[:Penultimate_Author][i]) == NAtype
            return "none"
        else
            return df[:Penultimate_Author][i]
        end
    end

    return df
end

allbio = getgenders("data/all_bio_pubs.csv")
compbio = getgenders("data/compbio_pubs2.csv")
gitbio = getgenders("data/github_pub.csv")

function getstats(df::DataFrame)
    all = length(df[:x])

    ff = df[df[:First_Author] .== "female", :First_Author]
    fm = df[df[:First_Author] .== "male", :First_Author]
    first = length(ff) / (length(ff) + length(fm))
    fknown = (length(ff) + length(fm)) / all

    lf = df[df[:Last_Author] .== "female", :Last_Author]
    lm = df[df[:Last_Author] .== "male", :Last_Author]
    last = length(lf) / (length(lf) + length(lm))
    lknown = (length(lf) + length(lm)) / all

    sf = df[df[:Second_Author] .== "female", :Second_Author]
    sm = df[df[:Second_Author] .== "male", :Second_Author]
    second = length(sf) / (length(sf) + length(sm))
    sknown = (length(sf) + length(sm)) / all

    pf = df[df[:Penultimate_Author] .== "female", :Penultimate_Author]
    pm = df[df[:Penultimate_Author] .== "male", :Penultimate_Author]
    penultimate = length(pf) / (length(pf) + length(pm))
    pknown = (length(pf) + length(pm)) / all

    o = df[:Other_Authors]
    fcount, mcount, tcount = otherauthors(o)
    oknown = (fcount + mcount) / tcount
    others = fcount / (fcount + mcount)

    return DataFrame(Position=["First", "Second", "Others", "Penultimate", "Last"],
                     Female=[first, second, others, penultimate, last],
                     Known=[fknown, sknown, oknown, pknown, lknown])
end

function otherauthors(column)
    fcount = 0
    mcount = 0
    tcount = 0

    for line in column
        l = replace(line, r"['\[\]]", "")
        s = split(l, ", ")
        for e in s
            tcount += 1
            if e == "female"
                fcount += 1
            elseif e == "male"
                mcount += 1
            end
        end
    end
    return fcount, mcount, tcount
end

allstats = getstats(allbio)
compstats = getstats(compbio)
gitstats = getstats(gitbio)

allstats[:DataSet] = ["All_Bio", "All_Bio", "All_Bio", "All_Bio", "All_Bio"]
compstats[:DataSet] = ["Comp_Bio", "Comp_Bio", "Comp_Bio", "Comp_Bio", "Comp_Bio"]
gitstats[:DataSet] = ["Git_Bio", "Git_Bio", "Git_Bio", "Git_Bio", "Git_Bio"]

append!(allstats, compstats)
append!(allstats, gitstats)
pool!(allstats, :Position)

p = plot(allstats, x = :Position, y = :Female,
    color = "DataSet", Geom.bar(position=:dodge), Coord.cartesian(ymax=0.45))

draw(PDF("by_position.pdf", 11inch, 8inch), p)
