using JuMP
using Clp
using Gurobi
using Plots
using LinearAlgebra
plotlyjs()


include("MMM_Assignment1_data.jl")
include("MMM_Assignment1_model.jl")

m, cost ,installed, power, res, emission, batteryRes, batteryInflow, installedTransBetween, transmission = build_model_exercise34(I = 1:7)
emission_max_con = add_CO_2_con(m, CO2_emissions_from_Ex1)
set_optimizer(m, Gurobi.Optimizer)
optimize!(m)

println("The installed capacities [MW] (Ex4): ", value.(installed))
println("The total cost (Ex4): ", value.(cost), " euro")
println("The CO2-emissions (Ex4) for Sweden is ", value.(emission[1]),
 " for Germany ", value.(emission[2]),
 " and for Denmark ", value.(emission[3]), " ton CO2")
println("Total CO2-emission (Ex4): ", sum(value.(emission)), " ton CO2")
println("Transmission capacity (Ex4) SE<->DE: ", value.(installedTransBetween[1,2]), " SE <-> DK: ", value.(installedTransBetween[1,3]), " DE <-> DK: ", value.(installedTransBetween[2,3]))

I = 1:7
power_values = zeros(length(CI), length(I), length(T))
for ci in CI, i in I, t in T
    power_values[ci,i,t+1] = value.(power[ci,i,t])
end


emissionsFig = bar(["SE", "DE", "DK"],[value(emission[ci]) for ci in CI], legend = false,
title = "Emissions (Ex4)", size = (750,500), dpi = 2000, ytickfontsize = 12, xtickfontsize = 12, yguidefontsize = 14,
ylabel =  "CO_2 emissions in tons")
savefig(emissionsFig, "Ex4_emissions_fig.png")


yearlyProductionFig = bar(["SE", "DE", "DK"], [sum(power_values[ci,:,:]) for ci in CI], title = "Yearly production by country (Ex4)",
    ylabel = "Power produced [GW]", legend = false, size = (750,500), dpi = 2000, ytickfontsize = 12, xtickfontsize = 12, yguidefontsize = 14)
savefig(yearlyProductionFig, "Ex4_yearly_production_fig.png")


using Printf
countries = ["Sweden", "Germany", "Denmark"]
countryTag = [" SE", " DE", " DK"]
capacityFig = bar(dpi = 2000,left_margin = 15mm, title = "Energy sources per country (Ex4)", legendfontsize = 25, size = (1250,500),
ytickfontsize = 12, xtickfontsize = 8, yguidefontsize = 1, xrotation = 90, bottom_margin = -20mm)
for ci in CI
    bar!(capacityFig,["Wind", "PV", "Gas", "Hydro", "Batteries", "Transmission", "Nuclear"].*countryTag[ci] ,[value(installed[ci, i]) for i in I], 
    ylabel = "Installed capacity [MW]", labels = countryTag[ci])
    print(["Wind", "PV", "Gas", "Hydro", "Batteries", "Transmission", "Nuclear"].*countryTag[ci])
end
capacityFig
savefig(capacityFig, "Ex4_capacity_fig.png")

batteryResValues = zeros(size(batteryRes))
for ci in CI, t in T
    batteryResValues[ci, t+1] = value(batteryRes[ci,t])
end

fig = plot()
fig = stackedarea!(0:168, [power_values[2, i, t] for t in 1:169, i in I], alpha = 1,
            labels = ["Wind" "PV" "Gas" "Hydro" "Batteries" "Transmission" "Nuclear"],
            #left_margin = -25mm,
            title = "Energy produced in Germany during first week (Ex4)",
            ylabel = "Power produced [MW]",
            xlabel = "Time [h]",
            legend = (0.675,0.93),
            legendfontsize = 7,
            size = (1000,500),
            dpi = 1200,
            xtickfontsize = 11,
            ytickfontsize = 11,
            xticks = 0:12:168,
            xguidefontsize = 14,
            yguidefontsize  = 14)
fig = plot!(0:168, mean(load_all[1:169,2])*ones(169), linewidth = 3, color = :red, label = "Mean load")
fig = plot!(0:168, load_all[1:169,2], linewidth = 3, color = :orange, label = "Load")

fig = plot!(0:168, batteryResValues[2,1:169].*0.1, color = :blue, label = "Battery reservoir * 0.1", linewidth = 3)
savefig(fig, "Ex4_Germany_production_week1.png")