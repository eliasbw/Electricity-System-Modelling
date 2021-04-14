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

emissionsFig = bar(["SE", "DE", "DK"],[value(emission[ci]) for ci in CI], legend = false,
title = "Emissions (Ex1)", size = (750,500), dpi = 2000, ytickfontsize = 12, xtickfontsize = 12, yguidefontsize = 14,
ylabel =  "CO_2 emissions in tons")
savefig(emissionsFig, "Ex1_emissions_fig.png")
yearlyProductionFig = bar(["SE", "DE", "DK"], [sum(power_values[ci,:,:]) for ci in CI], title = "Yearly production by country (Ex1)",
    ylabel = "Power produced [GW]", legend = false, size = (750,500), dpi = 2000, ytickfontsize = 12, xtickfontsize = 12, yguidefontsize = 14)
savefig(yearlyProductionFig, "Ex1_yearly_production_fig.png")
using Printf
countries = ["Sweden", "Germany", "Denmark"]
countryTag = [" SE", " DE", " DK"]
capacityFig = bar(size = (1250,500), dpi = 2000,left_margin = 15mm, title = "Energy sources per country (Ex1)")
for ci in CI
    bar!(capacityFig,["Wind"*countryTag[ci], "PV"*countryTag[ci], "Gas"*countryTag[ci], "Hydro"*countryTag[ci]] ,[value(installed[ci, i]) for i in I], 
    ylabel = "Installed capacity [MW]", labels = countryTag[ci], legendfontsize = 25, size = (1250,500),
    ytickfontsize = 12, xtickfontsize = 8, yguidefontsize = 11)
    
end
capacityFig
savefig(capacityFig, "Ex1_capacity_fig.png")


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



