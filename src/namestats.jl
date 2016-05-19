using DataFrames,
    Gadfly,
    JSON

genders = JSON.parsefile("data/gender_dict.json")

authornames = DataArray{UTF8String}([])
pf = DataArray{Float64}([])
n = DataArray{Int}([])

for key in keys(genders)
    push!(authornames, key)
    gender = genders[key]["gender"]
    if typeof(genders[key]["count"]) <: Int
        push!(n, genders[key]["count"])
    else
        push!(n, NA)
    end
    if gender == "female"
        p = genders[key]["probability"]
    elseif gender == "male"
        p = 1 - genders[key]["probability"]
    else
        p = NA
    end
    push!(pf, p)
end

df = DataFrame(Name = authornames, Pf = pf, Count = n)
sort!(df)

mean(isna(df[:Pf])) # Percent of names that have no gender: 0.6230653885288919

known = df[!isna(df[:Pf]), :]

mean(known[:Pf] .> 0.5) # Percent of known names that are female: 0.4896639909071535

f = known[known[:Pf] .> 0.5, :]
m = known[known[:Pf] .< 0.5, :]

mean(f[:Count] .< 10) # percent of female names that have less than 10 Samples: 0.534237632380676
mean(m[:Count] .< 10) # percent of male names that have less than 10 Samples: 0.5820304056488219

mean(f[:Count] .> 100)
mean(m[:Count] .> 100)



mean(f[:Count]) # average samples: 89.21442042651965
plot(f, x = :Count, Geom.histogram(), Scale.x_log10())
mean(m[:Count]) # average male: 84.92809280207507
plot(f, x = :Count, Geom.histogram(), Scale.x_log10())
