# Anders Ohman
# Assignment 10
#
# Write a Julia program called netid_asg10.jl where netid is your Brown username (e.g., bcbi_asg10.jl) that:
# Reads each line in the input data file (brfss2016_ri.txt)

data_file = open("brfss2016_ri.txt","r")
output_file_one = open("aohman_asg10_output.txt", "w")
output_file_two = open("aohman_asg10_output2.txt", "w")
health_dict = Dict("1" => "Excellent", "2" => "Very good", "3" => "Good", "4" => "Fair", "5" => "Poor", "7" => "Don’t know/Not Sure", "9" => "Refused")
health_count = Dict()

line_count = 0
for line in readlines(data_file)
    line_count += 1 # equivalent to ++
    if line_count == 1
        continue
    end
    if isempty(line)
        continue
    end

# Gets the value for “General Health” (character 90) and converts it to the corresponding value label
# Notes: Treat each line as a string of characters rather than a set of fields that needs to be split into an array.
#   You can use the string() function to convert a single character (e.g., ‘1’) to a string (e.g., “1”).

    general_health = string(line[90])

# Keeps track of the number of times each value label for “General Health” occurs
# Prints out the line number and “General Health” value label into an output file called netid_asg10_output.jl
# Format: 	line_number|general_health

    if haskey(health_count, general_health)
        health_count[general_health] += 1
        condition = health_dict[general_health]
        println("$line_count|$condition")
        write(output_file_one, "$line_count|$condition\n")
    else
        health_count[general_health] = 1
    end
end
# Prints out the total number of lines in the input file

println("\nTotal line count: $line_count\n")

# Prints out the frequency of each value label for “General Health” into another output file called netid_asg10_output2.jl

for general_health in sort(collect(keys(health_count)))
    println("$(health_dict[general_health]) = $(health_count[general_health])")
    write(output_file_two, "$(health_dict[general_health]) = $(health_count[general_health])\n")
end

close(data_file)
close(output_file_one)
close(output_file_two)
