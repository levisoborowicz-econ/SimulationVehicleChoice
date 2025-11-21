
# will need to add a condition for who actually enters the market
struct Market
    participants::Vector{Household}
    can_transact::Vector{Pair{Household,Household}}
    function Market(participants)
        can_transact = generate_pairs(participants)
        new(participants,can_transact)
    end

end

function generate_pairs(participants::Vector{Household})
    # declare tyes in vector to help the compiler
    can_transact = Vector{Pair{Household, Household}}()
    
    for i in 1:length(participants)
        for j in (i+1):length(participants)  # Only pairs where j > i
            push!(can_transact, Pair(participants[i], participants[j]))
        end
    end
    return can_transact
end


function potential_transaction(HH_1::Household,HH_2::Household)
    zero_car = Vehicle(0, 0, 0, 0, 0, 0, 0, 0, UInt(0))

    v_1_h1, v_2_h1 = HH_1.portfolio
    v_1_h2, v_2_h2 = HH_2.portfolio 

    base_u_h1 = HH_1.utility(v_1_h1, v_2_h1)
    base_u_h2 = HH_2.utility(v_1_h2, v_2_h2)

    # what transactions can they make?

    if HH_1.porfolio_size == 0 & HH_2.porfolio_size == 0
        return 0




    # if car 1 for household two is traded
    if v_1_h2.age > v_2_h1.age
        t1_u_h1 = HH_1.utility(v_1_h2, v_2_h1)
    else 
        t1_u_h1 = HH_1.utility(v_2_h1, v_1_h2)
    end

    if v_1_h2.age > v_2_h1.age
        t1_u_h1 = HH_1.utility(v_1_h2, v_2_h1)
    else 
        t1_u_h1 = HH_1.utility(v_2_h1, v_1_h2)
    end
    if v_1_h2.age > v_2_h1.age
        t1_u_h1 = HH_1.utility(v_1_h2, v_2_h1)
    else 
        t1_u_h1 = HH_1.utility(v_2_h1, v_1_h2)
    end
    if v_1_h2.age > v_2_h1.age
        t1_u_h1 = HH_1.utility(v_1_h2, v_2_h1)
    else 
        t1_u_h1 = HH_1.utility(v_2_h1, v_1_h2)
    end
end