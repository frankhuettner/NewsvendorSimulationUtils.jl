Base.@kwdef struct Story
	title::String = "Patisserie Cheers!"
	url::String = "https://raw.githubusercontent.com/frankhuettner/newsvendor/main/scenarios/cheers_1_story.md"
end

Base.@kwdef struct SimConf
	max_num_days::Int = 30  # Maximal number of rounds to play
	delay::Int = 300    # ms it takes for demand to show after stocking decision 
	allow_reset::Bool = false
end

Base.@kwdef mutable struct SimData
	name::String="cheers_1"
	nvm::NVModel = NVModel(truncated(Normal(90, 30), lower = 0, upper = 180), cost = 1, price = 5)
	story::Story = Story()	
	sim_conf::SimConf = SimConf()

    "Realized demands"
	demands::Vector{Int64} = round.(Int, rand(nvm.demand, sim_conf.max_num_days))
	"Choosen quantities"
    qs::Vector{<:Number} = Vector{Int64}()
	"Days completed"
	days_played::Int = length(qs)
	
    "Sales implied by demand and choosen quantities"
	sales::Vector{<:Number} = Vector{Int64}()
    "Lost sales implied by demand and choosen quantities"
	lost_sales::Vector{<:Number} = Vector{Int64}()
    "Left overs implied by demand and choosen quantities"
	left_overs::Vector{<:Number} = Vector{Int64}()
    "Revenue implied by demand, choosen quantities, unit price and unit salvage value"
	revenues::Vector{<:Number} = Vector{Float64}()
    "Cost implied by choosen quantities unit cost"
	costs::Vector{<:Number} = Vector{Float64}()
    "Proifts implied by demand, choosen quantities, unit price, cost, and unit salvage value"
	profits::Vector{<:Number} = Vector{Float64}()
	
	total_demand::Int64 = 0
	total_q::Int64 = 0
	total_sale::Int64 = 0
	total_lost_sale::Int64 = 0
	total_left_over::Int64 = 0
	total_revenue::Float64 = 0.0
	total_cost::Float64 = 0.0
	total_profit::Float64 = 0.0
	
	avg_demand::Float64 = 0.0
	avg_q::Float64 = 0.0
	avg_sale::Float64 = 0.0
	avg_lost_sale::Float64 = 0.0
	avg_left_over::Float64 = 0.0
	avg_revenue::Float64 = 0.0
	avg_cost::Float64 = 0.0
	avg_profit::Float64 = 0.0
	
	expected_lost_sales::Float64 = 0.0
	expected_sales::Float64 = 0.0
	expected_left_overs::Float64 = 0.0
	expected_profits::Float64 = 0.0
end


"""
    update_sim_data!(sd::SimData)	

Update realized and expected sales, profits etc. for a given demand and choosen quantity.
Return [expected lost sales, expected sales, expected left overs,  expected_profits].
"""
function update_sim_data!(sd::SimData)
	sd.days_played = length(sd.qs)
	
	sd.sales = min.(sd.qs, sd.demands[1:sd.days_played])
	sd.lost_sales = sd.demands[1:sd.days_played] - sd.sales
	sd.left_overs = sd.qs - sd.sales
	sd.revenues = sd.nvm.price .* sd.sales + sd.nvm.salvage .* sd.left_overs
	sd.costs = sd.nvm.cost .* sd.qs
	sd.profits = sd.revenues - sd.costs
	
	sd.total_demand = sum(sd.demands[1:sd.days_played])
	sd.total_q = sum(sd.qs)
	sd.total_sale = sum(sd.sales)
	sd.total_lost_sale = sum(sd.lost_sales)
	sd.total_left_over = sum(sd.left_overs)
	sd.total_revenue = sum(sd.revenues)
	sd.total_cost = sum(sd.costs)
	sd.total_profit = sum(sd.profits)
	
	if sd.days_played > 0
		sd.avg_demand = sd.total_demand / sd.days_played
		sd.avg_q = sd.total_q / sd.days_played
		sd.avg_sale = sd.total_sale / sd.days_played
		sd.avg_lost_sale = sd.total_lost_sale / sd.days_played
		sd.avg_left_over = sd.total_left_over / sd.days_played
		sd.avg_revenue = sd.total_revenue / sd.days_played
		sd.avg_cost = sd.total_cost / sd.days_played
		sd.avg_profit = sd.total_profit / sd.days_played
	end
	
	sd.expected_lost_sales = lost_sales(sd.nvm, sd.qs)
	sd.expected_sales = sales(sd.nvm, sd.qs)
	sd.expected_left_overs = leftover(sd.nvm, sd.qs)
	sd.expected_profits = profit(sd.nvm, sd.qs)

	return sd
end

function is_running(sd::SimData)
	return length(sd.qs) < sd.sim_conf.max_num_days
end

function partialcopy(sd::SimData)
	sd2 = SimData(name = sd.name, nvm = sd.nvm, story = sd.story, 
				sim_conf = sd.sim_conf, demands = sd.demands, 
				qs = sd.qs, days_played = sd.days_played)
	return sd2
end