__precompile__()

module essentials
#I don't really want to export pop_wand, but I don't know how else I could bring it into global scope
export log_calculator, convertInt, pop_wand, readdlm, cbs
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
        io = open(path, "r")
        lines = countlines(open(path))
        l1 = readline(io)
        col1 = split(l1, r"\t")
        c = length(col1)
        out = fill("", lines, c)
        out[1, :] = col1
        row = 2
        while !eof(io)
            line = readline(io)
            s = split(line, r"\t")
            @assert length(s) == size(out, 2) "All the rows must have equal amuount of columns"
            out[row, :] = s
            row += 1
        end
        out
    end
end

function cbs(u, g, j)
	z = []
	n = length(u[g:j])
	sn = sum(u[g:end])
	sj = sum(u[g:j])
	if g >= j
		error("There seems to be too much variation in copynumber. Are you sure your threshold is not too small?")
	end
	for i in g:j
		s = sum(u[1:i])
		first = ((1/(j-i)) + (1/(n-j+i)))
		first = 1/sqrt(first)
		second = ((sj-s)/(j-i)) - ((sn-sj+s)/(n-j+i))

		if isnan(abs(first*second))
			push!(z, 0)
			continue
		end
		push!(z, abs(first*second))
	end
	return findmax(z)[2] + g
end

end
