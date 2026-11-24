const DEP_ROOT = joinpath(root,"reference","dependent","v1")

function dep_csv(name)
    raw, header = readdlm(joinpath(DEP_ROOT,name), ',', Any, '\n'; header=true)
    names = String.(vec(header))
    column(key) = raw[:,findfirst(==(key),names)]
    (; raw, names, column)
end

function dep_matrix(name)
    raw, _ = readdlm(joinpath(DEP_ROOT,name), ',', Any, '\n'; header=true)
    Float64.(raw[:,2:end])
end

function dep_expected(model, quantity, name)
    tab = dep_csv("results.csv")
    rows = [i for i in axes(tab.raw,1) if String(tab.raw[i,1]) == model &&
        String(tab.raw[i,2]) == quantity && String(tab.raw[i,3]) == name]
    length(rows) == 1 || error("expected one R reference row for $model/$quantity/$name")
    Float64(tab.raw[only(rows),4])
end

function dep_covariance_expected(model, labels)
    tab = dep_csv("coefficient-covariance.csv")
    [begin
        rows = [i for i in axes(tab.raw,1) if String(tab.raw[i,1]) == model &&
            String(tab.raw[i,2]) == labels[r] && String(tab.raw[i,3]) == labels[c]]
        length(rows) == 1 || error("missing R coefficient covariance entry")
        Float64(tab.raw[only(rows),4])
    end for r in eachindex(labels), c in eachindex(labels)]
end

function dep_compare_coefficients(model, fit, labels)
    beta = [dep_expected(model,"beta",label) for label in labels]
    se = [dep_expected(model,"se",label) for label in labels]
    lower = [dep_expected(model,"ci.lb",label) for label in labels]
    upper = [dep_expected(model,"ci.ub",label) for label in labels]
    z = 1.959963984540054
    @test fit.beta ≈ beta rtol=1e-5 atol=1e-6
    @test sqrt.(diag(fit.covariance)) ≈ se rtol=1e-5 atol=1e-6
    @test fit.beta .- z .* se ≈ lower rtol=1e-5 atol=1e-6
    @test fit.beta .+ z .* se ≈ upper rtol=1e-5 atol=1e-6
    @test fit.covariance ≈ dep_covariance_expected(model,labels) rtol=1e-5 atol=1e-7
    @test fit.qe ≈ dep_expected(model,"QE","QE") rtol=1e-5 atol=1e-6
    @test fit.qep ≈ dep_expected(model,"QEp","QEp") rtol=5e-4 atol=1e-24
end

if selected("dependent-model") || selected("all")
    @testset "dependent models against pinned R reference" begin
        gls = dep_csv("gls-rows.csv")
        y = Float64.(gls.column("yi"))
        x = Float64.(gls.column("x"))
        X = hcat(ones(length(y)),x)
        fit = fit_meta_cov(y,dep_matrix("gls-V.csv");X=X,
                           design_columns=["intrcpt","x"],method=:FE)
        dep_compare_coefficients("correlated-gls",fit,["intrcpt","x"])
        ids = gls.column("row_id")
        table = (yi=y,x=x,row_id=ids)
        adapted = fit_meta_cov_formula(table,@formula(yi~x),dep_matrix("gls-V.csv");
            id=:row_id,method=:FE)
        direct = fit_meta_cov(y,dep_matrix("gls-V.csv");X=X,method=:FE)
        @test adapted.row_indices == collect(1:length(y))
        @test string.(adapted.row_ids) == string.(ids)
        @test adapted.design_columns[end] == "x"
        @test adapted.result.beta ≈ direct.beta atol=1e-12 rtol=0
        xm = Union{Missing,Float64}[x...]; xm[2] = missing
        ym = Union{Missing,Float64}[y...]
        missing_table = (yi=ym,x=xm,row_id=ids)
        Vm = dep_matrix("gls-V.csv"); Vm[2,:] .= NaN; Vm[:,2] .= NaN
        reduced = @test_logs (:warn,r"Missing or invalid rows omitted") fit_meta_cov_formula(
            missing_table,@formula(yi~x),Vm;id=:row_id,method=:FE)
        keep = [i for i in eachindex(y) if i != 2]
        direct_reduced = fit_meta_cov(y[keep],dep_matrix("gls-V.csv")[keep,keep];
            X=X[keep,:],method=:FE)
        @test reduced.row_indices == keep
        @test string.(reduced.row_ids) == string.(ids[keep])
        @test reduced.result.beta ≈ direct_reduced.beta atol=1e-12 rtol=0

        nested = dep_csv("nested-rows.csv")
        yn = Float64.(nested.column("yi"))
        xn = Float64.(nested.column("x"))
        study = string.(nested.column("study"))
        local_effect = string.(nested.column("effect_local"))
        lower_group = collect(zip(study,local_effect))
        Xn = hcat(ones(length(yn)),xn)
        nested_fit = fit_meta_nested(yn,dep_matrix("nested-V.csv"),
            [study,lower_group];group_names=["study","study/effect"],X=Xn,
            design_columns=["intrcpt","x"],method=:REML)
        dep_compare_coefficients("nested-reml",nested_fit,["intrcpt","x"])
        @test nested_fit.variance_components["study"] ≈ dep_expected("nested-reml","variance","study") rtol=1e-4 atol=1e-6
        @test nested_fit.variance_components["study/effect"] ≈ dep_expected("nested-reml","variance","nested-effect") rtol=1e-4 atol=1e-6
        @test nested_fit.component_kernels["study/effect"][1,2] == 0
        @test nested_fit.component_kernels["study/effect"][1,4] == 0

        berkey = dep_csv("berkey-rows.csv")
        study_b = string.(berkey.column("study"))
        outcome = String.(berkey.column("outcome"))
        fit_un = fit_meta_un(Float64.(berkey.column("yi")),dep_matrix("berkey-V.csv"),
            study_b,outcome;outcome_levels=["benefit","harm"],method=:REML)
        dep_compare_coefficients("berkey-un",fit_un,["outcomebenefit","outcomeharm"])
        expected_sigma = [dep_expected("berkey-un","variance","benefit") dep_expected("berkey-un","covariance","benefit-harm");
                         dep_expected("berkey-un","covariance","benefit-harm") dep_expected("berkey-un","variance","harm")]
        @test fit_un.outcome_covariance ≈ expected_sigma rtol=1e-4 atol=1e-6
        @test minimum(eigvals(Symmetric(fit_un.outcome_covariance))) >= -1e-10
    end
    println("VERIFY_DEPENDENT_REFERENCE_OK")
end

if selected("dependent-edges") || selected("all")
    @testset "dependent covariance hand cases and alignment" begin
        y = [0.2,1.1,0.7]
        X = ones(3,1)
        V = [0.5 0.1 0.0;0.1 0.8 0.12;0.0 0.12 0.6]
        fit = fit_meta_cov(y,V;X=X,method=:FE)
        ViX = V \ X
        beta = (X' * ViX) \ (X' * (V \ y))
        covariance = inv(X' * ViX)
        @test fit.beta ≈ beta atol=1e-12 rtol=0
        @test fit.covariance ≈ covariance atol=1e-12 rtol=0

        ym = [0.2,NaN,0.7,1.0]
        Xm = ones(4,1)
        Vm = [0.5 NaN 0.08 0.0;NaN NaN NaN NaN;0.08 NaN 0.7 0.1;0.0 NaN 0.1 0.9]
        masked = @test_logs (:warn,r"Missing or invalid rows omitted") fit_meta_cov(ym,Vm;X=Xm,method=:FE)
        keep = [1,3,4]
        Vk = Vm[keep,keep]; Xk = Xm[keep,:]; yk = ym[keep]
        covk = inv(Xk' * (Vk \ Xk))
        betak = covk * Xk' * (Vk \ yk)
        @test masked.row_indices == keep
        @test masked.beta ≈ betak atol=1e-12 rtol=0

        x = [-1.0,0.0,1.0,2.0]
        Xb = hcat(ones(4),x)
        yb = 0.4 .+ 0.2 .* x
        K = Matrix(Diagonal([1.0,2.0,1.0,3.0]))
        boundary = fit_meta_cov(yb,0.1 .* Matrix{Float64}(I,4,4);X=Xb,
            components=["heterogeneity"=>K],method=:REML)
        @test boundary.variance_components["heterogeneity"] ≈ 0 atol=1e-8
        @test boundary.beta ≈ [0.4,0.2] atol=1e-10

        @test_throws ArgumentError fit_meta_cov([0.1,0.2],[1.0 2.0;2.0 1.0];method=:FE)
        @test_throws ArgumentError fit_meta_cov([0.1,0.2],Matrix{Float64}(I,2,2);
            components=["invalid"=>[1.0 2.0;2.0 1.0]],method=:REML)
    end
    println("VERIFY_DEPENDENT_EDGES_OK")
end
