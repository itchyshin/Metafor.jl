"""Structured result for covariance-aware GLS and dependent-effects REML."""
struct DependentMetaResult
    beta::Vector{Float64}
    covariance::Matrix{Float64}
    variance_components::Dict{String,Float64}
    component_kernels::Dict{String,Matrix{Float64}}
    marginal_covariance::Matrix{Float64}
    qe::Float64
    qep::Float64
    converged::Bool
    method::Symbol
    row_indices::Vector{Int}
    design_columns::Vector{String}
    outcome_covariance::Union{Nothing,Matrix{Float64}}
end

function interval(result::DependentMetaResult; level=0.95)
    0 < level < 1 || throw(ArgumentError("level must be between zero and one"))
    z = _normal_quantile((1 + level) / 2)
    se = sqrt.(diag(result.covariance))
    result.beta .- z .* se, result.beta .+ z .* se
end

_dependent_float(x) = ismissing(x) ? NaN : (try Float64(x) catch; NaN end)
_dependent_array(x) = map(_dependent_float,x)
_dependent_finite_group(x) = ismissing(x) ? false : (x isa Real && !isfinite(x) ? false : true)
_dependent_finite_group(x::Tuple) = all(_dependent_finite_group,x)

function _dependent_missing_group(x)
    !_dependent_finite_group(x)
end

function _dependent_prepare(yi,V,X,component_pairs; extra_valid=nothing)
    y = vec(_dependent_array(yi))
    vfull = Matrix{Float64}(_dependent_array(V))
    n = length(y)
    size(vfull) == (n,n) || throw(ArgumentError("V must be square with one row per observation"))
    design = X === nothing ? ones(n,1) : Matrix{Float64}(_dependent_array(X))
    size(design,1) == n || throw(ArgumentError("X must have one row per input observation"))
    valid = isfinite.(y) .& vec(all(isfinite.(design),dims=2))
    extra_valid === nothing || (valid .&= extra_valid)
    if !all(valid)
        @warn "Missing or invalid rows omitted from analysis"
    end
    rows = findall(valid)
    isempty(rows) && throw(ArgumentError("no usable observations"))
    y = y[rows]
    design = design[rows,:]
    v = vfull[rows,rows]
    all(isfinite,v) || throw(ArgumentError("retained sampling covariance must be finite"))
    scale_v = max(maximum(abs,v),1.0)
    isapprox(v,v';atol=1e-10*scale_v,rtol=0) || throw(ArgumentError("sampling covariance must be symmetric"))
    v = (v + v') / 2
    try
        cholesky(Symmetric(v))
    catch
        throw(ArgumentError("sampling covariance must be positive definite"))
    end
    p = size(design,2)
    rank(design) == p || throw(ArgumentError("X is rank deficient"))
    kernels = Dict{String,Matrix{Float64}}()
    for (rawname,rawkernel) in component_pairs
        name = String(rawname)
        kernel_full = Matrix{Float64}(_dependent_array(rawkernel))
        size(kernel_full) == (n,n) || throw(ArgumentError("component $name must be square with one row per observation"))
        kernel = kernel_full[rows,rows]
        all(isfinite,kernel) || throw(ArgumentError("component $name must be finite on retained rows"))
        scale_k = max(maximum(abs,kernel),1.0)
        isapprox(kernel,kernel';atol=1e-10*scale_k,rtol=0) || throw(ArgumentError("component $name must be symmetric"))
        kernel = (kernel + kernel') / 2
        minimum(eigvals(Symmetric(kernel))) >= -1e-9*scale_k || throw(ArgumentError("component $name must be positive semidefinite"))
        haskey(kernels,name) && throw(ArgumentError("component names must be unique"))
        kernels[name] = kernel
    end
    y,v,design,kernels,rows
end

function _dependent_pairs(components)
    components === nothing && return Pair{String,Any}[]
    raw_pairs = components isa AbstractDict ? collect(Base.pairs(components)) : collect(components)
    names = String.(first.(raw_pairs))
    length(unique(names)) == length(names) || throw(ArgumentError("component names must be unique"))
    [String(pair.first) => pair.second for pair in raw_pairs]
end

function _dependent_state(y,V,X,G)
    C = V + G
    F = try
        cholesky(Symmetric(C))
    catch
        return nothing
    end
    logdet_c = 2sum(log,diag(F.L))
    inv_c = F \ Matrix{Float64}(I,length(y),length(y))
    ci_x = inv_c * X
    information = Symmetric(X' * ci_x)
    FX = try
        cholesky(information)
    catch
        return nothing
    end
    logdet_information = 2sum(log,diag(FX.L))
    covariance = FX \ Matrix{Float64}(I,size(X,2),size(X,2))
    beta = covariance * X' * (inv_c * y)
    py = inv_c*y - ci_x*beta
    P = inv_c - ci_x*covariance*ci_x'
    objective = 0.5*(logdet_c + logdet_information + dot(y,py) +
        (length(y)-size(X,2))*log(2π))
    (objective=objective,beta=beta,covariance=covariance,P=P,py=py,C=C)
end

function _dependent_gradient(state,derivatives)
    [0.5*(tr(state.P*K)-dot(state.py,K*state.py)) for K in derivatives]
end

function _dependent_box_fit(y,V,X,build,derivatives,starts,lower,upper)
    candidates = Tuple{Float64,Vector{Float64}}[]
    objective = x -> begin
        state = _dependent_state(y,V,X,build(x))
        state === nothing ? Inf : state.objective
    end
    function gradient!(G,x)
        state = _dependent_state(y,V,X,build(x))
        if state === nothing
            fill!(G,0.0)
        else
            G .= _dependent_gradient(state,derivatives(x))
        end
        nothing
    end
    options = Optim.Options(iterations=2000,outer_iterations=20,
                            g_abstol=1e-8,f_reltol=1e-13,f_abstol=1e-13)
    for start in starts
        result = Optim.optimize(objective,gradient!,lower,upper,Float64.(start),
            Optim.Fminbox(Optim.LBFGS()),options)
        if Optim.converged(result) && isfinite(Optim.minimum(result))
            push!(candidates,(Optim.minimum(result),Optim.minimizer(result)))
        end
    end
    isempty(candidates) && throw(ErrorException("REML variance-component optimizer did not converge"))
    first(sort(candidates,by=first))
end

function _dependent_component_fit(y,V,X,kernels,method)
    meth = Symbol(uppercase(String(method)))
    meth in (:FIXED,:FIXED_EFFECT) && (meth = :FE)
    meth in (:FE,:REML) || throw(ArgumentError("method must be FE or REML"))
    names = collect(keys(kernels))
    # Preserve insertion order when callers supplied a vector of pairs.
    mats = [kernels[name] for name in names]
    q = length(mats)
    q <= 8 || throw(ArgumentError("at most eight independent covariance components are supported"))
    theta = zeros(q)
    if meth == :REML && q > 0
        scale = max(var(y),mean(diag(V)),1e-6)
        upper = max(scale*1e6,1.0)
        lower_floor = max(scale*1e-12,1e-12)
        zero_state = _dependent_state(y,V,X,zeros(size(V)))
        candidates = Tuple{Float64,Vector{Float64}}[(zero_state.objective,zeros(q))]
        for mask in 1:(2^q-1)
            active = [j for j in 1:q if ((mask >> (j-1)) & 1) == 1]
            function build(partial)
                full = zeros(q); full[active] = partial
                G = zeros(size(V))
                for j in 1:q
                    G .+= full[j] .* mats[j]
                end
                G
            end
            derivatives = _ -> mats[active]
            for factor in (0.01,0.1,1.0,10.0)
                initial = fill(max(scale*factor,lower_floor*10),length(active))
                fit = _dependent_box_fit(y,V,X,build,derivatives,[initial],
                    fill(lower_floor,length(active)),fill(upper,length(active)))
                full = zeros(q); full[active] = fit[2]
                push!(candidates,(fit[1],full))
            end
        end
        theta = first(sort(candidates,by=first))[2]
    end
    G = zeros(size(V))
    for j in 1:q
        G .+= theta[j] .* mats[j]
    end
    state = _dependent_state(y,V,X,G)
    state === nothing && throw(ArgumentError("marginal covariance must be positive definite"))
    sampling_state = _dependent_state(y,V,X,zeros(size(V)))
    qe = dot(y,sampling_state.P*y)
    df = length(y)-size(X,2)
    qep = df > 0 ? ccdf(Chisq(df),qe) : NaN
    vc = Dict(names[j]=>Float64(theta[j]) for j in 1:q)
    vc,state,G,qe,qep,meth
end

function fit_meta_cov(yi,V;X=nothing,components=nothing,method=:REML,design_columns=nothing)
    pairs = _dependent_pairs(components)
    y,v,design,kernels,rows = _dependent_prepare(yi,V,X,pairs)
    vc,state,G,qe,qep,meth = _dependent_component_fit(y,v,design,kernels,method)
    labels = design_columns === nothing ? ["x$i" for i in 1:size(design,2)] : String.(design_columns)
    length(labels) == size(design,2) || throw(ArgumentError("design_columns must have one label per column of X"))
    DependentMetaResult(state.beta,state.covariance,vc,kernels,state.C,qe,qep,true,meth,
                        rows,labels,nothing)
end

function fit_meta_cov_formula(data,formula,V;id=nothing,components=nothing,method=:REML)
    Tables.istable(data) || throw(ArgumentError("data must implement the Tables.jl table interface"))
    columns = Tables.columntable(data)
    names = keys(columns)
    n = length(first(values(columns)))
    all(length(column) == n for column in values(columns)) ||
        throw(ArgumentError("table columns must have equal lengths"))
    variables = StatsModels.termvars(formula)
    all(name -> name in names,variables) || throw(ArgumentError("formula refers to a missing table column"))
    id === nothing || id in names || throw(ArgumentError("row ID column $id is missing"))
    keep = trues(n)
    for name in variables
        column = getproperty(columns,name)
        for i in 1:n
            value = column[i]
            if ismissing(value) || (value isa Real && !isfinite(value))
                keep[i] = false
            end
        end
    end
    positions = findall(keep)
    isempty(positions) && throw(ArgumentError("no complete formula rows"))
    filtered = NamedTuple{names}(map(column -> collect(column[positions]),values(columns)))
    frame = StatsModels.ModelFrame(formula,filtered)
    response = Float64.(StatsModels.response(frame))
    design = Matrix{Float64}(StatsModels.modelmatrix(frame))
    size(design,1) == length(positions) == length(response) ||
        throw(ArgumentError("formula design rows do not align with retained table rows"))
    full_y = fill(NaN,n)
    full_X = fill(NaN,n,size(design,2))
    full_y[positions] = response
    full_X[positions,:] = design
    columns_out = String.(StatsModels.coefnames(frame))
    fit = fit_meta_cov(full_y,V;X=full_X,components=components,
        method=method,design_columns=columns_out)
    rows = fit.row_indices
    ids = id === nothing ? Any[rows...] : Any[getproperty(columns,id)[i] for i in rows]
    length(unique(ids)) == length(ids) || throw(ArgumentError("row IDs must be unique"))
    TableMetaResult(fit,rows,ids,columns_out,formula)
end

function _dependent_group_kernel(values)
    n = length(values)
    [isequal(values[i],values[j]) ? 1.0 : 0.0 for i in 1:n,j in 1:n]
end

function _dependent_replace_rows(result,rows)
    DependentMetaResult(result.beta,result.covariance,result.variance_components,
        result.component_kernels,result.marginal_covariance,result.qe,result.qep,
        result.converged,result.method,rows,result.design_columns,result.outcome_covariance)
end

function fit_meta_nested(yi,V,groups;group_names=nothing,X=nothing,method=:REML,design_columns=nothing)
    y = vec(_dependent_array(yi)); n = length(y)
    group_values = if groups isa AbstractDict
        collect(pairs(groups))
    else
        vals = collect(groups)
        labels = group_names === nothing ? ["group$i" for i in eachindex(vals)] : String.(group_names)
        length(labels) == length(vals) || throw(ArgumentError("group_names must match groups"))
        [labels[i]=>vals[i] for i in eachindex(vals)]
    end
    isempty(group_values) && throw(ArgumentError("at least one grouping vector is required"))
    names = String.(first.(group_values))
    length(unique(names)) == length(names) || throw(ArgumentError("group names must be unique"))
    vectors = [collect(pair.second) for pair in group_values]
    all(length(v)==n for v in vectors) || throw(ArgumentError("each grouping vector must match yi"))
    design = X === nothing ? ones(n,1) : Matrix{Float64}(_dependent_array(X))
    size(design,1) == n || throw(ArgumentError("X must have one row per observation"))
    valid = isfinite.(y) .& vec(all(isfinite.(design),dims=2))
    for v in vectors
        valid .&= [_dependent_finite_group(v[i]) for i in eachindex(v)]
    end
    if !all(valid)
        @warn "Missing or invalid rows omitted from analysis"
    end
    rows = findall(valid)
    isempty(rows) && throw(ArgumentError("no usable observations"))
    size(V) == (n,n) || throw(ArgumentError("V must be square with one row per observation"))
    subset_groups = [v[rows] for v in vectors]
    kernels = [names[i]=>_dependent_group_kernel(subset_groups[i]) for i in eachindex(names)]
    result = fit_meta_cov(y[rows],_dependent_array(V)[rows,rows];X=design[rows,:],
        components=kernels,method=method,design_columns=design_columns)
    _dependent_replace_rows(result,rows)
end

function fit_meta_un(yi,V,study,outcome;outcome_levels,method=:REML)
    y = vec(_dependent_array(yi)); n = length(y)
    levels = collect(outcome_levels)
    length(levels) == 2 && length(unique(levels)) == 2 ||
        throw(ArgumentError("unstructured outcome covariance currently supports exactly two outcomes"))
    studies = collect(study); outcomes = collect(outcome)
    length(studies) == n == length(outcomes) || throw(ArgumentError("yi, study, and outcome lengths must match"))
    valid = isfinite.(y) .& [_dependent_finite_group(s) for s in studies] .&
        [_dependent_finite_group(o) for o in outcomes]
    if !all(valid)
        @warn "Missing or invalid rows omitted from analysis"
    end
    rows = findall(valid)
    isempty(rows) && throw(ArgumentError("no usable observations"))
    any(i -> !any(level -> isequal(outcomes[i],level),levels),rows) &&
        throw(ArgumentError("an observed outcome is absent from outcome_levels"))
    outcome_labels = outcomes[rows]
    study_labels = studies[rows]
    outcome_index = [findfirst(level -> isequal(label,level),levels) for label in outcome_labels]
    X = [Float64(isequal(outcome_labels[i],levels[j])) for i in eachindex(rows),j in eachindex(levels)]
    size(V) == (n,n) || throw(ArgumentError("V must be square with one row per observation"))
    y,v,X,_,local_rows = _dependent_prepare(y[rows],_dependent_array(V)[rows,rows],X,Pair{String,Any}[])
    length(local_rows) == length(rows) || throw(ArgumentError("outcome design contains an unusable row"))
    rank(X) == size(X,2) || throw(ArgumentError("outcome design is rank deficient"))
    same_study = [isequal(study_labels[i],study_labels[j]) for i in eachindex(rows),j in eachindex(rows)]
    scale = max(var(y),mean(diag(v)),1e-6)
    upper = max(sqrt(scale*1e6),1.0)
    function sigma_derivatives(p)
        a,b,c = p
        sigma = [a^2 a*b; a*b b^2+c^2]
        derivatives = ([2a b;b 0.0],[0.0 a;a 2b],[0.0 0.0;0.0 2c])
        sigma,derivatives
    end
    function build(p)
        sigma,_ = sigma_derivatives(p)
        [same_study[i,j] ? sigma[outcome_index[i],outcome_index[j]] : 0.0
            for i in eachindex(rows),j in eachindex(rows)]
    end
    function derivatives(p)
        _,ds = sigma_derivatives(p)
        [[same_study[i,j] ? d[outcome_index[i],outcome_index[j]] : 0.0
            for i in eachindex(rows),j in eachindex(rows)] for d in ds]
    end
    method_name = Symbol(uppercase(String(method)))
    if method_name in (:FE,:FIXED,:FIXED_EFFECT)
        method_name = :FE
        parameters = zeros(3)
    elseif method_name == :REML
        floor = max(upper*1e-12,1e-12)
        starts = [[upper*.001,0.0,upper*.001],[upper*.01,upper*.002,upper*.008],
                  [upper*.01,-upper*.002,floor*10],[floor*10,0.0,upper*.01],
                  [upper*.02,upper*.01,upper*.02]]
        fit = _dependent_box_fit(y,v,X,build,derivatives,starts,
            [floor,-upper,floor],[upper,upper,upper])
        parameters = fit[2]
    else
        throw(ArgumentError("method must be FE or REML"))
    end
    sigma,_ = sigma_derivatives(parameters)
    state = _dependent_state(y,v,X,build(parameters))
    state === nothing && throw(ArgumentError("marginal covariance must be positive definite"))
    sampling_state = _dependent_state(y,v,X,zeros(size(v)))
    qe = dot(y,sampling_state.P*y)
    df = length(y)-size(X,2)
    qep = df > 0 ? ccdf(Chisq(df),qe) : NaN
    vc = Dict("outcome_variance:$(levels[1])"=>sigma[1,1],
              "outcome_variance:$(levels[2])"=>sigma[2,2],
              "outcome_covariance:$(levels[1])/$(levels[2])"=>sigma[1,2])
    labels = ["outcome$(levels[1])","outcome$(levels[2])"]
    DependentMetaResult(state.beta,state.covariance,vc,Dict{String,Matrix{Float64}}(),
        state.C,qe,qep,true,method_name,rows,labels,sigma)
end
