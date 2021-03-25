using CSV
using DataFrames
#Pkg.add("DataFrames")
#Pkg.add("CSV")

#CSV.read("The path where your CSV file is stored\\File Name.csv")
T_end = 8759
I = 1:4 #energies wind,pv,gas and hydro (+ later nuclear)
#J = 1:6 #index of the energy properties
T = 0:T_end #time points in the CSV file
CI = 1:3 #country index

#SE, DE, DK

# wind, PV, gas, hydro, nuclear
SE_data=CSV.read("TimeSeries.csv", DataFrame, select=[4,5])
DE_data=CSV.read("TimeSeries.csv", DataFrame, select=[2,3])
DK_data=CSV.read("TimeSeries.csv", DataFrame, select=[6,7])

hourly_load_factor = ones(8760,5,3)
hourly_load_factor[:,1:2,1].=SE_data #[dimensionless]
hourly_load_factor[:,1:2,2].=DE_data
hourly_load_factor[:,1:2,3].=DK_data

load_SE = CSV.read("TimeSeries.csv", DataFrame, select=[10])
load_DE = CSV.read("TimeSeries.csv", DataFrame, select=[8])
load_DK = CSV.read("TimeSeries.csv", DataFrame, select=[9])

load_all = zeros(8760,3)
load_all[:,1].= load_SE[:,1] #MWh
load_all[:,2].= load_DE[:,1]
load_all[:,3].= load_DK[:,1]

#hydro inflow
inflow = CSV.read("TimeSeries.csv", DataFrame, select=[11])

max_capacity_SE = [280 75 Inf 14 Inf Inf Inf] #wind, pv, gas, hydro, batteries, transmission, nuclear in [GW]
max_capacity_DK = [90 60 Inf 0 Inf Inf Inf]
max_capacity_DE = [180 460 Inf 0 Inf Inf Inf]

max_capacity_all = [max_capacity_SE;
                    max_capacity_DE;
                    max_capacity_DK]

# Table from the assignment
energy_systems = [1100 0.1 0 25 1 0; #Wind
                  600 0.1 0 25 1 0;   #pv
                  550 2 22 30 0.4 0.202; #gas
                  0 0.1 0 80 1 0;              #hydro
                  150 0.1 0 10 0.9 0;  #batteries
                  2500 0 0 50 0.98 0; #transmission
                  7700 4 3.2 50 0.4 0] #nuclear

                  
investment_costs = energy_systems[:,1] #Euro/kW
variable_costs = energy_systems[:,2] #Euro/MWh_elec
fuel_costs = energy_systems[:,3] #Euro/MWh_fuel
lifetimes = energy_systems[:,4] #Years
efficiencies = energy_systems[:,5] #-
emission_factor = energy_systems[:,6] #ton CO_2/MWh_fuel

r = 0.05
annualized_costs = investment_costs.*r./(1 .- (1+r).^(-lifetimes))