using DataFrames,
      Bootstrap

function getbootstrap(v, n=1000, i=0.95)
    bs = boot_basic(v, mean, n)
    ci = ci_basic(bs, i)
    return ci
end

function bystats(df::DataFrame, by1::Symbol, n=1000, i=0.95)
    by(df, by1) do df2
        ci = getbootstrap(dropna(df2[:Pfemale]), n, i)
        return DataFrame(Mean=ci.t0, Lower=interval(ci)[1], Upper=interval(ci)[2])
    end
end

function bystats(df::DataFrame, cols::Vector{Symbol}, n=1000, i=0.95)
    by(df, cols) do df2
        ci = getbootstrap(dropna(df2[:Pfemale]), n, i)
        return DataFrame(Mean=ci.t0, Lower=interval(ci)[1], Upper=interval(ci)[2])
    end
end
