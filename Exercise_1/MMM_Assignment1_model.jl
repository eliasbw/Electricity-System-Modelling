using JuMP

include("MMM_Assignment1_data.jl")

function build_model()

  m = Model()

  @variable(m, installed[CI,I] >= 0) #Installed power in country ci of energy type i in MW.
  @variable(m, power[CI,I, T] >= 0) #Power output in country ci from energy source i at time t in MW.
  @variable(m, res[0:(T_end+1)] >= 0) #Size of water reservoir in Sweden at time t, in MW.
  
  cost = @objective(m,Min, 
    sum([installed[country,i]*1000*annualized_costs[i] for country in CI, i in I])
    + sum([power[country,i,t]*variable_costs[i] for country in CI,i in I, t in T])
      # MW * 1h * Euro/MWh  =?= Euro
    + sum([power[country,i,t]*fuel_costs[i]/efficiencies[i] for country in CI, i in I, t in T]))
      # MW * 1h * Euro/Mwh =?= Euro

  # The installed power can't be higher than the maximum capacity
  capacity_con = @constraint(m,[i in I, ci in CI], installed[ci,i] <= 1000*max_capacity_all[ci,i])

  # We need at least the power output required for each hour
  load_con = @constraint(m, [ci in CI, t in T], sum(power[ci,i,t] for i in I) >= load_all[t+1, ci])

  # The output power must be lower than the installed power * the load factor
  power_con = @constraint(m, [ci in CI, i in I, t in T], power[ci, i, t] <= installed[ci,i]*hourly_load_factor[t+1,i,ci])

  hydro_con = @constraint(m, [t in T], -power[1,4,t] + inflow[t+1,1] == res[t+1] - res[t] )
  hydro_start_con = @constraint(m, res[0] == 33*10^6/2)
  hydro_stop_con = @constraint(m, res[T_end+1] == 33*10^6/2)
  hydro_max_con = @constraint(m, [t in T], res[t] <= 33*10^6)
    
  #Swedish hydro can produce 14 000 Mw at most, given enough water in reservoir.
  hydro_installed = @constraint(m, installed[1,4] == 14000)

  return m, installed, power, res 
end
