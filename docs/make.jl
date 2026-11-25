using Documenter, Metafor
repo = normpath(joinpath(@__DIR__, ".."))
generated = joinpath(@__DIR__, "src", "assets", "generated")
for (source, target) in [
    ("COMPATIBILITY.md", "references/COMPATIBILITY.md"),
    ("reference/v1/PROVENANCE.md", "references/bcg-PROVENANCE.md"),
    ("reference/dependent/v1/PROVENANCE.md", "references/dependent-PROVENANCE.md"),
    ("reference/phylogeny/v1/PROVENANCE.md", "references/phylogeny-PROVENANCE.md"),
    ("examples/bcg-forest.svg", "bcg-forest.svg"),
    ("examples/pairwise/bcg-comparison.html", "comparisons/bcg-comparison.html"),
    ("examples/pairwise/dependent-comparison.html", "comparisons/dependent-comparison.html"),
    ("examples/pairwise/phylogeny-comparison.html", "comparisons/phylogeny-comparison.html"),
    ("examples/pairwise/effect-size-comparison.html", "comparisons/effect-size-comparison.html"),
    ("examples/pairwise/table-adapter-comparison.html", "comparisons/table-adapter-comparison.html"),
]
    destination = joinpath(generated, target)
    input = joinpath(repo, source)
    if !isfile(input)
        if startswith(source, "examples/pairwise/") && get(ENV, "METAFOR_PREVIEW", "") == "1"
            @warn "Comparison input not present; skipping only because METAFOR_PREVIEW=1" source
            continue
        end
        error("Required documentation input is missing: $input")
    end
    mkpath(dirname(destination))
    cp(input, destination; force=true)
    if target == "references/COMPATIBILITY.md"
        content = read(destination, String)
        content = replace(content,
            "[COVERAGE.md](COVERAGE.md)" => "[COVERAGE.md](https://github.com/itchyshin/Metafor.jl/blob/main/COVERAGE.md)",
            "[reference provenance](reference/v1/PROVENANCE.md)" => "[reference provenance](bcg-PROVENANCE.md)")
        write(destination, content)
    elseif target in ("references/dependent-PROVENANCE.md", "references/phylogeny-PROVENANCE.md")
        content = read(destination, String)
        write(destination, replace(content, "../../v1/PROVENANCE.md" => "bcg-PROVENANCE.md"))
    end
end
makedocs(
    sitename="Metafor.jl",
    modules=[Metafor],
    format=Documenter.HTML(assets=["assets/metafor.css"]),
    remotes=Dict(".." => (Documenter.Remotes.GitHub("itchyshin", "Metafor.jl"), "main")),
pages=["Home"=>"index.md",
           "Getting started"=>"getting-started.md",
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
                         "Odds ratios"=>"tutorials/odds-ratio.md",
                         "Risk differences"=>"tutorials/risk-difference.md",
                         "Choosing an effect scale"=>"tutorials/effect-scale.md",
                         "Zero-cell policies"=>"tutorials/zero-cell-policies.md",
                         "Missing rows"=>"tutorials/missing-rows.md",
                         "Pooling log odds ratios"=>"tutorials/odds-ratio-models.md",
                         "Pooling risk differences"=>"tutorials/risk-difference-models.md",
                         "Phylogenetic boundary"=>"tutorials/phylo-boundary.md",
                         "Phylogenetic interior fit"=>"tutorials/phylo-interior.md",
                         "Phylogenetic labels"=>"tutorials/phylo-labels.md",
                         "Table and formula adapter"=>"tutorials/table-adapter.md"],
           "Reference"=>["Overview"=>"reference/index.md",
                         "Effect sizes"=>"reference/effect-sizes.md",
                         "Univariate models"=>"reference/univariate.md",
                         "Prediction and forest data"=>"reference/prediction.md",
                         "Dependent effects"=>"reference/dependent.md",
                         "Phylogeny"=>"reference/phylogeny.md"],
           "Compare"=>"compare.md",
           "Articles"=>["Differences from R metafor"=>"tutorials/differences.md",
                        "News"=>"news.md",
                        "Citation"=>"citation.md"],
],
)
# This project publishes one unversioned site directly, without deploydocs' version
# metadata. Remove only Documenter's optional selector script tags; search and theme
# scripts remain intact.
build = joinpath(@__DIR__, "build")
for (directory, _, files) in walkdir(build)
    for file in files
        endswith(file, ".html") || continue
        path = joinpath(directory, file)
        html = read(path, String)
        html = replace(html, r"""<script src="(?:\.\./)*siteinfo\.js"></script>""" => "")
        html = replace(html, r"""<script src="(?:\.\./)*versions\.js"></script>""" => "")
        write(path, html)
    end
end
println("DOCUMENTATION_BUILD_OK")
