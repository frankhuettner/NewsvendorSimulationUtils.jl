sd = SimData()
append!(sd.qs, [0, 111, 155, 115])
NewsvendorSimulationUtils.update_sim_data!(sd)

@test_nowarn NewsvendorSimulationUtils.history_table(sd::SimData)

@test_nowarn NewsvendorSimulationUtils.visualize_demand_and_stock(sd::SimData)	

@test_nowarn NewsvendorSimulationUtils.visualize_profit_revenue_and_cost(sd::SimData)	

append!(sd.qs, round.(Int, rand(sd.nvm.demand, 26)))
@test_nowarn NewsvendorSimulationUtils.result_figures(sd::SimData)



@test_nowarn NewsvendorSimulationUtils.describe_demand(sd.nvm)
@test_nowarn NewsvendorSimulationUtils.visualize_demand(sd.nvm)
@test_nowarn NewsvendorSimulationUtils.describe_cost(sd.nvm)
@test_nowarn NewsvendorSimulationUtils.visualize_cost(sd.nvm)
@test_nowarn NewsvendorSimulationUtils.describe(sd.nvm)