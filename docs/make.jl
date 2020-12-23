using Documenter
using BaseExtensions

DocMeta.setdocmeta!(BaseExtensions, :DocTestSetup, :(using BaseExtensions); recursive=true)

makedocs(;
    modules=[BaseExtensions],
    authors="Jishnu Bhattacharya",
    repo="https://github.com/jishnub/BaseExtensions.jl/blob/{commit}{path}#L{line}",
    sitename="BaseExtensions.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://jishnub.github.io/BaseExtensions.jl",
        assets=String[],
    ),
    pages=[
        "API" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/jishnub/BaseExtensions.jl",
)
