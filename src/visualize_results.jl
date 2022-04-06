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
    if is_running(sd) return null end

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