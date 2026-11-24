using Metafor, DelimitedFiles, LinearAlgebra, Printf

const ROOT = normpath(joinpath(@__DIR__,"..","reference","dependent","v1"))

function read_table(name)
    raw, header = readdlm(joinpath(ROOT,name), ',', Any, '\n'; header=true)
    labels = String.(vec(header))
    column(key) = raw[:,findfirst(==(key),labels)]
    (; raw, labels, column)
end

function read_matrix(name)
    raw, _ = readdlm(joinpath(ROOT,name), ',', Any, '\n'; header=true)
    Float64.(raw[:,2:end])
end

function add_fit!(estimates,covariances,model,fit,labels,k)
    lower,upper = Metafor.interval(fit)
    se = sqrt.(diag(fit.covariance))
    for i in eachindex(labels)
        push!(estimates,(model,"beta",labels[i],fit.beta[i]))
        push!(estimates,(model,"se",labels[i],se[i]))
        push!(estimates,(model,"ci.lb",labels[i],lower[i]))
        push!(estimates,(model,"ci.ub",labels[i],upper[i]))
    end
    push!(estimates,(model,"QE","QE",fit.qe))
    push!(estimates,(model,"QEp","QEp",fit.qep))
    push!(estimates,(model,"k","k",k))
    push!(estimates,(model,"p","p",length(labels)))
    for i in eachindex(labels), j in eachindex(labels)
        push!(covariances,(model,labels[i],labels[j],fit.covariance[i,j]))
    end
end

function write_rows(path,header,rows)
    open(path,"w") do io
        println(io,join(header,','))
        for row in rows
            fields = [field isa AbstractFloat ? @sprintf("%.17g",field) : string(field) for field in row]
            println(io,join(fields,','))
        end
    end
end

function arg_value(args,key,default)
    i = findfirst(==(key),args)
    i === nothing && return default
    i < length(args) || error("$key needs a path")
    args[i+1]
end

function main()
    output = arg_value(ARGS,"--output",joinpath(@__DIR__,"dependent-julia-results.csv"))
    covariance_output = arg_value(ARGS,"--covariance-output",joinpath(@__DIR__,"dependent-julia-covariance.csv"))
    estimates = Tuple{String,String,String,Float64}[]
    covariances = Tuple{String,String,String,Float64}[]

    gls_table = read_table("gls-rows.csv")
    gls_y = Float64.(gls_table.column("yi"))
    gls_x = Float64.(gls_table.column("x"))
    gls_X = hcat(ones(length(gls_y)),gls_x)
    gls = fit_meta_cov(gls_y,read_matrix("gls-V.csv");X=gls_X,
        design_columns=["intrcpt","x"],method=:FE)
    add_fit!(estimates,covariances,"correlated-gls",gls,["intrcpt","x"],length(gls_y))

    nested_table = read_table("nested-rows.csv")
    nested_y = Float64.(nested_table.column("yi"))
    nested_x = Float64.(nested_table.column("x"))
    nested_X = hcat(ones(length(nested_y)),nested_x)
    study = string.(nested_table.column("study"))
    effect = string.(nested_table.column("effect_local"))
    nested = fit_meta_nested(nested_y,read_matrix("nested-V.csv"),
        [study,collect(zip(study,effect))];group_names=["study","study/effect"],
        X=nested_X,design_columns=["intrcpt","x"],method=:REML)
    add_fit!(estimates,covariances,"nested-reml",nested,["intrcpt","x"],length(nested_y))
    push!(estimates,("nested-reml","variance","study",nested.variance_components["study"]))
    push!(estimates,("nested-reml","variance","nested-effect",nested.variance_components["study/effect"]))

    berkey_table = read_table("berkey-rows.csv")
    berkey_y = Float64.(berkey_table.column("yi"))
    berkey = fit_meta_un(berkey_y,read_matrix("berkey-V.csv"),
        string.(berkey_table.column("study")),string.(berkey_table.column("outcome"));
        outcome_levels=["benefit","harm"],method=:REML)
    berkey_labels = ["outcomebenefit","outcomeharm"]
    add_fit!(estimates,covariances,"berkey-un",berkey,berkey_labels,length(berkey_y))
    sigma = berkey.outcome_covariance
    between = sigma[1,2]
    push!(estimates,("berkey-un","variance","benefit",sigma[1,1]))
    push!(estimates,("berkey-un","variance","harm",sigma[2,2]))
    push!(estimates,("berkey-un","covariance","benefit-harm",between))
    push!(estimates,("berkey-un","correlation","benefit-harm",between/sqrt(sigma[1,1]*sigma[2,2])))

    write_rows(output,["model","quantity","name","estimate"],estimates)
    write_rows(covariance_output,["model","row","column","estimate"],covariances)
    println("Wrote $(length(estimates)) R-comparable estimates to $output")
    println("Wrote $(length(covariances)) coefficient-covariance entries to $covariance_output")
end

main()
