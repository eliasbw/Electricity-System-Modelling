# Read the data from the tables
#Pkg.add("Distributions")
#using Distributions

using CSV
using DataFrames

#CSV.read("The path where your CSV file is stored\\File Name.csv")
T_end = 167
I = 1:4 #energies wind,pv,gas and hydro
J = 1:6 #index of the energy properties
T = 1:T_end #time points in the CSV file
CI = 1:3 #country index

# Time, wind, PV
SE_data=CSV.read("TimeSeries.csv", DataFrame, select=[1,4,5])
DE_data=CSV.read("TimeSeries.csv", DataFrame, select=[1,2,3])
DK_data=CSV.read("TimeSeries.csv", DataFrame, select=[1,6,7])

load_SE = CSV.read("TimeSeries.csv", DataFrame, select=[10])
load_DE = CSV.read("TimeSeries.csv", DataFrame, select=[8])
load_DK = CSV.read("TimeSeries.csv", DataFrame, select=[9])

load_all = [load_SE[:,1];
            load_DE[:,1];
            load_DK[:,1]]

countrydata = zeros(8760,5,3)
countrydata[:,1:3,1].=SE_data
countrydata[:,1:3,2].=DE_data
countrydata[:,1:3,3].=DK_data

#Time and hydro inflow
inflow = CSV.read("TimeSeries.csv", DataFrame, select=[1,11])


max_capacity_SE = [280 75 Inf 14 Inf Inf Inf] #wind, pv, gas, hydro, batteries, transmission, nuclear
max_capacity_DK = [90 60 Inf 0 Inf Inf Inf]
max_capacity_DE = [180 460 Inf 0 Inf Inf Inf]

max_capacity_all = [max_capacity_SE;
                    max_capacity_DE;
                    max_capacity_DK]

energy_systems = [1100 0.1 0 25 1 0; #Wind
                  600 0.1 0 25 1 0;   #pv
                  550 2 22 30 0.4 0.202; #gas
                  0 0.1 0 80 1 0;              #hydro
                  150 0.1 0 1 0 0.9;  #batteries
                  2500 0 0 50 0.98 0; #transmission
                  7700 4 3.2 50 0.4 0] #nuclear
