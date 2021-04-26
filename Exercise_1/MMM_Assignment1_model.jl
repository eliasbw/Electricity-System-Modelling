using JuMP

include("MMM_Assignment1_data.jl")

function build_model_exercise1()
  I = 1:4
  m = Model()

  @variable(m, installed[CI,I] >= 0) #Installed power in country ci of energy type i in MW.
  @variable(m, power[CI,I, T] >= 0) #Power output in country ci from energy source i at time t in MW.
  @variable(m, res[0:(T_end+1)] >= 0) #Size of water reservoir in Sweden at time t, in MW.
  @variable(m, emission[CI] >= 0)

  cost = @objective(m,Min, 
    sum([installed[country,i]*1000*annualized_costs[i] for country in CI, i in I])
    + sum([power[country,i,t]*variable_costs[i] for country in CI,i in I, t in T])
      # MW * 1h * Euro/MWh  =?= Euro
    + sum([power[country,i,t]*fuel_costs[i]/efficiencies[i] for country in CI, i in I, t in T]))
      # MW * 1h * Euro/Mwh =?= Euro

  # The installed power can't be higher than the maximum capacity
  #capacity_con = @constraint(m,[i in I, ci in CI], installed[ci,i] <= 1000*max_capacity_all[ci,i])
  for ci in CI, i in I
    set_upper_bound(installed[ci,i], 1000*max_capacity_all[ci,i])
  end
  # We need at least the power output required for each hour
  load_con = @constraint(m, [ci in CI, t in T], sum(power[ci,i,t] for i in I) >= load_all[t+1, ci])

  # The output power must be lower than the installed power * the load factor
  power_con = @constraint(m, [ci in CI, i in I, t in T], power[ci, i, t] <= installed[ci,i]*hourly_load_factor[t+1,i,ci])

  hydro_con = @constraint(m, [t in T], -power[1,4,t] + inflow[t+1,1] == res[t+1] - res[t] )
  hydro_start_stop_con = @constraint(m, res[0] == res[T_end+1])
  hydro_max_con = @constraint(m, [t in T], res[t] <= 33*10^6)
    
  #Swedish hydro can produce 14 000 Mw at most, given enough water in reservoir.
  hydro_installed = @constraint(m, installed[1,4] == 14000)

  #Ensures the variable emission is equal to the CO_2 emissions from Gas in each country
  emission_value_con = @constraint(m, [ci in CI], emission[ci] == sum(power[ci,3,:])/efficiencies[3]*emission_factor[3])

  return m, cost, installed, power, res, emission 
end

function add_CO_2_con(model, CO_2_Ex1)
   emission_max_con = @constraint(model, sum(emission) <= 0.1*CO_2_Ex1)
   return emission_max_con
end

function build_model_exercise2()
  I = 1:5
  m = Model()
  @variable(m, installed[CI,I] >= 0) #Installed power in country ci of energy type i in MW.
  @variable(m, power[CI,I,T] >= 0) #Power output in country ci from energy source i at time t in MW.
  @variable(m, res[0:(T_end+1)] >= 0) #Size of water reservoir in Sweden at time t, in MW.
  @variable(m, batteryRes[CI, 0:(T_end+1)] >= 0) #Energy stored in batteries at time t in country ci, in MWh.
  @variable(m, emission[CI] >= 0)
  @variable(m, batteryInflow[CI,T] >= 0)

  cost = @objective(m,Min, 
    sum([installed[country,i]*1000*annualized_costs[i] for country in CI, i in I])
    + sum([power[country,i,t]*variable_costs[i] for country in CI,i in 1:4, t in T]) #Variable cost for wind, pv, gas, hydro
      # MW * 1h * Euro/MWh  =?= Euro
    + sum([batteryInflow[country,t]*variable_costs[5] for country in CI, t in T]) #Count variable cost for battery when charging.
    + sum([power[country,i,t]*fuel_costs[i]/efficiencies[i] for country in CI, i in I, t in T]))
      # MW * 1h * Euro/Mwh =?= Euro

  # The installed power can't be higher than the maximum capacity
  #capacity_con = @constraint(m,[i in I, ci in CI], installed[ci,i] <= 1000*max_capacity_all[ci,i])
  for ci in CI, i in I
    set_upper_bound(installed[ci,i], 1000*max_capacity_all[ci,i])
  end

  # We need at least the power output required for each hour
  load_con = @constraint(m, [ci in CI, t in T], sum(power[ci,i,t] for i in I) - batteryInflow[ci,t] >= load_all[t+1, ci])

  # The output power must be lower than the installed power * the load factor
  power_con = @constraint(m, [ci in CI, i in I, t in T], power[ci, i, t] <= installed[ci,i]*hourly_load_factor[t+1,i,ci])

  hydro_con = @constraint(m, [t in T], -power[1,4,t] + inflow[t+1,1] == res[t+1] - res[t] )
  hydro_start_stop_con = @constraint(m, res[0] == res[T_end+1])
  hydro_max_con = @constraint(m, [t in T], res[t] <= 33*10^6)
  
  #Swedish hydro can produce 14 000 Mw at most, given enough water in reservoir.
  hydro_installed = @constraint(m, installed[1,4] == 14000)

  #Ensures the variable emission is equal to the CO_2 emissions from Gas in each country
  emission_value_con = @constraint(m, [ci in CI], emission[ci] == sum(power[ci,3,:])/efficiencies[3]*emission_factor[3])
  
  battery_con = @constraint(m, [ci in CI, t in T], -power[ci, 5, t]/efficiencies[5] + batteryInflow[ci,t] == batteryRes[ci, t+1] - batteryRes[ci, t])
  #battery_con = @constraint(m, [ci in CI, t in T], batteryRes[ci, t] <= batteryRes[ci, t>1 ? t-1 : T_end] + batteryInflow[ci,t]*efficiencies[5] - power[ci,5,t])
  #StorageLevel[r, h] <= StorageLevel[r, h>1 ? h-1 : length(HOUR)] + Charging[r, h] - Electricity[r, :Batteries, h]/eta[:Batteries]
  battery_start_stop_con = @constraint(m, [ci in CI], batteryRes[ci,0] == batteryRes[ci, T_end+1])
  battery_res_max_con = @constraint(m, [ci in CI, t in T], batteryRes[ci, t] <= installed[ci,5])

  return m, cost, installed, power, res, emission, batteryRes, batteryInflow
end

function build_model_exercise34(;I = 1:6)
  
  m = Model()
  @variable(m, installed[CI,I] >= 0) #Installed power in country ci of energy type i in MW.
  @variable(m, power[CI,I,T] >= 0) #Power output in country ci from energy source i at time t in MW.
  @variable(m, res[0:(T_end+1)] >= 0) #Size of water reservoir in Sweden at time t, in MW.
  @variable(m, batteryRes[CI, 0:(T_end+1)] >= 0) #Energy stored in batteries at time t in country ci, in MWh.
  @variable(m, emission[CI] >= 0)
  @variable(m, batteryInflow[CI,T] >= 0)


  @variable(m, installedTransBetween[CI,CI] >= 0)
  @variable(m, transmission[CI, CI, T] >= 0) #Transmitted power from country ci1 to country ci2 in MW.
  

  cost = @objective(m,Min, 
    sum([installed[country,i]*1000*annualized_costs[i] for country in CI, i in I])
    - sum(installed[country,6]*1000*annualized_costs[6]/2 for country in CI) #Only count the invested cost once.
    + sum([power[country,i,t]*variable_costs[i] for country in CI,i in ((length(I) > 6) ? [1,2,3,4,7] : [1,2,3,4]), t in T])
    + sum([batteryInflow[country,t]*variable_costs[5] for country in CI, t in T]) #Count variable cost for battery when charging.

    + sum([transmission[ci1,ci2,t]*variable_costs[6] for ci1 in CI, ci2 in CI, t in T]) #Count variable cost for transmission when sending (not receiving).
    # MW * 1h * Euro/MWh  =?= Euro
    + sum([power[country,i,t]*fuel_costs[i]/efficiencies[i] for country in CI, i in I, t in T]))
      # MW * 1h * Euro/Mwh =?= Euro

  # The installed power can't be higher than the maximum capacity
  #capacity_con = @constraint(m,[i in I, ci in CI], installed[ci,i] <= 1000*max_capacity_all[ci,i])
  for ci in CI, i in I
    set_upper_bound(installed[ci,i], 1000*max_capacity_all[ci,i])
  end

  # We need at least the power output required for each hour
  load_con = @constraint(m, [ci in CI, t in T], sum(power[ci,i,t] for i in I) - batteryInflow[ci,t] - sum(transmission[ci,ci2,t] for ci2 in CI) >= load_all[t+1, ci])

  # The output power must be lower than the installed power * the load factor
  power_con = @constraint(m, [ci in CI, i in I, t in T], power[ci, i, t] <= installed[ci,i]*hourly_load_factor[t+1,i,ci])

  hydro_con = @constraint(m, [t in T], -power[1,4,t] + inflow[t+1,1] == res[t+1] - res[t] )
  hydro_start_stop_con = @constraint(m, res[0] == res[T_end+1])
  hydro_max_con = @constraint(m, [t in T], res[t] <= 33*10^6)
  
  #Swedish hydro can produce 14 000 Mw at most, given enough water in reservoir.
  hydro_installed = @constraint(m, installed[1,4] == 14000)

  #Ensures the variable emission is equal to the CO_2 emissions from Gas in each country
  emission_value_con = @constraint(m, [ci in CI], emission[ci] == sum(power[ci,3,:])/efficiencies[3]*emission_factor[3])
  
  battery_con = @constraint(m, [ci in CI, t in T], -power[ci, 5, t]/efficiencies[5] + batteryInflow[ci,t] == batteryRes[ci, t+1] - batteryRes[ci, t])
  battery_start_stop_con = @constraint(m, [ci in CI], batteryRes[ci,0] == batteryRes[ci, T_end+1])
  battery_res_max_con = @constraint(m, [ci in CI, t in T], batteryRes[ci, t] <= installed[ci,5])

  transmission_power_con = @constraint(m, [ci in CI, t in T], power[ci, 6, t] == efficiencies[6]*sum(transmission[:, ci, t]))
  transmission_capacity_con = @constraint(m, [ci1 in CI, ci2 in CI, t in T], transmission[ci1,ci2,t] <= installedTransBetween[ci1,ci2] )
  installedTransBetween_self_con = @constraint(m,[ci in CI], installedTransBetween[ci,ci] == 0)
  transmission_installed_con = @constraint(m, [ci in CI], sum(installedTransBetween[ci,:])  == installed[ci,6])
  transmission_equal_con = @constraint(m, [ci1 in CI, ci2 in CI], installedTransBetween[ci1,ci2] == installedTransBetween[ci2,ci1])

  return m, cost, installed, power, res, emission, batteryRes, batteryInflow, installedTransBetween, transmission
end
