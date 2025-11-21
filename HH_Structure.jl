## Houshold Object ##

struct Household
    id::UInt64
    utility::Function
    portfolio::Pair{Vehicle, Vehicle}
    α::Float64
    preferences::Dict{Symbol, Float64}
    # this is called Household because it overwrites the default constructor function
    function Household(id::UInt64, portfolio::Pair{Vehicle, Vehicle}, α::Real)
        # Draw preferences inside constructor
        preferences = draw_preferences()
        
        # Create utility function using those preferences
        utility_func = create_single_utility(preferences)
        
        # Create portfolio utility function
        # I need some meta preferences 
        comp_preferences = draw_complementary_preferences()
        portfolio_func = meta_utility(utility_func, comp_preferences, α)
        
        v1, v2 = portfolio
        ordered_portfolio = v1.age <= v2.age ? (v1 => v2) : (v2 => v1)
        new(UInt64(id), portfolio_func, ordered_portfolio, Float64(α), preferences)
    end
end

# functions that go in the Household Object 
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
        :price => -2.0
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
        :price => β_mean[:price] + rand(Uniform(0, 1))
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
    
    return d_comp, p_comp, pd_comp
end


# Meta utility recieves the individuals utility fucntion
# this creates a new function for every utility function it is given
# but you need to have created the single car utility function
# we cant use cobb dounglas aggregator - we want to add utility and then allow complementarity through
# the fuel type portfolio
function meta_utility(utility::Function, β::Dict{Symbol,Real},α::Real)
    # Return a NEW function that evaluates portfolios
    function portfolio_utility(v_1::Vehicle, v_2::Vehicle, price_1::Real, price_2::Real)
        u_1 = utility(v_1, price_1)
        u_2 = utility(v_2, price_2)
        d_comp, p_comp, pd_comp = check_for_compl(v_1,v_2)
        return u_1 + u_2 + d_comp*β[:d_comp] + p_comp*β[:p_comp] + β[:pd_comp]
    end
    return portfolio_utility
end

# this is the single car utility function
function create_single_utility(β::Dict{Symbol, Float64})
    function utility(v::Vehicle, price::Real)
        u = β[:price] * log(price)
        u += β[:age] * v.age
        u += β[:mileage] * (v.mileage / 100000)
        # Brand dummies
        u += β[:VOLVO] * (v.VOLVO)
        u += β[:SAAB] * (v.SAAB)
        
        # Fuel type dummies
        u += β[:PETROL] * (v.PETROL)
        u += β[:DIESEL] * (v.DIESEL)
        u += β[:ELECTRIC] * (v.ELECTRIC)
        
        return u
    end
    return utility
end
# Houshold Functions for creating the object

