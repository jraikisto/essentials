__precompile__()

module essentials

export log_calculator, convertInt, @rand!

function log_calculator(purity; ploidy=2)
    print("Expected logratios:")
    for i in 1:5
        print("$i")
        print("  ")
        res  = log2( (1 - purity) + purity * (i) / ploidy )
        println("$(res)")
    end
end

function convertInt(vec::AbstractArray)
    bits = length(vec)
    f = [2^(x) for x in bits-1:-1:0]
    sum(f[vec])
end

macro rand!(r)
    varName = r

    println(r)
    r = eval(r)
    local l = length(r)
    local wanted = rand(1:l)
    local ret = r[wanted]
    if wanted == 1
        out = r[2:end]
    elseif wanted == l
        out = r[1:end-1]
    else
        out = vcat(r[1:wanted-1], r[wanted+1:end])
    end
    return esc(quote
        $(varName) = $(out)
        $(ret)
    end)
end
function pop_wand(r, wanted)
    if wanted == 1
        out = r[2:end]
    elseif wanted == length(r)
        out = r[1:end-1]
    else
        out = vcat(r[1:wanted-1], r[wanted+1:end])
    end
    out
end

macro rand!(r, d)
    varName = r
    r = eval(r)
    d = eval(d)
    t = typeof(r[1])
    ret = Array{t}(undef, d)
    for i in 1:d
        l = length(r)
        wanted = rand(1:l)
        ret[i] = r[wanted]
        r = pop_wand(r, wanted)
    end
    out = r
    return esc(quote
        $(varName) = $(out)
        $(ret)
    end)
end

end
