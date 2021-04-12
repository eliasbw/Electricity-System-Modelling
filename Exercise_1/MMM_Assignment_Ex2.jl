using JuMP
#using teletype
#using Cbc
#using Clp
using Gurobi
#using SparseArrays
using Plots
using LinearAlgebra
plotly()
#using Distributions

include("MMM_Assignment1_data.jl")
include("MMM_Assignment1_model.jl")


m, cost ,installed, power, res, emission = build_model_exercise1()
emission_max_con = add_CO_2_con(m, CO2_emissions_from_Ex1)
set_optimizer(m, Gurobi.Optimizer)
optimize!(m)

#The model is not feasible with a CO_2 limit.

m, cost ,installed, power, res, emission, batteryRes, batteryInflow = build_model_exercise2();
emission_max_con = add_CO_2_con(m, CO2_emissions_from_Ex1)
set_optimizer(m, Gurobi.Optimizer)
optimize!(m)

println("The installed capacities [MW] (Ex2): ", value.(installed))
println("The total cost (Ex2): ", value.(cost), " euro")
println("The CO2-emissions (Ex2) ", value.(emission[1]),
 " for Germany ", value.(emission[2]),
 " and for Denmark ", value.(emission[3]), " ton CO2")
println("Total CO2-emission (Ex2): ", sum(value.(emission)), " ton CO2")
I = 1:5
power_values = zeros(length(CI), length(I), length(T))
for ci in CI, i in I, t in T
    power_values[ci,i,t+1] = value.(power[ci,i,t])
end

emission_values = zeros(length(CI))
bar(["SE", "DE", "DK"],[value(emission[ci]) for ci in CI], 
title = "Emissions (Ex2)",
ylabel =  "CO_2 emissions in tons")

using Printf
countries = ["Sweden", "Germany", "Denmark"]
for ci in CI
    Plots.display(bar(["Wind", "PV", "Gas", "Hydro", "Battery"] ,[value(installed[ci, i]) for i in I], 
    title = @sprintf("Energy sources in %s (Ex2)", countries[ci]),
    ylabel = "Installed capacity [MW]"), legend = false)
end

fig = plot(0:168,[power_values[2, i, 1:169] for i in I], 
    labels = ["Wind" "PV" "Gas" "Hydro" "Battery"], 
    title = "Energy produced in Germany (Ex2)",
    ylabel = "Power produced [MW]",
    xticks = 0:12:168)
