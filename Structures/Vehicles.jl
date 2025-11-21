using Random, Distributions

## Vehicle Object ##
struct Vehicle
    age::UInt8
    mileage::UInt64
    VOLVO::UInt8
    SAAB::UInt8
    PETROL::UInt8
    DIESEL::UInt8
    ELECTRIC::UInt8
    price::Float64
    ISVEH::UInt8
end

struct Manufacturer
    cost::Float64
    products::Matrix{Int8}
end

