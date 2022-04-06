
"""
    history_table(sd::SimData)	

View history play of a simulation.
"""
function history_table(sd::SimData)
    m = sd.days_played

    if m == 0 return md"" end 
        
    T = DataFrame(hcat( 1:m,
                        sd.qs, 
                        sd.demands[1:m],
                        sd.sales,
                        sd.left_overs,
                        sd.lost_sales,
                        sd.profits),         
        ["Day","Stocked","Demand","Sold","Left over","Lost sales","Profit"])
    # data_table(T)
end


"""
    visualize_demand_and_stock(sd::SimData)

Plot the daily demands and stocks of the current simulation.
"""
function visualize_demand_and_stock(sd::SimData)	
    scatter(sd.sales,  label="Sales", markerstrokewidth=3.5, c=:white, 
        markersize=7, markerstrokecolor = 3, bar_width=sd.days_played*0.01)	

    scatter!(sd.demands[1:sd.days_played], label = "Demanded", c = 1, msw = 0, 
        xlabel = "Day", xticks=1:sd.days_played, xrotation=60, size=(700, 450),
        right_margin=-8Plots.mm)
    plot!(sd.demands[1:sd.days_played], lw=1, ls=:dash, label="", c = 1)

    plot!([sd.avg_demand], seriestype="hline", 
        c=1,lw=2,ls=:dot,label="Observed\naverage\ndemand\n($(my_round(sd.avg_demand)))")

    scatter!(sd.qs, label = "You stocked", c = 2,  msw = 0)
    plot!(sd.qs, lw=1, ls=:dash, label="", c = 2, legend = :outerright)

    plot!([sd.avg_q], seriestype="hline", 
        c=2,lw=2, ls=:dot,label="Your average\ndecision ($(my_round(sd.avg_q)))")
end


"""
    visualize_profit_revenue_and_cost(sd::SimData)

Plot the daily profits, revenues and costs of the current simulation.
"""
function visualize_profit_revenue_and_cost(sd::SimData)
    days = 1:sd.days_played
    bar(days, sd.revenues, label="Revenue", lw=0,  c = :green, fillalpha = 0.61, bar_width=0.17, 
        size=(750, 150), xticks=days, xrotation=60, legend=:outerright)
    bar!(days.+0.17, sd.profits, label="Profit", lw=0,c = 5, fillalpha = 0.95, bar_width=0.17,)
    bar!(days, 0 .- sd.costs, label="Cost", lw=0,c = 2, fillalpha = 0.81, bar_width=0.17, )
    plot!(x->0, label="",  c = :black, left_margin=-2Plots.mm, right_margin=-6Plots.mm, bottom_margin=2Plots.mm)
end

