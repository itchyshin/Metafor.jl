using Documenter, Metafor
repo = normpath(joinpath(@__DIR__, ".."))
generated = joinpath(@__DIR__, "src", "assets", "generated")
for (source, target) in [
    ("COMPATIBILITY.md", "references/COMPATIBILITY.md"),
    ("reference/v1/PROVENANCE.md", "references/bcg-PROVENANCE.md"),
    ("reference/dependent/v1/PROVENANCE.md", "references/dependent-PROVENANCE.md"),
    ("reference/phylogeny/v1/PROVENANCE.md", "references/phylogeny-PROVENANCE.md"),
    ("examples/bcg-comparison.html", "comparisons/bcg-comparison.html"),
    ("examples/dependent-comparison.html", "comparisons/dependent-comparison.html"),
    ("examples/phylogeny-comparison.html", "comparisons/phylogeny-comparison.html"),
]
    destination = joinpath(generated, target)
    mkpath(dirname(destination))
    cp(joinpath(repo, source), destination; force=true)
end
makedocs(
    sitename="Metafor.jl",
    modules=[Metafor],
    format=Documenter.HTML(assets=["assets/metafor.css"]),
    remotes=Dict("." => (Documenter.Remotes.GitHub("itchyshin", "Metafor.jl"), "main")),
pages=["Home"=>"index.md",
           "Tutorials"=>["Overview"=>"tutorials/index.md",
                         "BCG effect sizes"=>"tutorials/bcg-effects.md",
                         "Fixed and random effects"=>"tutorials/bcg-models.md",
                         "Meta-regression"=>"tutorials/bcg-moderator.md",
                         "Predictions"=>"tutorials/bcg-prediction.md",
                         "Forest plot data"=>"tutorials/bcg-forest.md",
                         "Correlated sampling errors"=>"tutorials/dependent-gls.md",
                         "Nested effects"=>"tutorials/dependent-nested.md",
                         "Two outcomes"=>"tutorials/dependent-bivariate.md",
                         "Supplied phylogenetic correlation"=>"tutorials/phylogeny.md",
                         "Differences from R metafor"=>"tutorials/differences.md"]],
)
println("DOCUMENTATION_BUILD_OK")
