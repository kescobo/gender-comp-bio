using DataFrames,
        JSON

function importauthors(filename::String, setname::String)
    df = readtable(filename)
    rename!(df, :x, :ID)
    df[:Dataset] = @pdata([setname for x in 1:length(df[:ID])])
    df[:Date] = @data([Date(replace(d, r"['\(\)\s]", ""), "y,m,d") for d in df[:Date]])
    return df
end


function getgenderprob(df::DataFrame, g::String, s::Symbol)
    genders = JSON.parsefile(g)
    ps = DataArray{Float64}([])
    cs = DataArray{Int32}([])
    for name in df[s]
        name = lowercase(name)
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
