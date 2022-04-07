sd = SimData()
@test_nowarn NewsvendorSimulationUtils.update_sim_data!(sd)

append!(sd.qs, [0, 111, 155, 115])
NewsvendorSimulationUtils.update_sim_data!(sd)

@test_nowarn NewsvendorSimulationUtils.update_result_figures_panel(sd::SimData)

@test_nowarn NewsvendorSimulationUtils.history_table(sd::SimData)

@test_nowarn NewsvendorSimulationUtils.visualize_demand_and_stock(sd::SimData)	

@test_nowarn NewsvendorSimulationUtils.visualize_profit_revenue_and_cost(sd::SimData)	

@test_nowarn NewsvendorSimulationUtils.update_submission_and_result_panel(sd::SimData)
@test_nowarn NewsvendorSimulationUtils.update_demand_realization_panel(sd::SimData)
@test_nowarn NewsvendorSimulationUtils.update_history_table(sd::SimData)

append!(sd.qs, round.(Int, rand(sd.nvm.demand, 26)))
@test_nowarn NewsvendorSimulationUtils.update_sim_data!(sd)
@test_nowarn NewsvendorSimulationUtils.result_figures(sd::SimData)

@test_nowarn NewsvendorSimulationUtils.update_result_figures_panel(sd::SimData)


@test_nowarn NewsvendorSimulationUtils.update_submission_and_result_panel(sd::SimData)
@test_nowarn NewsvendorSimulationUtils.update_demand_realization_panel(sd::SimData)

@test_nowarn NewsvendorSimulationUtils.describe_demand(sd.nvm)
@test_nowarn NewsvendorSimulationUtils.visualize_demand(sd.nvm)
@test_nowarn NewsvendorSimulationUtils.describe_cost(sd.nvm)
@test_nowarn NewsvendorSimulationUtils.visualize_cost(sd.nvm)
@test_nowarn NewsvendorSimulationUtils.describe(sd.nvm)


cheers4 = NVModel(cost=10, price=42, demand=DiscreteNonParametric([0,1,2],[.3,.5,.2]))

@test_nowarn NewsvendorSimulationUtils.describe_demand(cheers4)
@test_nowarn NewsvendorSimulationUtils.visualize_demand(cheers4)
@test_nowarn NewsvendorSimulationUtils.describe_cost(cheers4)
@test_nowarn NewsvendorSimulationUtils.visualize_cost(cheers4)
@test_nowarn NewsvendorSimulationUtils.describe(cheers4)