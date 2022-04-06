sd = SimData()

@test NewsvendorSimulationUtils.likelihood_of_observed_mean(sd, 80) < 1
@test NewsvendorSimulationUtils.likelihood_of_observed_mean(sd, 90) == 1.0