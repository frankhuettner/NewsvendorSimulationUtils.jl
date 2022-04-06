module NewsvendorSimulationUtils

using DocStringExtensions
using Distributions
using Plots
using Markdown
using QuadGK
using Tables
using JSON3
using DataFrames
using OrderedCollections
using NewsvendorModel
import Base: show


export my_round
export SimData, is_running



"""
	my_round(x::Real; [sigdigits::Int=3])		

Return x rounded with #sigdigits significiant digits.
"""
function my_round(x::Real; sigdigits::Int=3)
	x = round(x, sigdigits=sigdigits)
	if x >= 10^(sigdigits-1)
		Int(x)
	else
		x
	end
end


include("./metrics_nvm.jl")
include("./simdata.jl")
include("./metrics_sd.jl")
include("./visualize_nvm.jl")
include("./visualize_play.jl")
include("./visualize_results.jl")

end # module

