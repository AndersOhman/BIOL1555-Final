#   Anders Ohman
#   Assignment 8
#
# Asks user to enter the title for a PubMed article

println("Please enter the title of a PubMed article:")
title = readline(STDIN)
while (title != "qqq")

# Prints the number of words in the title
title_words = split(title, " ")
print("That title has a total of $(length(title_words)) words ")

# Prints the number of unique words in the title
title_set = Set()
for word in title_words
    push!(title_set, word)
end
print("and $(length(title_set)) unique words.\n")

# Checks each word and indicates if it
# Starts with a letter
for word in title_set
    if ismatch(r"^[.a-zA-Z]", word)
        println("The word \"$word\" starts with a letter.")
# Starts with a number
    elseif ismatch(r"^[.\d]", word)
        println("The word \"$word\" starts with a number.")
    end
# Ends with a ‘.’
    if ismatch(r"[\.$]", word)
        println("The word \"$word\" ends with a period.")
    end
end

# Checks each word to see if it is a number word that is less than ten and prints its conversion to a digit
#(e.g., “one” to “1” and “five” to “5”) [Note: use a dictionary for this]
number_dict = Dict()
number_dict["one"] = 1; number_dict["One"] = 1; number_dict["ONE"] = 1
number_dict["two"] = 2; number_dict["Two"] = 2; number_dict["TWO"] = 2
number_dict["three"] = 3; number_dict["Three"] = 3; number_dict["THREE"] = 3
number_dict["four"] = 4; number_dict["Four"] = 4; number_dict["FOUR"] = 4
number_dict["five"] = 5; number_dict["Five"] = 5; number_dict["FIVE"] = 5
number_dict["six"] = 6; number_dict["Six"] = 6; number_dict["SIX"] = 6
number_dict["seven"] = 7; number_dict["Seven"] = 7; number_dict["SEVEN"] = 7
number_dict["eight"] = 8; number_dict["Eight"] = 8; number_dict["EIGHT"] = 8
number_dict["nine"] = 9; number_dict["Nine"] = 9; number_dict["NINE"] = 9

for word in title_set
    if haskey(number_dict, word)
        translation = number_dict[word]
        println("FYI: The word \"$word\" is the number $translation.")
    end
end

# Asks for another title and goes back to steps b-e until the user types “qqq”
println("Please enter another title:")
title = readline(STDIN)
end
println("Goodbye!")
