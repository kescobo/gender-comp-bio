# from Github user Mattriks. See: https://github.com/dcjones/Gadfly.jl/issues/844#issuecomment-219267978
using Colors, Compose, DataFrames

immutable PointGeom2 <: Gadfly.GeometryElement
     tag::Symbol

    function PointGeom2(; tag::Symbol=Gadfly.Geom.empty_tag)
         new(tag)
     end
end


function Gadfly.element_aesthetics(::PointGeom2)
    [:x, :y, :size, :color, :shape]
end


function Gadfly.render(geom::PointGeom2, theme::Gadfly.Theme, aes::Gadfly.Aesthetics)

     default_aes = Gadfly.Aesthetics()
    default_aes.color = DataArrays.PooledDataArray(Colors.RGBA{Float32}[theme.default_color])
     default_aes.size = Measure[theme.default_point_size]
    aes = Gadfly.inherit(aes, default_aes)
    # aes.color arrives as a vector of RGB colors ->
    # so change them to back to RGBA colors
    alpha_color = map(theme.lowlight_color, aes.color)
    ctx = context()
    compose!(ctx, circle(aes.x, aes.y, aes.size, geom.tag), fill(alpha_color))
    return compose!(context(order=4), svgclass("geometry"), ctx)
end


# # Usage:
# point2 = PointGeom2
#
# D = DataFrame(x=1:5, y=randn(5), dcol=["a","b","b","a","c"], ccol=[1,2,2,1,3])
# dcolscale = Scale.color_discrete_manual(RGB(0.8,0,0), RGB(0,0.8,0), RGB(0,0,0.8))
# ccolscale = Scale.color_continuous(colormap=Scale.lab_gradient(colorant"green",colorant"red"))
# # In the next line, opacity = 0.5
# theme1 = Theme(default_point_size=10pt, lowlight_color=c -> RGBA{Float32}(c.r, c.g, c.b, 0.5))
#
# p1 = plot(D,x=:x,y=:y, color=:dcol, point2, theme1, dcolscale)
# p2 = plot(D,x=:x,y=:y, color=:ccol, point2, theme1, ccolscale)
# hstack(p1,p2)
