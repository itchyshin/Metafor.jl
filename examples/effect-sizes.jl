using Metafor, DelimitedFiles, Printf

const ROOT = normpath(joinpath(@__DIR__,".."))
const FIELDS = ["measure","kind","method","row","author","yi","vi","beta","se","tau2","QE","I2","H2","ci_lb","ci_ub"]

function columns(path)
    raw, header = readdlm(path, ',', Any, '\n'; header=true)
    names = String.(vec(header))
    column(name) = raw[:,findfirst(==(name),names)]
    (; raw, names, column)
end

function csv_value(value)
    value === nothing && return ""
    value === missing && return ""
    value isa AbstractFloat && !isfinite(value) && return "NA"
    value isa AbstractFloat && return @sprintf("%.17g",value)
    string(value)
end

function add_record!(rows, measure, kind; method="", row="", author="", yi="", vi="",
                     beta="", se="", tau2="", QE="", I2="", H2="", ci_lb="", ci_ub="")
    push!(rows,(measure,kind,method,row,author,yi,vi,beta,se,tau2,QE,I2,H2,ci_lb,ci_ub))
end

function main()
    case_index = findfirst(arg -> startswith(arg,"--case="),ARGS)
    case = case_index === nothing ? "all" : split(ARGS[case_index],"=",limit=2)[2]
    case in ("all","odds-ratio","risk-difference","scale","zero-correction") || error("unknown --case=$case")
    table = columns(joinpath(ROOT,"reference","v1","bcg.csv"))
    count(name) = Float64.(table.column(name))
    authors = string.(table.column("author"))
    functions = Dict("OR"=>escalc_or,"RD"=>escalc_rd,"RR"=>escalc_rr)
    selected = Dict("odds-ratio"=>["OR"],"risk-difference"=>["RD"],"scale"=>["RR","OR","RD"],"all"=>["OR","RD"])
    rows = Tuple[]

    if case == "zero-correction"
        a,b,c,d = [0,2],[10,8],[2,3],[8,7]
        for measure in ("OR","RD"), policy in (:only0,:all,:if0all,:none)
            yi,vi = functions[measure](a,b,c,d;to=policy)
            for i in eachindex(yi)
                add_record!(rows,measure,"correction";method=String(policy),row=i,yi=yi[i],vi=vi[i])
            end
        end
    else
        for measure in selected[case]
            yi,vi = functions[measure](count("tpos"),count("tneg"),count("cpos"),count("cneg"))
            for i in eachindex(yi)
                add_record!(rows,measure,"effect";row=i,author=authors[i],yi=yi[i],vi=vi[i])
            end
            for method in (:FE,:REML)
                fit = fit_meta(yi,vi;method=method)
                se = sqrt(fit.covariance[1,1]); z = 1.959963984540054
                low,high = fit.beta[1]-z*se, fit.beta[1]+z*se
                add_record!(rows,measure,"model";method=String(method),beta=fit.beta[1],se=sqrt(fit.covariance[1,1]),
                            tau2=fit.tau2,QE=fit.q,I2=fit.i2,H2=fit.h2,ci_lb=low[1],ci_ub=high[1])
            end
        end
    end

    output = joinpath(@__DIR__,"generated","effect-sizes","julia-$(case).csv")
    mkpath(dirname(output))
    open(output,"w") do io
        println(io,join(FIELDS,','))
        for row in rows
            println(io,join(csv_value.(row),','))
        end
    end
    isempty(rows) && error("effect-size example produced no results")
    println("EFFECT_SIZE_EXAMPLE_OK case=$case rows=$(length(rows)) $output")
end

main()
