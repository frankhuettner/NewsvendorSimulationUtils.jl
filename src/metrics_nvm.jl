import NewsvendorModel: lost_sales, sales, leftover, profit


function lost_sales(nvm::NVModel, qs::Vector{<:Number}) 
    if length(qs) == 0 
        return 0.0
    else
        mean([lost_sales(nvm, q) for q in qs])
    end
end
function sales(nvm::NVModel, qs::Vector{<:Number}) 
    if length(qs) == 0 
        return 0.0
    else
        mean([sales(nvm, q) for q in qs])
    end
end
function leftover(nvm::NVModel, qs::Vector{<:Number}) 
    if length(qs) == 0 
        return 0.0
    else
        mean([leftover(nvm, q) for q in qs])
    end
end
function profit(nvm::NVModel, qs::Vector{<:Number}) 
    if length(qs) == 0 
        return 0.0
    else
        mean([profit(nvm, q) for q in qs])
    end
end
