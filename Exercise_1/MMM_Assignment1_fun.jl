using JuMP
using teletype
using Cbc
using Gurobi
#using SparseArrays
#using Plots
#using Distributions

include("MMM_Assignment1_model.jl")
include("MMM_Assignment1_data.jl")

m, x = build_model()
set_optimizer(m, Gurobi.Optimizer)
optimize!(m)

println(value(x))



#m, x, z, u = build_model3()
#set_optimizer(m, Gurobi.Optimizer)
#optimize!(m)
