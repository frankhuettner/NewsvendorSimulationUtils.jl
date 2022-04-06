function describe_demand(nvm::NVModel; return_as_MD = true)
	res = """
	#### Information Abouth The Demand	
	* Customer **demand is uncertain** and will be **between $(minimum(nvm.demand)) and
	  $(maximum(nvm.demand))** every day. 
	* Independent of the demand of the previous day, you **expect 
	  μ = $(my_round(mean(nvm.demand)))** and face uncertainty captured by a standard
	  deviation of **σ = $(my_round(std(nvm.demand)))**. 
	"""
	return_as_MD ? Markdown.parse(res) : res
end

function visualize_demand(nvm::NVModel)	
	l = minimum(nvm.demand)
	u = maximum(nvm.demand)
	μ = mean(nvm.demand)
	distr = nvm.demand

	plt_dem = plot(left_margin = 15Plots.mm, label="cdf", xlabel="Daily Demand", 
				ylabel="Likelihood", yaxis=nothing, legend=false,
				xlims=(l-(u-l)/6,u+(u-l)/6))
	
	if distr isa DiscreteNonParametric
		xs = params(distr)[1]
		bar!(plt_dem, l:u, [pdf(distr,x) for x in l:u], c=1,  lw=0, bar_width=(xs[end]-xs[1])/20)
		plot!(plt_dem, yaxis=0:.1:1,ylims=(0,1), xaxis=xs)
	else
		plot!(plt_dem, l:u, [pdf(distr,x) for x in l:u], fillrange=(x->0),c=1, fillalpha=0.81,lw=0)
		plot!(plt_dem, l:u, [pdf(distr,x) for x in l:u], c=4,  lw=3)
		plot!(plt_dem, l-(u-l)/5:l, x->0, lw=3, c=4)
		plot!(plt_dem, u:u+(u-l)/5, x->0, lw=3, c=4)
		vline!([μ], c=:white)
		annotate!(0.9*μ, pdf(distr,μ)/10, Plots.text("μ = $(my_round(μ))", 10, :white, :left, rotation = 90), size=(400,200))
	end
end


function describe_cost(nvm::NVModel; return_as_MD = true)
	res = """
	#### Unit Price and Cost
	* You **pay $(nvm.cost)** for each unit that you stock.
	* You **get $(nvm.price)** for each unit that you sell to your customer.
	* At the end of each round, unsold units are discarded at a 
	  **salvage value** of **$(nvm.salvage)**.
	"""
	return_as_MD ? Markdown.parse(res) : res
end


function visualize_cost(nvm::NVModel)
	plt_econ = bar([1], [nvm.salvage], size=(400,200), orientation=:h, yaxis=false,
					yticks=nothing, c = :grey, alpha=.3, legend=false)	
	bar!([2], [nvm.cost], orientation=:h, c = :red, alpha=.3, legend=false)
	bar!([3], [nvm.price], orientation=:h, c = :green, alpha=.3, legend=false)
	annotate!(0.02*nvm.price, 3, "Unit Selling Price", :left)
	annotate!(0.02*nvm.price, 2, "Unit Cost", :left)
	annotate!(0.02*nvm.price, 1, "Unit Salvage Value", :left)
end


function describe(nvm::NVModel; return_as_MD = true)
	res = describe_demand(nvm, return_as_MD = false) * 
                    describe_cost(nvm, return_as_MD = false)
	return_as_MD ? Markdown.parse(res) : res			  
end