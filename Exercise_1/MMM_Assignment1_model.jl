

function build_model(Val :: Int)

  using JuMP

  include("MMM_Assignment1_data.jl")

  m = Model()

  @variable(m, x[CI,I] >= 0)
  @variable(m, res[T] >= 0)

  cost=zeros(3)
  for ci in CI
    cost[ci] = @objective(m,Min, sum(x[ci,i]*1000*energy_systems[i,1] for i in I) + sum(x[ci,i]*energy_systems[i,2]*energy_systems[i,5] for i in I)
    + sum(x[ci,i]*energy_systems[i,3] for i in I))
  end


  const1 = @constraint(m, x[ci,i] <= 1000*max_capacity_all[ci,i] for i in I, ci in CI)

  const2 = @constraint(m,((x[ci,i] >= countrydata[t,4,ci] for i in I) for ci in CI) for t in T)

  #Swedish hydro produces 14 000 Mw
  const3 = @constraint(m, x[1,4] = 14_000)

  const4 = @constraint(m, res[1] = 33*10^6 + inflow[1,2])

  const5 = @constraint(m, res[T_end] = 33*10^6 + inflow[T_end,2])

  return m, x
end
