
include("../Structures/Households.jl")
include("../Structures/Vehicles.jl")

function generate_HH(iterations::UInt64)
    # the sorting of vehicles occurs in the constructor
    households = [Household(i, generate_random_vehicle() => generate_random_vehicle(), 0.6) for i in 1:iterations]
    return households
end


function generate_random_vehicle(share_volvo::Real=0.7, 
                                share_petrol::Real=0.4, 
                                share_diesel::Real=0.5,
                                prob_is_car::Real=.32)
    
    draw = rand(Uniform(0,1))
    is_car = draw < prob_is_car ? true : false

    if is_car
        # Generate age (0 to 20 years, log-distributed means more newer cars)
        age = floor(UInt8, rand(Exponential(5)))  # Mean ~5 years old
        age = min(age, 20)  # Cap at 20 years
        
        # Generate mileage (correlated with age)
        base_mileage = age * rand(Uniform(8000, 15000))  # 8k-15k miles per year
        mileage = floor(UInt64, base_mileage)
        
        # Generate brand (Bernoulli = binary choice)
        VOLVO = rand(Bernoulli(share_volvo))
        VOLVO = UInt8(VOLVO)

        SAAB = 1 - VOLVO
        
        # Generate fuel type (three categories)
        fuel_rand = rand(Uniform(0,1))
        if fuel_rand < share_petrol
            PETROL = 1
            DIESEL = 0
            ELECTRIC = 0
        elseif fuel_rand < share_petrol + share_diesel
            PETROL = 0
            DIESEL = 1
            ELECTRIC = 0
        else
            PETROL = 0
            DIESEL = 0
            ELECTRIC = 1
        end

        price = (50000                                   # Base price
                - 1500 * age                             # -1500/year depreciation
                - 30 * age^2                             # Accelerating depreciation
                - 0.05 * mileage                         # -0.05 per km
                - 5000 * SAAB             # SAAB discount (less prestigious)
                + 8000 * DIESEL           # Diesel premium (until recently)
                + 15000 * ELECTRIC)       # Electric premium
        if price < 0
            price = 1000
        end
        # Create and return Vehicle
        return Vehicle(age, mileage, VOLVO, SAAB, PETROL, DIESEL, ELECTRIC, price, UInt(1))
    else
        return Vehicle(0, 0, 0, 0, 0, 0, 0, 0, UInt(0))
    end
end

function compute_base_u(hh::Household)
    v_1, v_2 = hh.portfolio
    u = hh.utility(v_1,v_2,v_1.price,v_2.price)
    return u
end