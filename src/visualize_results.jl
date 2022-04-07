function create_reference_plays(sd::SimData)
    results = OrderedDict("Your play" => sd)

    naive_data = partialcopy(sd)
    naive_data.qs = round.(Int, mean(sd.nvm.demand) * ones(sd.sim_conf.max_num_days))
    update_sim_data!(naive_data)
    results["Always order\nthe mean,\nstock = $(naive_data.qs[1])"] = naive_data	

    opt_data = partialcopy(sd)
    opt_data.qs = round.(Int, q_opt(sd.nvm) * ones(sd.days_played))
    update_sim_data!(opt_data)
    results["The strategy\nthat maximizes\nexpected profit,\nie if Service Level\n= Critical Fractile"] = opt_data

    dream_data = partialcopy(sd)
    dream_data.qs = sd.demands
    update_sim_data!(dream_data)
    dream_data.expected_lost_sales = 0.0
    dream_data.expected_sales = mean(sd.nvm.demand)
    dream_data.expected_left_overs = 0.0
    dream_data.expected_profits = (sd.nvm.price-sd.nvm.cost) * mean(sd.nvm.demand)
    results["God mode: you\nknow the future,\nstock = units to\n   be demanded"] = dream_data

    return results
end

"""
    result_figures(sd::SimData)

Visualize the result.
"""
function result_figures(sd::SimData; sftsz = 11, lftsz = 13)   
    if is_running(sd) return nothing end

    results = create_reference_plays(sd)

    plt = plot()

    # descriptions
    description_plt = plot(legend=false, ticks=nothing, axis = false, grid = false, 
            palette=:lightrainbow, ylabel = "Strategy")
    x_loc = 0
    for (description, _) in results
        bar!([x_loc], [1], alpha=.3)
        annotate!(x_loc, 0.5, text(description, sftsz))
        x_loc = x_loc + 1
    end	

    # comparing profits
    profit_plt = plot(legend=false, ticks=nothing, axis = false, grid = false, 
            palette=:lightrainbow, ylabel = "Average Profit")
    x_loc = 0
    for (description, data) in results
        y = my_round(data.avg_profit)
        bar!([x_loc], [y], alpha=.3)	
        annotate!(x_loc, y, text("$(my_round(y))", lftsz,:bottom))
        x_loc = x_loc + 1
    end

    # comparing sales
    sale_plt = plot(legend=false, ticks=nothing, axis = false, grid = false, 
            palette=:lightrainbow, ylabel = "Avg. Sales")
    x_loc = 0
    for (description, data) in results
        y = data.avg_sale
        bar!([x_loc], [y], alpha=.3)
        annotate!(x_loc, y, text("$(my_round(y))", lftsz,:bottom))
        x_loc = x_loc + 1
    end

    # comparing left over
    left_over_plt = plot(legend=false, ticks=nothing, axis = false, grid = false, 
            palette=:lightrainbow, ylabel="Avg. Left Over")
    for (description, data) in results
        y =  my_round(data.avg_left_over)
        bar!([x_loc], [y], alpha=.3)
        annotate!(x_loc, y, text("$(my_round(y))", lftsz,:bottom))
        x_loc = x_loc + 1
    end	

    # comparing lost sales
    lost_sale_plt = plot(legend=false, ticks=nothing, axis = false, grid = false, 
            palette=:lightrainbow, ylabel="Avg. Lost Sales")
    for (description, data) in results
            y =  data.avg_lost_sale
            bar!([x_loc], [y], alpha=.3)
        annotate!(x_loc, y, text("$(my_round(y))", lftsz,:bottom))
        x_loc = x_loc + 1
    end	

    # comparing expected profit
    exp_profit_plt = plot(legend=false, ticks=nothing, axis = false, grid = false, 
        yguidefontcolor=:grey,	palette=:lightrainbow, ylabel="Expected Avg. Profit\n(if we play forever)")
    for (description, data) in results
        y = data.expected_profits
        bar!([x_loc], [y], alpha=.13)
        annotate!(x_loc, y, text("$(my_round(y))", :grey, lftsz,:bottom))
        x_loc = x_loc + 1
    end	

    # comparing expected sales
    exp_sales_plt = plot(legend=false, ticks=nothing, axis = false, grid = false, 
        yguidefontcolor=:grey,	palette=:lightrainbow, ylabel="Expected Avg. Sales\n(if we play forever)")
    for (description, data) in results
        y = data.expected_sales
        bar!([x_loc], [y], alpha=.13)
        annotate!(x_loc, y, text("$(my_round(y))", :grey, lftsz,:bottom))
        x_loc = x_loc + 1
    end	

    # comparing expected leftover inventory
    exp_left_over_plt = plot(legend=false, ticks=nothing, axis = false, grid = false, 
        yguidefontcolor=:grey,	palette=:lightrainbow, ylabel="Exp. Avg. Left Over \n(if we play forever)")
    for (description, data) in results
        y = data.expected_left_overs
        bar!([x_loc], [y], alpha=.13)
        annotate!(x_loc, y, text("$(my_round(y))", :grey, lftsz,:bottom))
        x_loc = x_loc + 1
    end	

    # comparing expected lost sales
    exp_lost_sale_plt = plot(legend=false, ticks=nothing, axis = false, grid = false, 
        yguidefontcolor=:grey,	palette=:lightrainbow, ylabel="Exp. Avg. Lost Sales\n(if we play forever)")
    for (description, data) in results
        y = data.expected_lost_sales
        bar!([x_loc], [y], alpha=.13)
        annotate!(x_loc, y, text("$(my_round(y))", :grey, lftsz,:bottom))
        x_loc = x_loc + 1
    end	
    
    description_height = 0.06
    profit_height = 0.14
    other_height = 0.11
    heights = [description_height, profit_height,other_height,other_height,other_height, profit_height,other_height,other_height,other_height]
    
    plt = plot(description_plt, profit_plt, sale_plt, left_over_plt, lost_sale_plt,
        exp_profit_plt, exp_sales_plt, exp_left_over_plt, exp_lost_sale_plt, ylabelfontsize=13,	layout = grid(9, 1, heights=heights), size=(820, 2000), bottom_margin=3Plots.mm, top_margin=5Plots.mm, right_margin=-8Plots.mm, left_margin=12Plots.mm)
end

function update_submission_and_result_panel(sd::SimData)
	
	if sd.days_played > 0 && sd.days_played < sd.sim_conf.max_num_days
md" ##### 👉 How much do you want to stock for day $(sd.days_played+1)?"
	elseif sd.days_played == sd.sim_conf.max_num_days 
			
days_out_of_stock = count(sd.qs .< sd.demands)
days_demand_satisfied = sd.sim_conf.max_num_days - days_out_of_stock
service_level = my_round(100 * days_demand_satisfied/sd.sim_conf.max_num_days)
			
md"""
!!! tip "You came to the end of the simulation." 
	👍 Great job!
	
	Scroll down to find a comparison of your result with alternative strategies.

		

		
##### Your average order was:  $(my_round(sd.avg_q, sigdigits=4)) units.

The **observed average demand** was **$(my_round(sd.avg_demand, sigdigits=4))**, whereas $(my_round(mean(sd.nvm.demand), sigdigits=4)) was expected. (Did you have an extreme sample of demands? To give you an idea as to how (un)usual your random draws were: Out of 100 students runing this simulation, 
$(round(Int,(100*likelihood_of_observed_mean(sd, sd.avg_demand) )))  observe an average in their simulation that is even further from the mean than yours.)
			

##### ☝️ Your service level was $(service_level)%. 

On $(days_out_of_stock) out of $(sd.sim_conf.max_num_days), you ran out of stock; **on $(days_demand_satisfied) out of $(sd.sim_conf.max_num_days), you satisfied all customers**, 
which gives the service level  $(days_demand_satisfied) /  $(sd.sim_conf.max_num_days) = $(my_round(service_level)) %. 
 
	"""
	else
md" ##### 👉 How much do you want to stock for day $(sd.days_played+1)?"
	end
end 

function update_result_figures_panel(sd::SimData)
	if sd.days_played == sd.sim_conf.max_num_days
		result_figures(sd) 
	else
		md""
	end	
end


function update_demand_realization_panel(sd::SimData)

	if sd.days_played > 0 && sd.days_played <= sd.sim_conf.max_num_days
md"""
**Total profit: \$ $(my_round(sd.total_profit, sigdigits=4))** ``~~`` 

**Average profit: \$ $(my_round(sd.avg_profit, sigdigits=4))**
		
**Result for day $(sd.days_played):**
		
Day  	| Stocked 	| Demand 	| Sold 	| Left over 	| Lost sales 	| Profit 	|
|---	|---	|---	|---	|---	|---	|---	|
|$(sd.days_played)  | $(sd.qs[end]) 	| $(sd.demands[sd.days_played]) 	| $(sd.sales[end]) 	| $(sd.left_overs[end]) 	| $(sd.lost_sales[end]) 	| \$ $(sd.profits[end]) 	|	
"""
	else	
md""
	end
end

function data_table(table)
	d = Dict(
        "headers" => [Dict("text" => string(name), "value" => string(name)) for name in Tables.columnnames(table)],
        "data" => [Dict(string(name) => row[name] for name in Tables.columnnames(table)) for row in Tables.rows(table)]
    )
	djson = JSON3.write(d)
	
	return HTML("""
		<link href="https://cdn.jsdelivr.net/npm/@mdi/font@5.x/css/materialdesignicons.min.css" rel="stylesheet">


	  <div id="app">
		<v-app>
		  <v-data-table
		  :headers="headers"
		  :items="data"
		></v-data-table>
		</v-app>
	  </div>

	  <script src="https://cdn.jsdelivr.net/npm/vue@2.x/dist/vue.js"></script>
	  <script src="https://cdn.jsdelivr.net/npm/vuetify@2.x/dist/vuetify.js"></script>
	
	<script>
		new Vue({
		  el: '#app',
		  vuetify: new Vuetify(),
		  data () {
				return $djson
			}
		})
	</script>
	<style>
		.v-application--wrap {
			min-height: 10vh;
		}
		.v-data-footer__select {
			display: none;
		}
	</style>
	""")
end


function update_history_table(sd::SimData)
	if sd.days_played > 0
		T = Tables.table(hcat( 	1:sd.days_played,
								sd.qs, 
								sd.demands[1:sd.days_played],
								sd.sales,
								sd.left_overs,
								sd.lost_sales,
								sd.profits); 
			
		header = ["Day","Stocked","Demand","Sold","Left over","Lost sales","Profit"])
		data_table(T)
	else
		return md""
	end
end; md""