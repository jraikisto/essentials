__precompile__()

module essentials
#I don't really want to export pop_wand, but I don't know how else I could bring it into global scope
export log_calculator, convertInt, pop_wand, readdlm
export @rand!

using DelimitedFiles

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
#I wouldnt want to do all the computing inside quotes, but I couldnt find a way to bring variables into the scope

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
            global $(r)
            l = length($(r))
            wanted = rand(1:l)
            ret[i] = $(r)[wanted]
            $(r) = pop_wand($(r), wanted)
        end
        ret
    end)
end

function readdlm(path::String; parse=true)
    if parse
        DelimitedFiles.readdlm(path)
    else
        r = readlines(path)
        out = fill("", length(r), length(split(r[1], "\t")))
        for i in 1:length(r)
            s = split(r[i], "\t")
            @assert length(s) == size(out, 2) "All the rows must have equal amuount of columns"
            out[i, :] = s
        end
        out
    end
end

end
