using JuMP
#using teletype
#using Cbc
using Clp
using Plots
using LinearAlgebra
plotly()

include("MMM_Assignment1_data.jl")
include("MMM_Assignment1_model.jl")


m, cost,installed, power, res, emission = build_model_exercise1()
set_optimizer(m, Clp.Optimizer)
optimize!(m)

println("The installed capacities [MW] are: ", value.(installed))
println("The total cost is: ", value.(cost), " euro")
println("The CO2-emissions for Sweden is ", value.(emission[1]),
 " for Germany ", value.(emission[2]),
 " and for Denmark ", value.(emission[3]), " ton CO2")
println("Total CO2-emission: ", sum(value.(emission)), " ton CO2")

power_values = zeros(length(CI), length(I), length(T))
for ci in CI, i in I, t in T
    power_values[ci,i,t+1] = value.(power[ci,i,t])
end

emission_values = zeros(length(CI))

bar(["SE", "DE", "DK"],[value(emission[ci]) for ci in CI], 
title = "Emissions before CO_2 constraint",
ylabel =  "CO_2 emissions in tons")
using Printf
countries = ["Sweden", "Germany", "Denmark"]
for ci in CI
    Plots.display(bar(["Wind", "PV", "Gas", "Hydro"] ,[value(installed[ci, i]) for i in I], 
    title = @sprintf("Energy sources in %s before CO_2 constraint", countries[ci]),
    ylabel = "Installed capacity [MW]"))
end

plot(0:168,[power_values[2, i, 1:169] for i in I], 
    labels = ["Wind" "PV" "Gas" "Hydro"], 
    title = "Energy produced in Germany first week",
    ylabel = "Power produced [MW]",
    xticks = 0:12:168)

areaplot(0:168,[sum(power_values[2, i:4, 1:169], dims = 1) for i in I])
    





