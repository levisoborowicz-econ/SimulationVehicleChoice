## Houshold Object ##
include("Vehicles.jl")

struct Household
    id::UInt64
    utility::Function
    portfolio::Pair{Vehicle, Vehicle}
    income::UInt64
    children::UInt64
    α::Float64
    vehicle_preferences::Dict{Symbol, Float64}
    portfolio_preferences::Dict{Symbol, Float64}
    portfolio_size::UInt8

    # this is called Household because it overwrites the default constructor function
    # I put the default arg here not in the declaration of the structrue 
    function Household(id::UInt64, portfolio::Pair{Vehicle, Vehicle}, α::Real=.5)
        # Draw preferences inside constructor
        preferences = draw_preferences()
        
        # Create utility function using those preferences
        utility_func = create_single_utility(preferences)
        
        # Create portfolio utility function
        # I need some meta preferences 
        comp_preferences = draw_complementary_preferences()
        portfolio_func = meta_utility(utility_func, comp_preferences,α)
        
        # this can come later since we don't evalueate the utility yet :) planning ahead
        v_1, v_2 = portfolio
        ordered_portfolio = order_veh(v_1, v_2)
        portfolio_size = v_1.ISVEH + v_2.ISVEH
        new(UInt64(id), portfolio_func, ordered_portfolio, income, Float64(α), preferences, comp_preferences, portfolio_size)
    end
end

# functions that Draw preferences for utility computaiton
function draw_preferences()
    # Population means
    β_mean = Dict(
        :age => -1.0,
        :mileage => -2.0,
        :VOLVO => 4.0,
        :SAAB => 2.0,
        :PETROL => 0.0,
        :DIESEL => 2.0,
        :ELECTRIC => 4.0,
        :price => 2.0,
        :ISVEH => 25
    )
    
    # Draw individual deviations
    β_individual = Dict(
        :age => β_mean[:age] + rand(Uniform(0, 1)),
        :mileage => β_mean[:mileage] + rand(Uniform(0, 2)),
        :VOLVO => β_mean[:VOLVO] + rand(Normal(0, 2)),
        :SAAB => β_mean[:SAAB] + rand(Normal(0, 2)),
        :PETROL => β_mean[:PETROL] + rand(Normal(0, 1)),
        :DIESEL => β_mean[:DIESEL] + rand(Normal(0, 4)),
        :ELECTRIC => β_mean[:ELECTRIC] + rand(Normal(0, 2)),
        :price => β_mean[:price] + rand(Uniform(-1.5, 2)),
        :ISVEH => β_mean[:ISVEH] + rand(Normal(0, 2))
    )

    return β_individual
end

function draw_complementary_preferences()
    # Population means
    β_mean = Dict(
        :d_comp => 4.0,
        :p_comp => 1.0,
        :pd_comp => 2.0
    )
    
    # Draw individual deviations
    β_individual = Dict(
        :d_comp => β_mean[:d_comp] + rand(Normal(0, 3)),
        :p_comp => β_mean[:p_comp] + rand(Normal(0, 3)),
        :pd_comp => β_mean[:pd_comp] + rand(Normal(0, 2))
    )

    return β_individual
end

function generate_income_family(portfolio_size)
    if portfolio_size == 2
        return rand(Uniform(650000,2000000)), rand(Binomial(5,p=.6))
    elseif portfolio_size == 1
        return rand(Uniform(200000,1000000)), rand(Binomial(5,p=.2))
    elseif portfolio_size == 0
        return rand(Uniform(00000,800000)), rand(Binomial(5,p=.1))
    end
end
# This function checks to see if the Vehicle portfolio is Complementary
function check_for_compl(v_1::Vehicle, v_2::Vehicle)
    # Check for Diesel + Electric complement
    # the double &&, || or logic ands and ors, 
    # The & is a bitwise operator (+)
    d_comp = (v_1.DIESEL == 1 && v_2.ELECTRIC == 1) || 
             (v_1.ELECTRIC == 1 && v_2.DIESEL == 1)
    
    # Check for Petrol + Electric complement
    p_comp = (v_1.PETROL == 1 && v_2.ELECTRIC == 1) || 
             (v_1.ELECTRIC == 1 && v_2.PETROL == 1)
    
    # Check for Petrol + Diesel complement
    pd_comp = (v_1.PETROL == 1 && v_2.DIESEL == 1) || 
              (v_1.DIESEL == 1 && v_2.PETROL == 1)
    
    return Int8(d_comp), Int8(p_comp), Int8(pd_comp)
end

# Meta utility recieves the individuals utility fucntion
# this creates a new function for every utility function it is given
# but you need to have created the single car utility function
# we cant use cobb dounglas aggregator - we want to add utility and then allow complementarity through
# the fuel type portfolio
function meta_utility(utility::Function, β::Dict{Symbol,Float64}, α::Real)
    # Return a NEW function that evaluates portfolios
    function portfolio_utility(v_1::Vehicle, v_2::Vehicle, price_1::Real, price_2::Real)
        u_1 = utility(v_1, price_1)
        u_2 = utility(v_2, price_2)
        d_comp, p_comp, pd_comp = check_for_compl(v_1,v_2)
        return α*u_1 + (1-α)u_2 + d_comp*β[:d_comp] + p_comp*β[:p_comp] + pd_comp*β[:pd_comp]
    end
    return portfolio_utility
end

# this is the single car utility function
function create_single_utility(β::Dict{Symbol, Float64},hh::Household)
    function utility(v::Vehicle, price::Real)
        u = β[:price] * ((Household.income - price) / 100000)
        u += β[:age] * v.age
        u += β[:mileage] * (v.mileage / 100000)
        # Brand dummies
        u += β[:VOLVO] * (v.VOLVO)
        u += β[:SAAB] * (v.SAAB)
        
        # Fuel type dummies
        u += β[:PETROL] * (v.PETROL)
        u += β[:DIESEL] * (v.DIESEL)
        u += β[:ELECTRIC] * (v.ELECTRIC)
        
        # is it a vehicle
        u += β[:ISVEH] * (v.ISVEH)

        return u
    end
    return utility
end

# this just computes the base utility
function compute_base_u(hh::Household)
    v_1, v_2 = hh.portfolio
    u = hh.utility(v_1,v_2,v_1.price,v_2.price)
    return u
end

# Helper function for ordering
# first looks for existence
# then looks at age
function order_veh(v_1::Vehicle, v_2::Vehicle)
    if v_1.ISVEH != 0 && v_2.ISVEH == 0
        return (v_1 => v_2)
    elseif v_1.ISVEH == 0 && v_2.ISVEH != 0
        return (v_2 => v_1)
    else
        ordered_portfolio = v_1.age <= v_2.age ? (v_1 => v_2) : (v_2 => v_1)
        return ordered_portfolio
    end
end