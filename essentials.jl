__precompile__()

module essentials
#I don't really want to export pop_wand, but I don't know how else I could bring it into global scope
export log_calculator, convertInt, pop_wand, @rand!

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

macro rand!(r)
    return esc(quote
        l = length($(r))
        wanted = rand(1:l)
        ret = $(r)[wanted]
        out = pop_wand($(r), wanted)
        $(r) = out
        ret
    end)
end

macro rand!(r, d)
    return esc(quote
        t = typeof($(r)[1])
        ret = Array{t}(undef, $(d))
        for i in 1:$(d)
            println("asd")
            l = length($(r))
            println("qwe")
            wanted = rand(1:l)
            ret[i] = $(r)[wanted]
            $(r) = pop_wand($(r), wanted)
        end
        ret
    end)
    #=varName = r
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
    end)=#
end

end
