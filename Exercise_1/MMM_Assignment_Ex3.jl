using JuMP
#using teletype
#using Cbc
using Clp
using Gurobi
#using SparseArrays
using Plots
using LinearAlgebra
plotly()
#using Distributions

include("MMM_Assignment1_data.jl")
include("MMM_Assignment1_model.jl")

m, cost ,installed, power, res, emission, batteryRes, batteryInflow, installedTransBetween, transmission = build_model_exercise3(6.87002224181645e8)
emission_max_con = add_CO_2_con(m, 6.87002224181645e8)
set_optimizer(m, Clp.Optimizer)
optimize!(m)

println("The installed capacities [MW] with CO_2 constraint, batteries and transmission are: ", value.(installed))
println("The total cost with CO_2 constraint, batteries and transmission is: ", value.(cost), " euro")
println("The CO2-emissions with CO_2 constraint, batteries and transmission for Sweden is ", value.(emission[1]),
 " for Germany ", value.(emission[2]),
 " and for Denmark ", value.(emission[3]), " ton CO2")
println("Total CO2-emission with CO_2 constraint, batteries and transmission: ", sum(value.(emission)), " ton CO2")
println("Transmission capacity SE<->DE: ", value.(transmission[1,2]), " SE <-> DK: ", value.(transmission[1,3]), " DE <-> DK: ", value.(transmission[2,3]))

I = 1:6
power_values = zeros(length(CI), length(I), length(T))
for ci in CI, i in I, t in T
    power_values[ci,i,t+1] = value.(power[ci,i,t])
end

emission_values = zeros(length(CI))
bar(["SE", "DE", "DK"],[value(emission[ci]) for ci in CI], 
title = "Emissions after CO_2 constraint, batteries & transmission",
ylabel =  "CO_2 emissions in tons")

using Printf
countries = ["Sweden", "Germany", "Denmark"]
for ci in CI
    fig = (bar(["Wind", "PV", "Gas", "Hydro", "Battery", "Transmission"] ,[value(installed[ci, i]) for i in 1:6], 
    title = @sprintf("%s with CO_2 constraint, batteries & transmission", countries[ci]),
    ylabel = "Installed capacity [MW]"))
    bar!(fig, countries, [value(installedTransBetween[ci, ci2]) for ci2 in CI])
    Plots.display(fig)
end

fig = plot(0:168,[power_values[2, i, 1:169] for i in I], 
    labels = ["Wind" "PV" "Gas" "Hydro" "Battery", "Transmission"], 
    title = "Energy produced in Germany first week with CO_2 constraint, batteries and transmission",
    ylabel = "Power produced [MW]",
    xticks = 0:12:168)
