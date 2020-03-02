#   Anders Ohman
#   Assignment 9
#

term_dict = Dict("diagnosis" => "dx", "history" => "hx", "treatment" => "tx")
println("This script will simplify dx/hx/tx terms.")
println("Please enter the title of a PubMed article:")
title = readline(STDIN)

while title != "qqq"
    title_words_array = split(title, " ")
    new_title_array = []
    for word in title_words_array
        if haskey(term_dict, lowercase(word))
            push!(new_title_array, term_dict[lowercase(word)])
        else
            push!(new_title_array, word)
        end
    end
    println("The new title is:")
    println("> $(join(new_title_array, " "))")
    println("Please enter another title:")
    title = readline(STDIN)
end
println("Goodbye!")
