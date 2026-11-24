using Metafor, Test, DelimitedFiles, StatsModels, LinearAlgebra, Statistics

requested = isempty(ARGS) ? "all" : ARGS[1]
selected(name) = requested == "all" || requested == name
root = normpath(joinpath(@__DIR__, ".."))

function read_bcg()
    raw, header = readdlm(joinpath(root,"reference/v1/bcg.csv"), ',', Any, '\n'; header=true)
    names = String.(vec(header))
    column(name) = [row[findfirst(==(name),names)] for row in eachrow(raw)]
    numeric(name) = Float64.(column(name))
    yi, vi = escalc_rr(numeric("tpos"),numeric("tneg"),numeric("cpos"),numeric("cneg"))
    yi,vi,numeric("ablat"),string.(column("author")),numeric("trial")
end

if selected("bcg-models")
    @testset "BCG reference models" begin
        yi,vi,latitude,_,_ = read_bcg()
        expected_yi = [-.8893113339202054,-1.5853886572014306,-1.3480731482996933,-1.4415511900213054,-.21754732221129558,-.786115585818864,-1.6208982235983918,.011952333523840508,-.4694176487381494,-1.3713448034727844,-.3393588283383906,.44591340057137874,-.017313948216879815]
        expected_vi = [.32558476500396133,.19458112139814385,.4153679653679654,.020010031902247573,.05121017216963086,.0069056184559087574,.22301724757231517,.0039615792978177295,.056434210463248966,.07302479361302891,.01241221397155972,.5325058452001528,.0714046596839863]
        @test isapprox(yi,expected_yi;atol=1e-12,rtol=1e-10)
        @test isapprox(vi,expected_vi;atol=1e-12,rtol=1e-10)
        fe = fit_meta(yi,vi;method=:FE)
        re = fit_meta(yi,vi)
        mod = fit_meta(yi,vi;X=hcat(ones(length(yi)),latitude))
        @test fe.beta[1] ≈ -.430285163654091 atol=2e-6
        @test sqrt(fe.covariance[1,1]) ≈ .04049875171086381 atol=2e-6
        @test fe.q ≈ 152.23300808237326 atol=2e-5
        @test fe.i2 ≈ 92.11734685456204 atol=2e-5
        @test re.beta[1] ≈ -.714532348365101 atol=2e-6
        @test sqrt(re.covariance[1,1]) ≈ .17978153178036144 atol=2e-6
        @test re.tau2 ≈ .31324332598089494 atol=2e-6
        @test re.q ≈ 152.23300808237326 atol=2e-5
        @test re.i2 ≈ 92.22138607496558 atol=2e-5
        @test mod.beta ≈ [.2514642943742843,-.029101660928014826] atol=2e-6
        @test sqrt.(diag(mod.covariance)) ≈ [.24910366638913276,.007195554757080915] atol=2e-6
        @test mod.tau2 ≈ .07635469470565989 atol=2e-6
        pred = predict(mod,hcat(ones(3),[0.0,30.0,60.0]))
        @test pred.estimate ≈ [.2514642943742843,-.6215855334661605,-1.4946353613066052] atol=2e-6
        @test pred.ci_lb ≈ [-.23676992016529663,-.8311591602064521,-1.950136501100149] atol=2e-6
        @test pred.ci_ub ≈ [.7396985089138652,-.412011906725869,-1.0391342215130615] atol=2e-6
        @test pred.pi_lb ≈ [-.4777037683695152,-1.2023045020762302,-2.20230385985072] atol=2e-6
        @test pred.pi_ub ≈ [.9806323571180838,-.04086656485609075,-.7869668627624906] atol=2e-6
    end
    println("VERIFY_BCG_MODELS_OK")
end

if selected("bcg-edges")
    @testset "BCG hand cases and diagnostics" begin
        z,vz = escalc_rr([0,0],[20,10],[3,0],[17,10])
        @test all(isfinite,(z[1],vz[1],z[2],vz[2]))
        r_y, r_v = escalc_rr([0,2],[10,8],[2,3],[8,7];to=:only0)
        @test r_y ≈ [-1.6094379124341001,-0.4054651081081642] atol=1e-12
        @test r_v ≈ [2.2181818181818183,0.6333333333333334] atol=1e-12
        r_y, r_v = escalc_rr([0,2],[10,8],[2,3],[8,7];to=:all)
        @test r_y ≈ [-1.6094379124341001,-0.336472236621213] atol=1e-12
        @test r_v ≈ [2.2181818181818183,0.5038961038961038] atol=1e-12
        r_y, r_v = escalc_rr([0,2],[10,8],[2,3],[8,7];to=:if0all)
        @test r_y ≈ [-1.6094379124341001,-0.336472236621213] atol=1e-12
        @test r_v ≈ [2.2181818181818183,0.5038961038961038] atol=1e-12
        r_y, r_v = escalc_rr([0,2],[10,8],[2,3],[8,7];to=:none)
        @test isnan(r_y[1]) && isnan(r_v[1])
        @test r_y[2] ≈ -0.4054651081081642 atol=1e-12
        @test r_v[2] ≈ 0.6333333333333334 atol=1e-12
        @test_throws ArgumentError escalc_rr([-1],[10],[2],[8])
        missing_y, missing_v = escalc_rr(Union{Missing,Int}[missing,0],[10,10],[2,2],[8,8])
        @test isnan(missing_y[1]) && isnan(missing_v[1])
        missing_if0all_y, missing_if0all_v = escalc_rr(Union{Missing,Int}[missing,2],[10,8],[2,3],[8,7];to=:if0all)
        @test isnan(missing_if0all_y[1]) && isnan(missing_if0all_v[1])
        @test isfinite(missing_if0all_y[2]) && isfinite(missing_if0all_v[2])
        missing_fit = @test_logs (:warn, r"Missing or invalid rows omitted") fit_meta(Union{Missing,Float64}[0.1,missing,0.3],[0.2,0.2,0.2];method=:FE)
        @test missing_fit.row_indices == [1,3]
        y = [0.1,NaN,0.3,0.5]; v = fill(0.2,4)
        fit = fit_meta(y,v;method=:FE)
        @test fit.row_indices == [1,3,4]
        @test fit.beta[1] ≈ mean([0.1,0.3,0.5])
        xfit = fit_meta([0.1,0.2,0.3],[.2,.2,.2];X=[1. 0.;1. NaN;1. 2.],method=:FE)
        @test xfit.row_indices == [1,3]
        @test xfit.beta ≈ [.1,.1] atol=1e-12
        @test fit_meta([-1.0,0.0,1.0],ones(3)).tau2 ≈ 0 atol=1e-10
        boundary = @test_logs (:warn, r"inferior local maximum") fit_meta([0.0,0.0,25.0],[0.01,0.01,100.0])
        @test boundary.tau2 ≈ 0 atol=1e-12
        @test boundary.beta[1] ≈ 0.001249938 atol=1e-8
        single = fit_meta([2.0],[0.4])
        @test single.tau2 == 0.0 && single.beta[1] ≈ 2.0
        @test single.h2 == 1.0 && single.i2 == 0.0
        hand = fit_meta([1.0,3.0],[1.0,3.0];method=:FE)
        @test hand.beta[1] ≈ 1.5
        @test hand.covariance[1,1] ≈ .75
        @test_throws ArgumentError fit_meta([NaN],[NaN])
        @test_throws ArgumentError fit_meta([-2.0,0.0,2.0],[0.2,0.0,0.2])
        @test_throws ArgumentError fit_meta([-1.0,1.0],[0.0,0.2];method=:FE)
    end
    println("VERIFY_BCG_EDGES_OK")
end

if selected("bcg-adapters")
    @testset "BCG table and forest adapters" begin
        yi,vi,latitude,authors,trials = read_bcg()
        lat = Vector{Union{Missing,Float64}}(latitude); lat[4] = missing
        table = (yi=yi,vi=vi,ablat=lat,author=authors,trial=Int.(trials))
        fitted = fit_meta_formula(table,@formula(yi ~ 1 + ablat);id=:trial)
        keep = .!ismissing.(lat)
        direct = fit_meta(yi[keep],vi[keep];X=hcat(ones(sum(keep)),Float64.(lat[keep])))
        @test fitted.design_columns == ["(Intercept)","ablat"]
        @test fitted.row_indices == findall(keep)
        @test fitted.row_ids == Any[Int(trials[i]) for i in findall(keep)]
        @test fitted.result.beta ≈ direct.beta atol=1e-12
        reversed = (yi=reverse(yi),vi=reverse(vi),ablat=reverse(lat),author=reverse(authors),trial=reverse(Int.(trials)))
        reversefit = fit_meta_formula(reversed,@formula(yi ~ 1 + ablat);id=:trial)
        @test reversefit.row_ids == reverse(fitted.row_ids)
        @test reversefit.result.beta ≈ fitted.result.beta atol=1e-12
        zero_variance_table = (yi=[0.1,0.2,0.3],vi=[0.2,0.0,0.3],ablat=[1.0,2.0,3.0])
        @test_throws ArgumentError fit_meta_formula(zero_variance_table,@formula(yi ~ ablat))
        @test_throws ArgumentError fit_meta_formula(zero_variance_table,@formula(yi ~ ablat);method=:FE)
        model = fit_meta(yi,vi)
        forest = forest_plot_data(yi,vi,authors,model)
        @test [row["row"] for row in forest["rows"]] == collect(1:13)
        @test [row["label"] for row in forest["rows"]] == authors
        @test [row["estimate"] for row in forest["rows"]] ≈ yi atol=1e-12
        pooled = predict(model)
        @test forest["summary"]["estimate"] ≈ pooled.estimate[1] atol=1e-12
        @test forest["summary"]["ci_lb"] ≈ pooled.ci_lb[1] atol=1e-12
        @test forest["summary"]["ci_ub"] ≈ pooled.ci_ub[1] atol=1e-12
        @test forest["summary"]["pi_lb"] ≈ pooled.pi_lb[1] atol=1e-12
        @test forest["summary"]["pi_ub"] ≈ pooled.pi_ub[1] atol=1e-12
    end
    println("VERIFY_BCG_ADAPTERS_OK")
end

if selected("phylogeny-model") || selected("all")
    @testset "synthetic phylogenetic boundary and interior" begin
        A = [1.0 0.6 0.2; 0.6 1.0 0.3; 0.2 0.3 1.0]
        labels = [:sp_a,:sp_b,:sp_c]
        species = [:sp_a,:sp_a,:sp_b,:sp_c,:sp_c]
        yi = [0.35,0.28,-0.10,0.42,0.31]
        vi = [0.10,0.12,0.08,0.11,0.09]
        fit = fit_phylo(yi,vi,species,A,labels)
        @test fit.beta[1] ≈ 0.232112815437948 atol=1e-7
        @test fit.covariance[1,1] ≈ 0.139979499454352^2 atol=1e-7
        @test fit.tau2 ≈ 0 atol=1e-7
        perm = [3,1,2]
        pfit = fit_phylo(yi,vi,species,A[perm,perm],labels[perm])
        @test pfit.beta ≈ fit.beta atol=1e-10
        @test pfit.tau2 ≈ fit.tau2 atol=1e-10
        @test_throws ArgumentError fit_phylo(yi,vi,species,A,[:sp_a,:sp_b,:unknown])
        base = joinpath(root,"reference","phylogeny","v2-interior")
        obs, _ = readdlm(joinpath(base,"observations.csv"), ',', Any, '\n'; header=true)
        rawA, matrix_header = readdlm(joinpath(base,"species-correlation.csv"), ',', Any, '\n'; header=true)
        interior_labels = String.(vec(matrix_header[2:end]))
        interior_A = Float64.(rawA[:,2:end])
        interior_species = String.(obs[:,2])
        interior = fit_phylo(Float64.(obs[:,3]),Float64.(obs[:,4]),interior_species,interior_A,interior_labels)
        expected, _ = readdlm(joinpath(base,"reference.csv"), ',', Float64, '\n'; header=true)
        @test interior.beta[1] ≈ expected[1,1] atol=1e-6
        @test sqrt(interior.covariance[1,1]) ≈ expected[1,2] atol=1e-6
        @test interior.tau2 ≈ expected[1,3] atol=1e-6
        z = 1.959963984540054
        @test interior.beta[1]-z*sqrt(interior.covariance[1,1]) ≈ expected[1,4] atol=1e-6
        @test interior.beta[1]+z*sqrt(interior.covariance[1,1]) ≈ expected[1,5] atol=1e-6
        @test interior.tau2 > 0.1
        perm = [3,1,2]
        permuted_axes = fit_phylo(Float64.(obs[:,3]),Float64.(obs[:,4]),interior_species,interior_A[perm,perm],interior_labels[perm])
        @test permuted_axes.beta ≈ interior.beta atol=1e-8
        @test permuted_axes.tau2 ≈ interior.tau2 atol=1e-7
        masked_y = Float64.(obs[:,3]); masked_y[2] = NaN
        masked = fit_phylo(masked_y,Float64.(obs[:,4]),interior_species,interior_A,interior_labels)
        @test masked.row_indices == [1,3,4,5]
        high_variance = fit_phylo([-1.0,-1.0,1.0,1.0],fill(0.1,4),["a","a","b","b"],
                                  [1.0 0.999;0.999 1.0],["a","b"])
        @test high_variance.tau2 ≈ 1950.00332547 rtol=1e-4 atol=0.1
        one_level = @test_logs (:warn, r"not identifiable") fit_phylo([1.0,2.0,3.0],fill(0.1,3),fill("only",3),[1.0;;],["only"])
        @test one_level.tau2 == 0.0
        @test one_level.beta[1] ≈ 2.0 atol=1e-12
        @test sqrt(one_level.covariance[1,1]) ≈ sqrt(0.1/3) atol=1e-12
    end
    println("VERIFY_PHYLOGENY_MODEL_OK")
end

include("dependent.jl")

requested in ("all","bcg-models","bcg-edges","bcg-adapters","phylogeny-model","dependent-model","dependent-edges") || error("unknown test group: $requested")
