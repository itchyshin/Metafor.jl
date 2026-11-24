using Documenter, Metafor
makedocs(
    sitename="Metafor.jl",
    modules=[Metafor],
    remotes=Dict("." => (Documenter.Remotes.GitHub("itchyshin", "Metafor.jl"), "main")),
    pages=["Home"=>"index.md", "BCG example"=>"bcg.md"],
)
println("DOCUMENTATION_BUILD_OK")
