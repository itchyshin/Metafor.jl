using Metafor
using DelimitedFiles
using LinearAlgebra
using Printf

case_arg = findfirst(arg -> startswith(arg, "--case="), ARGS)
case = case_arg === nothing ? "all" : split(ARGS[case_arg], "=", limit=2)[2]
case in ("all", "effects", "models", "moderator", "prediction", "forest") || error("unknown --case=$case")
root = normpath(joinpath(@__DIR__, ".."))
raw, header = readdlm(joinpath(root, "reference/v1/bcg.csv"), ',', Any, '\n'; header=true)
header = String.(vec(header))
column(name) = [row[findfirst(==(name), header)] for row in eachrow(raw)]
numeric(name) = Float64.(column(name))
yi, vi = escalc_rr(numeric("tpos"), numeric("tneg"), numeric("cpos"), numeric("cneg"))
latitude = numeric("ablat")
labels = string.(column("author"))
designs = (fixed=ones(length(yi),1),random=ones(length(yi),1),
           latitude=hcat(ones(length(latitude)),latitude))
selected_models = case == "all" ? (:fixed,:random,:latitude) : case == "models" ? (:fixed,:random) : case in ("moderator", "prediction") ? (:latitude,) : case == "forest" ? (:random,) : ()
models = Dict{Symbol,Any}()
for name in selected_models
    models[name] = name == :fixed ? fit_meta(yi,vi;method=:FE) :
        name == :latitude ? fit_meta(yi,vi;X=designs.latitude) : fit_meta(yi,vi)
end
coefficient_labels = (fixed=["intrcpt"], random=["intrcpt"], latitude=["intrcpt","ablat"])
predictions = case in ("all", "moderator", "prediction") ?
    predict(models[:latitude],hcat(ones(3),[0.0,30.0,60.0])) : nothing
forest = case in ("all", "forest") ?
    forest_plot_data(yi,vi,labels,models[:random]) : nothing

fmt(x) = join((@sprintf("%.16g", value) for value in x), ",")
if case in ("all", "effects")
 for i in eachindex(yi)
    println("EFFECT|$i|$(@sprintf("%.16g",yi[i]))|$(@sprintf("%.16g",vi[i]))")
 end
end
for name in selected_models
    model = models[name]
    se = sqrt.(diag(model.covariance))
    z = 1.959963984540054
    println("RESULT|$name|beta=$(fmt(model.beta))|se=$(fmt(se))|tau2=$(@sprintf("%.16g",model.tau2))|QE=$(@sprintf("%.16g",model.q))|I2=$(@sprintf("%.16g",model.i2))|H2=$(@sprintf("%.16g",model.h2))|ci_lb=$(fmt(model.beta-z.*se))|ci_ub=$(fmt(model.beta+z.*se))")
    println("COV|$name|$(fmt(vec(model.covariance)))")
    println("COVLABELS|$name|$(join(getproperty(coefficient_labels,name),','))")
    println("ROWS|$name|$(join(model.row_indices,','))")
    X = getproperty(designs,name)
    println("DESIGN|$name|$(size(X,1))|$(size(X,2))|$(fmt(vec(permutedims(X))))")
end
if case in ("all", "forest")
 summary = forest["summary"]
 println("FOREST_SUMMARY|estimate=$(@sprintf("%.16g",summary["estimate"]))|se=$(@sprintf("%.16g",summary["se"]))|ci_lb=$(@sprintf("%.16g",summary["ci_lb"]))|ci_ub=$(@sprintf("%.16g",summary["ci_ub"]))|pi_lb=$(@sprintf("%.16g",summary["pi_lb"]))|pi_ub=$(@sprintf("%.16g",summary["pi_ub"]))|tau2=$(@sprintf("%.16g",summary["tau2"]))")
end
if case in ("all", "prediction", "moderator")
for i in eachindex(predictions.estimate)
    println("PRED|latitude|x=$(@sprintf("%.16g",[0.0,30.0,60.0][i]))|estimate=$(@sprintf("%.16g",predictions.estimate[i]))|se=$(@sprintf("%.16g",predictions.se[i]))|ci_lb=$(@sprintf("%.16g",predictions.ci_lb[i]))|ci_ub=$(@sprintf("%.16g",predictions.ci_ub[i]))|pi_lb=$(@sprintf("%.16g",predictions.pi_lb[i]))|pi_ub=$(@sprintf("%.16g",predictions.pi_ub[i]))")
end
end

# Write a plain CSV forest-data artifact and an original SVG without an optional backend.
if case in ("all", "forest")
data_path = joinpath(@__DIR__, "bcg-forest-data.csv")
open(data_path,"w") do io
    println(io,"row,label,estimate,se,ci_lb,ci_ub,pi_lb,pi_ub,tau2")
    for row in forest["rows"]
        println(io,"$(row["row"]),\"$(replace(row["label"], '\"'=>"'"))\",$(row["estimate"]),$(row["se"]),$(row["ci_lb"]),$(row["ci_ub"]),,,")
    end
    s=forest["summary"]
    println(io,"pooled,\"REML mean\",$(s["estimate"]),$(s["se"]),$(s["ci_lb"]),$(s["ci_ub"]),$(s["pi_lb"]),$(s["pi_ub"]),$(s["tau2"])")
end

rows = forest["rows"]
length(rows) == 13 || error("forest plot data must contain all 13 studies")
summary = forest["summary"]
width,left,right = 1120,330.0,1080.0
top,rowheight = 92.0,28.0
summary_y = top+rowheight*length(rows)+24
height = summary_y+72
low = min(minimum(row["ci_lb"] for row in rows),summary["pi_lb"])
high = max(maximum(row["ci_ub"] for row in rows),summary["pi_ub"])
pad = .06*(high-low); low-=pad; high+=pad
x(value) = left+(value-low)/(high-low)*(right-left)
escape_xml(s) = replace(string(s),"&"=>"&amp;","<"=>"&lt;",">"=>"&gt;","\""=>"&quot;")
svg = String["<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"$width\" height=\"$height\" viewBox=\"0 0 $width $height\">",
    "<style>text{font:14px system-ui,sans-serif;fill:#1b2d3a}.small{font-size:12px}.ci{stroke:#345f74;stroke-width:2}.summary{stroke:#a13c31;fill:#a13c31}.axis{stroke:#8a9aa3;stroke-width:1}</style>",
    "<text x=\"20\" y=\"32\" font-size=\"20\" font-weight=\"700\">BCG study effects</text>",
    "<text x=\"20\" y=\"54\" class=\"small\">Study log risk ratios with 95% normal intervals</text>",
    "<line x1=\"$(x(0))\" y1=\"68\" x2=\"$(x(0))\" y2=\"$(summary_y+18)\" class=\"axis\" stroke-dasharray=\"4 4\"/>" ]
for (i,row) in enumerate(rows)
    row_y=top+rowheight*(i-1)
    push!(svg,"<text x=\"20\" y=\"$(row_y+5)\">$(escape_xml(row["label"]))</text>")
    push!(svg,"<line x1=\"$(x(row["ci_lb"]))\" y1=\"$row_y\" x2=\"$(x(row["ci_ub"]))\" y2=\"$row_y\" class=\"ci\"/><rect x=\"$(x(row["estimate"])-5)\" y=\"$(row_y-5)\" width=\"10\" height=\"10\" fill=\"#345f74\"/>")
end
summary_position=summary_y
push!(svg,"<line x1=\"20\" y1=\"$(summary_position-15)\" x2=\"$right\" y2=\"$(summary_position-15)\" class=\"axis\"/><text x=\"20\" y=\"$(summary_position+5)\" font-weight=\"700\">REML mean</text>")
push!(svg,"<line x1=\"$(x(summary["pi_lb"]))\" y1=\"$summary_position\" x2=\"$(x(summary["pi_ub"]))\" y2=\"$summary_position\" class=\"summary\" stroke-dasharray=\"5 4\" opacity=\".65\"/><polygon points=\"$(x(summary["estimate"])),$(summary_position-8) $(x(summary["ci_ub"])),$summary_position $(x(summary["estimate"])),$(summary_position+8) $(x(summary["ci_lb"])),$summary_position\" class=\"summary\"/><text x=\"$left\" y=\"$(height-16)\" class=\"small\">log risk ratio (negative values favor vaccination)</text></svg>")
plot_path=joinpath(@__DIR__,"bcg-forest.svg")
write(plot_path,join(svg,"\n")*"\n")
filesize(plot_path) > 0 || error("forest SVG is empty")
println("BCG_EXAMPLE_OK case=$case")
case in ("all", "forest") && println("FOREST_PLOT_OK $plot_path")
end
