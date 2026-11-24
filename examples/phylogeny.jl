using Metafor
using DelimitedFiles
using LinearAlgebra
using Printf

root = normpath(joinpath(@__DIR__, ".."))
for case in ("v1", "v2-interior")
    base = joinpath(root, "reference", "phylogeny", case)
    obs, _ = readdlm(joinpath(base,"observations.csv"), ',', Any, '\n'; header=true)
    rawA, matrix_header = readdlm(joinpath(base,"species-correlation.csv"), ',', Any, '\n'; header=true)
    labels = String.(vec(matrix_header[2:end]))
    row_labels = String.(rawA[:,1])
    row_labels == labels || error("correlation matrix row and column labels must match")
    A = Float64.(rawA[:,2:end])
    yi = Float64.(obs[:,3]); vi = Float64.(obs[:,4]); species = String.(obs[:,2])
    fit = fit_phylo(yi,vi,species,A,labels)
    z = 1.959963984540054
    se = sqrt(fit.covariance[1,1])
    println("PHYLO|$case|beta=$(@sprintf("%.16g",fit.beta[1]))|se=$(@sprintf("%.16g",se))|tau2=$(@sprintf("%.16g",fit.tau2))|ci_lb=$(@sprintf("%.16g",fit.beta[1]-z*se))|ci_ub=$(@sprintf("%.16g",fit.beta[1]+z*se))")
end
println("PHYLOGENY_EXAMPLE_OK")
