@echo off
julia -e "using Pkg; Pkg.activate(); include(\"src/chem.jl\")"
