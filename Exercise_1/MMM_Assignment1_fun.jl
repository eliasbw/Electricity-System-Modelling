using JuMP
#using teletype
#using Cbc
using Clp
#using Gurobi
#using SparseArrays
#using Plots
#using Distributions

include("MMM_Assignment1_data.jl")
include("MMM_Assignment1_model.jl")


m, installed, power, res = build_model()
set_optimizer(m, Clp.Optimizer)
optimize!(m)

println(value.(installed))
