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


m, cost ,installed, power, res, emission = build_model_exercise1()
emission_max_con = add_CO_2_con(m, 6.87002224181645e8)
set_optimizer(m, Clp.Optimizer)
optimize!(m)

println(value.(installed))


