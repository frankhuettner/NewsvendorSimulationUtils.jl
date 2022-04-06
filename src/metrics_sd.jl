"""
    likelihood_of_observed_mean(observed_mean, nvm::NVModel, N = 100_000::Int)	

Compute likelihood of observed mean using Monte Carlo simuation with N trials.
"""
function likelihood_of_observed_mean(sd::SimData, observed_mean, N = 100_000::Int)
    distr = sd.nvm.demand
    num_days = sd.sim_conf.max_num_days
    μ = mean(distr)
    obs_distance = abs(μ - observed_mean)

    count = 0
    for i in 1:N
        if abs( mean(rand(distr, num_days)) - μ ) > obs_distance
            count = count + 1
        end
    end
    return count / N
end