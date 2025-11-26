# This is going to be a simple optimal automobile replacement model

include("Structures/Households.jl")
include("Structures/Vehicles.jl")
include("Datacreator/Simdata.jl")


using Random, Distributions

# now we have the objects so we create the data

# Example of Jeff and his utility

Jeff = Household(UInt64(5),generate_random_vehicle() => generate_random_vehicle(),.6)
v_1, v_2 = Jeff.portfolio
Jeff_Util = Jeff.utility(v_1, v_2, v_1.price, v_2.price)
print("Jeff has $(round(Jeff_Util,digits = 2)) utils from owning his portfolio.\n")
print("Jeff owns $(Jeff.portfolio_size) vehicles, a $(v_1.age) year old and a $(v_2.age) year old car\n")

# average U
data = generate_HH(UInt(50000))


utilities = [compute_base_u(hh) for hh in data]
# end
using Statistics

mean_u = mean(utilities)
sd_u = std(utilities)
print("The mean utility is $(round(mean_u,digits = 0)) and the StDev is $(round(sd_u,digits=0))\n")

using StatsBase

function create_choiceset(HHs::Array{Household})
    vehicle_array = []
    for hh in HHs
        v_1, v_2 = hh.portfolio
        push!(vehicle_array, v_1)
        push!(vehicle_array, v_2)
    end
    return vehicle_array
end

