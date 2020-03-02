#   Anders Ohman
#   Assignment 9
#
num_dict = Dict("zero" => "0", "one" => "1", "two" => "2", "three" => "3", "four" => "4", "five" => "5", "six" => "6", "seven" => "7", "eight" => "8", "nine" => "9")
term_dict = Dict("diagnosis" => "dx", "history" => "hx", "treatment" => "tx")
println("This script will:")
println("* find the number of words in the title")
println("* determine if the word starts with a letter or number")
println("* determine if the word ends with a period")
println("* simplify dx/hx/tx terms")
println("* simplify numbers")
println("Please enter the title of a PubMed article:")
title = readline(STDIN)

while title != "qqq"
    title_words_array = split(title, " ")
    new_title_array = []

    println("\nThat title has a total of $(length(title_words_array)) words and $(length(unique(title_words_array))) unique words.")

    for word in title_words_array
        if ismatch(r"^[.a-zA-Z]", word)
            println("\"$word\" starts with a letter.")
        elseif ismatch(r"^[.\d]", word)
            println("\"$word\" starts with a number.")
        end
        if ismatch(r"[\.$]", word)
            println("\"$word\" ends with a period.")
        end

        if haskey(num_dict, word) #can use command lowercase(word) to simplify dictionary
            translation = num_dict[word]
            println("\"$word\" is the number $translation.")
            word = translation
        end

        if haskey(term_dict, lowercase(word))
            push!(new_title_array, term_dict[lowercase(word)])
        else
            push!(new_title_array, word)
        end
    end
    println("\nThe new title is:")
    println("> $(join(new_title_array, " "))\n")
    println("Please enter another title:")
    title = readline(STDIN)
end
println("Goodbye!")
