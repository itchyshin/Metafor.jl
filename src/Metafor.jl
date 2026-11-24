module Metafor

using LinearAlgebra
using Statistics
using StatsModels
using Tables
using Distributions
using Optim

export MetaResult, PredictionResult, TableMetaResult, escalc_rr, fit_meta,
       fit_meta_formula, fit_meta_cov_formula, fit_phylo, fit_meta_cov, fit_meta_nested, fit_meta_un,
       DependentMetaResult, predict, forest_plot_data

struct MetaResult{T<:AbstractFloat}
    beta::Vector{T}
    covariance::Matrix{T}
    tau2::T
    q::T
    i2::T
    h2::T
    converged::Bool
    method::Symbol
    row_indices::Vector{Int}
end

struct PredictionResult{T<:AbstractFloat}
    estimate::Vector{T}
    se::Vector{T}
    ci_lb::Vector{T}
    ci_ub::Vector{T}
    pi_lb::Vector{T}
    pi_ub::Vector{T}
end

struct TableMetaResult{R,F}
    result::R
    row_indices::Vector{Int}
    row_ids::Vector{Any}
    design_columns::Vector{String}
    formula::F
end

function fit_meta_formula(data, formula; vi=:vi, id=nothing, method=:REML)
    Tables.istable(data) || throw(ArgumentError("data must implement the Tables.jl table interface"))
    columns = Tables.columntable(data)
    names = keys(columns)
    vi in names || throw(ArgumentError("sampling-variance column $vi is missing"))
    n = length(getproperty(columns,vi))
    variables = unique(vcat(StatsModels.termvars(formula),[vi]))
    all(name -> name in names, variables) || throw(ArgumentError("formula refers to a missing table column"))
    formula_variables = StatsModels.termvars(formula)
    variance_column = getproperty(columns,vi)
    for i in 1:n
        complete_formula_row = all(name -> begin
            value = getproperty(columns,name)[i]
            !ismissing(value) && (!(value isa Real) || isfinite(value))
        end, formula_variables)
        if complete_formula_row && !ismissing(variance_column[i])
            variance = try Float64(variance_column[i]) catch; NaN end
            variance < 0 && throw(ArgumentError("sampling variances must be nonnegative"))
            if iszero(variance)
                Symbol(uppercase(String(method))) == :FE && throw(ArgumentError("fixed-effect fitting does not accept zero sampling variances"))
                Symbol(uppercase(String(method))) == :REML && throw(ArgumentError("REML with zero sampling variances is not supported"))
            end
        end
    end
    keep = trues(n)
    for name in variables
        column = getproperty(columns,name)
        length(column) == n || throw(ArgumentError("table columns must have equal lengths"))
        for i in 1:n
            if ismissing(column[i])
                keep[i] = false
            elseif name == vi
                value = try Float64(column[i]) catch; NaN end
                keep[i] &= isfinite(value) && value > 0
            end
        end
    end
    positions = findall(keep)
    isempty(positions) && throw(ArgumentError("no complete rows with positive sampling variances"))
    filtered = NamedTuple{names}(map(column -> collect(column[keep]), values(columns)))
    frame = StatsModels.ModelFrame(formula, filtered)
    y = Float64.(StatsModels.response(frame))
    X = Matrix{Float64}(StatsModels.modelmatrix(frame))
    variances = Float64.(getproperty(columns,vi)[positions])
    valid = isfinite.(y) .& isfinite.(variances) .& (variances .> 0) .& vec(all(isfinite.(X),dims=2))
    rows = positions[valid]
    result = fit_meta(y[valid],variances[valid];X=X[valid,:],method=method)
    ids = if id === nothing
        Any[rows...]
    else
        id in names || throw(ArgumentError("row ID column $id is missing"))
        Any[getproperty(columns,id)[i] for i in rows]
    end
    length(unique(ids)) == length(ids) || throw(ArgumentError("row IDs must be unique"))
    TableMetaResult(result,rows,ids,String.(StatsModels.coefnames(frame)),formula)
end

function _normal_quantile(p::Real)
    0 < p < 1 || throw(ArgumentError("probability must be in (0, 1)"))
    a=(-39.6968302866538,220.946098424522,-275.928510446969,138.357751867269,-30.6647980661472,2.50662827745924)
    b=(-54.4760987982241,161.585836858041,-155.698979859887,66.8013118877197,-13.2806815528857)
    c=(-.00778489400243029,-.322396458041136,-2.40075827716184,-2.54973253934373,4.37466414146497,2.93816398269878)
    d=(.00778469570904146,.32246712907004,2.445134137143,3.75440866190742)
    z = if p < .02425
        q=sqrt(-2log(p))
        (((((c[1]*q+c[2])*q+c[3])*q+c[4])*q+c[5])*q+c[6])/((((d[1]*q+d[2])*q+d[3])*q+d[4])*q+1)
    elseif p > .97575
        -_normal_quantile(1-p)
    else
        q=p-.5; r=q*q
        (((((a[1]*r+a[2])*r+a[3])*r+a[4])*r+a[5])*r+a[6])*q/(((((b[1]*r+b[2])*r+b[3])*r+b[4])*r+b[5])*r+1)
    end
    for _ in 1:2
        cdf = 0.5*ccall((:erfc, Base.Math.libm), Cdouble, (Cdouble,), -z/sqrt(2.0))
        density = exp(-z*z/2)/sqrt(2π)
        z -= (cdf-p)/density
    end
    z
end

function predict(result::MetaResult, Xnew=nothing; level=0.95)
    0 < level < 1 || throw(ArgumentError("level must be between zero and one"))
    if Xnew === nothing
        length(result.beta) == 1 || throw(ArgumentError("Xnew is required for a model with moderators"))
        X = ones(1,1)
    else
        X = Xnew isa AbstractVector ? reshape(Float64.(Xnew),1,:) : Matrix{Float64}(Xnew)
    end
    size(X,2) == length(result.beta) && all(isfinite,X) || throw(ArgumentError("Xnew must be finite with one column per coefficient"))
    estimate = X*result.beta
    variance = [dot(view(X,i,:),result.covariance*view(X,i,:)) for i in axes(X,1)]
    se = sqrt.(max.(variance,0.0))
    z = _normal_quantile((1+level)/2)
    ci_lb, ci_ub = estimate-z.*se, estimate+z.*se
    if result.method == :REML
        pi_se = sqrt.(max.(variance .+ result.tau2,0.0))
        pi_lb, pi_ub = estimate-z.*pi_se, estimate+z.*pi_se
    else
        pi_lb = fill(NaN,length(estimate)); pi_ub = fill(NaN,length(estimate))
    end
    PredictionResult(estimate,se,ci_lb,ci_ub,pi_lb,pi_ub)
end

function forest_plot_data(yi, vi, labels, pooled=nothing; level=0.95)
    length(yi) == length(vi) == length(labels) || throw(ArgumentError("yi, vi and labels must have equal lengths"))
    z = _normal_quantile((1+level)/2)
    rows = Dict{String,Any}[]
    for i in eachindex(yi)
        y,v = Float64(yi[i]),Float64(vi[i])
        if isfinite(y) && isfinite(v) && v > 0
            se = sqrt(v)
            push!(rows,Dict("row"=>i,"label"=>string(labels[i]),"estimate"=>y,"se"=>se,"ci_lb"=>y-z*se,"ci_ub"=>y+z*se))
        end
    end
    summary = nothing
    if pooled !== nothing
        p = predict(pooled; level=level)
        summary = Dict("estimate"=>p.estimate[1],"se"=>p.se[1],"ci_lb"=>p.ci_lb[1],"ci_ub"=>p.ci_ub[1],"pi_lb"=>p.pi_lb[1],"pi_ub"=>p.pi_ub[1],"tau2"=>pooled.tau2)
    end
    Dict("scale"=>"log risk ratio","level"=>Float64(level),"rows"=>rows,"summary"=>summary)
end

function escalc_rr(ai, bi, ci, di; add=0.5, to=:only0)
    n = length(ai)
    length(bi) == n == length(ci) == length(di) || throw(ArgumentError("count vectors must have equal lengths"))
    yi = fill(NaN, n)
    vi = fill(NaN, n)
    for i in 1:n
        counts = (ai[i],bi[i],ci[i],di[i])
        any(ismissing,counts) && continue
        a, b, c, d = Float64.(counts)
        if !(isfinite(a) && isfinite(b) && isfinite(c) && isfinite(d))
            continue
        end
        all(x -> x >= 0 && isinteger(x), (a,b,c,d)) || throw(ArgumentError("counts must be nonnegative integers"))
        zero = a == 0 || b == 0 || c == 0 || d == 0
        if to == :only0 && zero || to == :if0all && any(x -> !ismissing(x) && isfinite(x) && iszero(x), (ai...,bi...,ci...,di...)) || to == :all
            a += add; b += add; c += add; d += add
        elseif to == :none && (a == 0 || c == 0)
            continue
        elseif !(to in (:only0, :if0all, :all, :none))
            throw(ArgumentError("unsupported zero-cell policy"))
        end
        nt, nc = a+b, c+d
        if a > 0 && c > 0 && nt > 0 && nc > 0
            yi[i] = log((a/nt)/(c/nc))
            vi[i] = 1/a - 1/nt + 1/c - 1/nc
        end
    end
    yi, vi
end

function fit_meta(yi, vi; X=nothing, method=:REML, threshold=1e-5)
    length(yi) == length(vi) || throw(ArgumentError("yi and vi must have equal lengths"))
    yall = [ismissing(x) ? NaN : Float64(x) for x in yi]
    vall = [ismissing(x) ? NaN : Float64(x) for x in vi]
    design = X === nothing ? ones(length(yi),1) : Matrix{Float64}(X)
    size(design,1) == length(yi) || throw(ArgumentError("X must have one row per input"))
    meth = Symbol(uppercase(String(method)))
    zero_variance = [isfinite(yall[i]) && iszero(vall[i]) && all(isfinite,view(design,i,:)) for i in eachindex(yall)]
    any(isfinite.(vall) .& (vall .< 0)) && throw(ArgumentError("sampling variances must be nonnegative"))
    if any(zero_variance)
        meth == :FE && throw(ArgumentError("fixed-effect fitting does not accept zero sampling variances"))
        meth == :REML && throw(ArgumentError("REML with zero sampling variances is not supported"))
    end
    keep = [isfinite(yall[i]) && isfinite(vall[i]) && vall[i] > 0 for i in eachindex(yall)]
    keep .&= [all(isfinite,view(design,i,:)) for i in axes(design,1)]
    !all(keep) && @warn "Missing or invalid rows omitted from analysis"
    rows = findall(keep)
    y, v = yall[keep], vall[keep]
    isempty(y) && throw(ArgumentError("no usable observations"))
    design = design[keep,:]
    rank(design) == size(design,2) || throw(ArgumentError("X is rank deficient"))
    k, p = size(design)
    function at(tau)
        w = 1.0 ./ (v .+ tau)
        cov = inv(design' * (w .* design))
        beta = cov * (design' * (w .* y))
        beta, cov
    end
    tau = 0.0
    if meth == :REML
        if k == 1 && p == 1
            beta,cov = at(0.0)
            return MetaResult(beta,cov,0.0,0.0,0.0,1.0,true,meth,rows)
        end
        P0 = I - design * ((design' * design) \ design')
        tau = max(0.0, (dot(y, P0*y) - tr(P0*Diagonal(v))) / (k-p))
        converged = false
        for _ in 1:1000
            w = 1.0 ./ (v .+ tau)
            W = Diagonal(w)
            P = W - W*design*((design' * W * design) \ (design' * W))
            adj = (dot(y, (P*P)*y) - tr(P)) / tr(P*P)
            while tau + adj < 0
                adj /= 2
            end
            newtau = tau + adj
            if abs(newtau-tau) <= threshold
                tau = newtau
                converged = true
                break
            end
            tau = newtau
        end
        converged || throw(ErrorException("REML Fisher scoring did not converge"))
        function objective(t)
            w = 1.0 ./ (v .+ t)
            beta,cov = at(t)
            residual = y-design*beta
            q = sum(w .* residual.^2)
            0.5*(sum(log.(v .+ t)) + logdet(Symmetric(design'*(w.*design))) + q + (k-p)*log(2π))
        end
        interior_objective, boundary_objective = objective(tau), objective(0.0)
        if tau > 1e-5 && interior_objective-boundary_objective > eps(Float64)^0.25
            @warn "REML Fisher scoring found an inferior local maximum; the zero-heterogeneity boundary was selected"
            tau = 0.0
        end
    elseif meth != :FE
        throw(ArgumentError("method must be FE or REML"))
    end
    beta, cov = at(tau)
    w0 = 1.0 ./ v
    W0 = Diagonal(w0)
    P0 = W0 - W0*design*((design' * W0 * design) \ (design' * W0))
    q = max(0.0, dot(y, P0*y))
    df = k-p
    if meth == :FE
        i2 = q > 0 ? max(0.0, 100*(q-df)/q) : 0.0
        h2 = df > 0 ? q/df : NaN
    else
        vt = df/tr(P0)
        i2 = 100*tau/(vt+tau)
        h2 = 1+tau/vt
    end
    MetaResult(beta,cov,tau,q,i2,h2,true,meth,rows)
end

function fit_phylo(yi, vi, species, correlation, correlation_labels; X=nothing, method=:REML)
    n = length(yi)
    length(vi) == n == length(species) || throw(ArgumentError("yi, vi and species must have equal lengths"))
    y = [ismissing(x) ? NaN : Float64(x) for x in yi]
    v = [ismissing(x) ? NaN : Float64(x) for x in vi]
    A = Matrix{Float64}(correlation)
    size(A,1) == size(A,2) || throw(ArgumentError("correlation must be square"))
    axis_labels = collect(correlation_labels)
    length(axis_labels) == size(A,1) && length(unique(axis_labels)) == length(axis_labels) || throw(ArgumentError("correlation labels must be unique and match matrix dimensions"))
    isapprox(A,A'; atol=1e-12,rtol=0) || throw(ArgumentError("correlation must be symmetric"))
    minimum(eigvals(Symmetric(A))) >= -1e-10 || throw(ArgumentError("correlation must be positive semidefinite"))
    design = X === nothing ? ones(length(y),1) : Matrix{Float64}(X)
    size(design,1) == length(y) || throw(ArgumentError("X must have one row per outcome"))
    keep = [isfinite(y[i]) && isfinite(v[i]) && v[i] > 0 && !ismissing(species[i]) && all(isfinite,view(design,i,:)) for i in eachindex(y)]
    rows = findall(keep)
    isempty(rows) && throw(ArgumentError("no usable observations"))
    y, v, species, design = y[keep], v[keep], species[keep], design[keep,:]
    labels = unique(species)
    all(label -> label in axis_labels, labels) || throw(ArgumentError("an observed species is absent from the correlation labels"))
    idx = [findfirst(==(label),axis_labels) for label in labels]
    A = A[idx,idx]
    Z = Float64.([species[i] == labels[j] for i in eachindex(species), j in eachindex(labels)])
    p = size(design,2)
    rank(design) == p || throw(ArgumentError("X is rank deficient"))
    projected_Z = design * (design \ Z)
    confounded = norm(Z - projected_Z) <= 1e-10 * max(norm(Z), 1.0)
    K = Z*A*Z'
    function at(tau)
        C = Diagonal(v) + tau*K
        F = cholesky(Symmetric(C))
        precision = F \ Matrix{Float64}(I,length(y),length(y))
        cov = inv(design'*precision*design)
        beta = cov*(design'*precision*y)
        residual = y-design*beta
        q = dot(residual,precision*residual)
        objective = 0.5*(2sum(log,diag(F.L)) + logdet(Symmetric(design'*precision*design)) + q + (length(y)-p)*log(2π))
        beta,cov,q,objective
    end
    meth = Symbol(uppercase(String(method)))
    if meth == :FE
        tau = 0.0
    elseif meth == :REML
        if confounded
            @warn "Phylogenetic variance is not identifiable from the fixed-effect design; setting tau² to zero"
            tau = 0.0
        else
            upper = max(var(y)*100,1.0)
            bracketed = false
            for _ in 1:12
                a,b = 0.0,upper
                gr = (sqrt(5.0)-1)/2
                c,d = b-gr*(b-a),a+gr*(b-a)
                fc,fd = at(c)[4],at(d)[4]
                for _ in 1:300
                    if b-a <= 1e-12*(1+abs(a)+abs(b)); break; end
                    if fc < fd
                        b,d,fd = d,c,fc; c=b-gr*(b-a); fc=at(c)[4]
                    else
                        a,c,fc = c,d,fd; d=a+gr*(b-a); fd=at(d)[4]
                    end
                end
                candidates = [(0.0,at(0.0)[4]),((a+b)/2,at((a+b)/2)[4]),(upper,at(upper)[4])]
                tau = first(sort(candidates,by=last))[1]
                if tau < upper*(1-1e-6)
                    bracketed = true
                    break
                end
                upper *= 10
            end
            bracketed || throw(ErrorException("phylogenetic REML optimum remained at the expanding upper bound"))
        end
    else
        throw(ArgumentError("method must be FE or REML"))
    end
    beta,cov,q,_ = at(tau)
    MetaResult(beta,cov,tau,q,NaN,NaN,true,meth,rows)
end

include("dependent.jl")

end
