using JuMP
#using teletype
#using Cbc
using Clp
using Gurobi
#using SparseArrays
using Plots
using LinearAlgebra
plotlyjs()
#using Distributions

include("MMM_Assignment1_data.jl")
include("MMM_Assignment1_model.jl")

m, cost ,installed, power, res, emission, batteryRes, batteryInflow, installedTransBetween, transmission = build_model_exercise34()
emission_max_con = add_CO_2_con(m, CO2_emissions_from_Ex1)
set_optimizer(m, Gurobi.Optimizer)
optimize!(m)

println("The installed capacities [MW] (Ex3): ", value.(installed))
println("The total cost (Ex3): ", value.(cost), " euro")
println("The CO2-emissions (Ex3) for Sweden is ", value.(emission[1]),
 " for Germany ", value.(emission[2]),
 " and for Denmark ", value.(emission[3]), " ton CO2")
println("Total CO2-emission (Ex3): ", sum(value.(emission)), " ton CO2")
println("Transmission capacity (Ex3) SE<->DE: ", value.(installedTransBetween[1,2]), " SE <-> DK: ", value.(installedTransBetween[1,3]), " DE <-> DK: ", value.(installedTransBetween[2,3]))

I = 1:6
power_values = zeros(length(CI), length(I), length(T))
for ci in CI, i in I, t in T
    power_values[ci,i,t+1] = value.(power[ci,i,t])
end

emission_values = zeros(length(CI))
bar(["SE", "DE", "DK"],[value(emission[ci]) for ci in CI], 
title = "Emissions exercise 3",
ylabel =  "CO_2 emissions in tons")

using Printf
countries = ["Sweden", "Germany", "Denmark"]
for ci in CI
    fig = (bar(["Wind", "PV", "Gas", "Hydro", "Battery", "Transmission"] ,[value(installed[ci, i]) for i in 1:6], 
    title = @sprintf("%s exercise 3", countries[ci]),
    ylabel = "Installed capacity [MW]"), legend = false)
    bar!(fig, countries, [value(installedTransBetween[ci, ci2]) for ci2 in CI])
    Plots.display(fig)
end

fig = plot(0:168,[power_values[2, i, 1:169] for i in I], 
    labels = ["Wind" "PV" "Gas" "Hydro" "Battery", "Transmission"], 
    title = "Energy produced in Germany (Ex3)",
    ylabel = "Power produced [MW]",
    xticks = 0:12:168)
