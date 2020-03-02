#   Anders Ohman
#   Assignment 7
#   aohman_asg7.jl
#

# Asks user to enter the title of a study in ClinicalTrials.gov
println("Please enter the title of a study from ClincalTrials.gov: ")
response = readline(STDIN)

# Gets and prints the length of the title
response_length = length(response)
println("This title is $response_length characters long.")

# If the title is less than 75 characters long, prints out the first five characters
if response_length < 75
    print("The first 5 characters are: \"")
    print(response[1:5])
    print("\".\n")

# Otherwise, prints out the last five characters
else
    print("The last 5 characters are: \"")
    print(response[end-4:end])
    print("\".\n")
end

# Tells the user if the title includes any numbers
if ismatch(r"[0-9]", response)
    println("This title includes numbers.")
end

# Asks for another title and goes back to steps b-c until the user types “qqq”
while response != "qqq"
    println("Please enter another title, or \"qqq\" to quit: ")
    response = readline(STDIN)
    if response != "qqq"
        response_length = length(response)
        println("This title is $response_length characters long.")
        if response_length < 75
            print("The first 5 characters are: \"")
            print(response[1:5])
            print("\".\n")
        else
            print("The last 5 characters are: \"")
            print(response[end-4:end])
            print("\".\n")
        end
        if ismatch(r"[0-9]", response)
            println("This title includes numbers.")
        end
    end
end
println("Goodbye!")
