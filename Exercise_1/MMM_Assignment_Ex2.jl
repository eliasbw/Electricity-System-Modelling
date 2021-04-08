using JuMPi
#using teletype
#using Cbc
using Clp
#using Gurobi
#using SparseArrays
using Plots
using LinearAlgebra
plotly()
#using Distributions

include("MMM_Assignment1_data.jl")
include("MMM_Assignment1_model.jl")


m, cost ,installed, power, res, emission = build_model_exercise1()
emission_max_con = add_CO_2_con(m, 6.87002224181645e8)
set_optimizer(m, Clp.Optimizer)
optimize!(m)

#The model is not feasible with a CO_2 limit.

m, cost ,installed, power, res, emission, batteryRes, batteryInflow = build_model_exercise2(6.87002224181645e8)
emission_max_con = add_CO_2_con(m, 6.87002224181645e8)
set_optimizer(m, Clp.Optimizer)
optimize!(m)

println("The installed capacities [MW] with CO_2 constraint are: ", value.(installed))
println("The total cost with CO_2 constraint is: ", value.(cost), " euro")
println("The CO2-emissions with CO_2 constraint for Sweden is ", value.(emission[1]),
 " for Germany ", value.(emission[2]),
 " and for Denmark ", value.(emission[3]), " ton CO2")
println("Total CO2-emission with CO_2 constraint: ", sum(value.(emission)), " ton CO2")
I = 1:5
power_values = zeros(length(CI), length(I), length(T))
for ci in CI, i in I, t in T
    power_values[ci,i,t+1] = value.(power[ci,i,t])
end

emission_values = zeros(length(CI))
bar(["SE", "DE", "DK"],[value(emission[ci]) for ci in CI], 
title = "Emissions after CO_2 constraint",
ylabel =  "CO_2 emissions in tons")

using Printf
countries = ["Sweden", "Germany", "Denmark"]
for ci in CI
    Plots.display(bar(["Wind", "PV", "Gas", "Hydro", "Battery"] ,[value(installed[ci, i]) for i in I], 
    title = @sprintf("Energy sources in %s after CO_2 constraint", countries[ci]),
    ylabel = "Installed capacity [MW]"))
end

fig = plot(0:168,[power_values[2, i, 1:169] for i in I], 
    labels = ["Wind" "PV" "Gas" "Hydro" "Battery"], 
    title = "Energy produced in Germany first week after first constraint",
    ylabel = "Power produced [MW]",
    xticks = 0:12:168)
