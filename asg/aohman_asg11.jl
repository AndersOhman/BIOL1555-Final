# Anders Ohman
# Assignment 11
#
#=
Expand the Julia program from Assignment 10 and call it [netid]_asg11.jl, where [netid] is your Brown username (e.g., bcbi_asg11.jl) that:

Gets the value for weight (characters 178-181). For details on the field  refer to page 41 in the 2016 BRFSS Codebook
* 50 - 0999: Weight (pounds) Notes: 0 _ _ _ = weight in pounds
* 7777: Don’t know/Not sure
* 9000 - 9998: Weight (kilograms) Notes: The initial  ́9 ́ indicates this was a metric value.
* 9999: Refused
* BLANK: Not asked or Missing

Tabulate and report to an output file how many weights are:
In imperial units (pounds);
In metric units (kilograms);
Not reported (either “Don’t Know/Not Sure”, “Refused”, or Blank

Submit the Julia program and output text file (as file attachments) through Google Classroom (by clicking “Add” in the Assignment Submission)
=#

data_file = open("brfss2016_ri.txt","r")
#output_file_one = open("aohman_asg10_output.txt", "w")
#output_file_two = open("aohman_asg10_output2.txt", "w")
output_file_three = open("aohman_asg11_output.txt", "w")
#health_dict = Dict("1" => "Excellent", "2" => "Very good", "3" => "Good", "4" => "Fair", "5" => "Poor", "7" => "Don’t know/Not Sure", "9" => "Refused", " " => "Blank")
#health_count = Dict()

weight_count = Dict("Not Reported"=>0,"Pounds"=>0, "Kilograms"=>0)

line_count = 0
for line in readlines(data_file)
    line_count += 1

#    general_health = string(line[90])

    # NOTE: I set about doing this using a Dict() system as done before
    # However, I was unable to find a good way to get a dictionary key to be a range of integers
    # I explored putting in weight_dict = Dict(0:999) and similar variants but these did not work
    # Julia documentation says that dictionaries are 1-to-1 so this may not be possible
    # I therefore did it using simple if/else commands after a while of attemping to get it to work as a dictionary

    weight = line[178:181]
    print("Weight is: ")
    if weight == "    "
        print("Missing")
        weight_count["Not Reported"] += 1
    elseif parse(Int64, weight) == 7777
        print("Unsure")
        weight_count["Not Reported"] += 1
    elseif parse(Int64, weight) == 9999
        print("Refused")
        weight_count["Not Reported"] += 1
    elseif parse(Int64, weight) <= 999
        weight = parse(Int64, weight)
        print("$weight lbs")
        weight_count["Pounds"] += 1
    elseif 9000 <= parse(Int64, weight) <= 9998
        weight = parse(Int64, weight)
        weight -= 9000
        print("$weight kg")
        weight_count["Kilograms"] += 1
    end
    print(".\n")

#= NOTE: Blocked out from Assignment 10
    if haskey(health_count, general_health)
        health_count[general_health] += 1
        condition = health_dict[general_health]
        println("$line_count|$condition")
        write(output_file_one, "$line_count|$condition\n")
    else
        health_count[general_health] = 1
    end
=#

end
println("\nTotal line count: $line_count\n")

#= NOTE: Blocked out from Assignment 10
for general_health in sort(collect(keys(health_count)))
    println("$(health_dict[general_health]) = $(health_count[general_health])")
    write(output_file_two, "$(health_dict[general_health]) = $(health_count[general_health])\n")
end
=#

println("Weights are reported as:")
for key in sort(collect(keys(weight_count)))
    println("* $key : $(weight_count[key])")
    write(output_file_three, "* $key : $(weight_count[key])\n")
end

close(data_file)
#close(output_file_one)
#close(output_file_two)
close(output_file_three)
