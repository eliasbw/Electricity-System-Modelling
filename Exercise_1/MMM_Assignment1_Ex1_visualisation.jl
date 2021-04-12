using JuMP
using Clp
using Gurobi
using Plots
using Plots.PlotMeasures
using LinearAlgebra
plotlyjs()

include("MMM_Assignment1_data.jl")
include("MMM_Assignment1_model.jl")


m, cost, installed, power, res, emission = build_model_exercise1()
set_optimizer(m, Gurobi.Optimizer)
optimize!(m)

println("The installed capacities [MW] (Ex1): ", value.(installed))
println("The total cost (Ex1): ", value.(cost), " euro")
println("The CO2-emissions (Ex1) for Sweden is ", value.(emission[1]),
 " for Germany ", value.(emission[2]),
 " and for Denmark ", value.(emission[3]), " ton CO2")
println("Total CO2-emission (Ex1): ", sum(value.(emission)), " ton CO2")
CO2_emissions_from_Ex1 = sum(value.(emission))


power_values = zeros(length(CI), length(I), length(T))
for ci in CI, i in I, t in T
    power_values[ci,i,t+1] = value.(power[ci,i,t])
end

emission_values = zeros(length(CI))

bar(["SE", "DE", "DK"],[value(emission[ci]) for ci in CI], 
title = "Emissions exercise 1",
ylabel =  "CO_2 emissions in tons")
yearlyProductionFig = bar(["SE", "DE", "DK"], [sum(power_values[ci,:,:]) for ci in CI], title = "Yearly production by country",
    ylabel = "Power produced [GW]", legend = false, size = (750,500), dpi = 2000, ytickfontsize = 12, xtickfontsize = 12, yguidefontsize = 14)
savefig(yearlyProductionFig, "Ex1_yearly_production_fig.png")
using Printf
countries = ["Sweden", "Germany", "Denmark"]

for ci in CI
    capacityFig = bar(["Wind", "PV", "Gas", "Hydro"] ,[value(installed[ci, i]) for i in I], 
    title = @sprintf("Energy sources in %s (Ex1)", countries[ci]),
    ylabel = "Installed capacity [MW]", legend = false,
    left_margin = 0mm, size = (750,500), dpi = 2000, ytickfontsize = 12, xtickfontsize = 12, yguidefontsize = 14)
    savefig(capacityFig, @sprintf("Ex1_capacity_fig_%S.png", countries[ci]))
end

plot(0:168,[power_values[2, i, 1:169] for i in I], 
    labels = ["Wind" "PV" "Gas" "Hydro"], 
    title = "Energy produced in Germany during first week (Ex1)",
    ylabel = "Power produced [MW]",
    xticks = 0:12:168,
    left_margin = -25mm,
    legend =:right)

#Courtesy of https://discourse.julialang.org/t/how-to-plot-a-simple-stacked-area-chart/21351/2
@userplot StackedArea
@recipe function f(pc::StackedArea)
    x, y = pc.args
    n = length(x)
    y = cumsum(y, dims=2)
    seriestype := :shape

    # create a filled polygon for each item
    for c=1:size(y,2)
        sx = vcat(x, reverse(x))
        sy = vcat(y[:,c], c==1 ? zeros(n) : reverse(y[:,c-1]))
        @series (sx, sy)
    end
end
fig = stackedarea(0:168, [power_values[2, i, t] for t in 1:169, i in I], 
            labels = ["Wind" "PV" "Gas" "Hydro"],
            #left_margin = -25mm,
            title = "Energy produced in Germany during first week (Ex1)",
            ylabel = "Power produced [MW]",
            xlabel = "Time [h]",
            legend = :bottom,
            legendfontsize = 16,
            size = (1000,500),
            dpi = 1200,
            xtickfontsize = 11,
            ytickfontsize = 11,
            xticks = 0:12:168,
            xguidefontsize = 14,
            yguidefontsize  = 14)

savefig(fig, "Ex1_Germany_production_week1.png")



