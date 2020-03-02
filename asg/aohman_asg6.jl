#   Anders Ohman
#   Assignment 6
#   aohman_asg6.jl
#

println("Welcome to the BMI Calculator.")
# Query user
print("Please provide your weight in pounds: ")
weight = parse(Float64, readline(STDIN))

print("Do you want to give your weight in FEET or INCHES? ")
response = chomp(readline(STDIN))
#TA comment: You need to add the chomp() function to cut the \n character in the end of the input.

if response == "INCHES"
    # Old standard code
    print("Please provide your height in inches: ")
    height = parse(Float64, readline(STDIN))
elseif response == "FEET"
    # Natural input conversion from feet and inches
    print("Please provide your height in feet and inches (i.e. 5\'10\"): ")
    input = readline(STDIN)
    input = split(input, r"\"|\'")
    feet = parse(Int, input[1])
    feetInInches = feet * 12
    inches = parse(Int, input[2])
    height = feetInInches + inches
end

# Performs BMI calculation
bmi = (weight / (height * height)) * 703
#println("BMI: $bmi")
@printf("\nBMI: %2.f\n", bmi)
# NOTE: Why doesn't this seem to work for me in truncating decimals?

if bmi >= 40
    println("Extreme or high risk obesity")
elseif bmi >= 30 # Don't need an && due to elseif condition
    println("Obese")
elseif bmi >= 25
    println("Overweight")
elseif bmi >= 18.5
    println("Normal")
elseif bmi < 18.5
    println("Underweight")
end

#if 30.0 <= bmi <= 34.9 #Nice, this works too
if bmi >= 30.0 && bmi < 40
print("You have a ")
    if bmi >= 30.0 && bmi <= 34.9
        print("LOW")
    elseif bmi >= 35.0 && bmi <= 39.9
        print("MODERATE")
    end
print(" level of risk.\n\n")
println("People with obesity have a higher chance of developing these health problems:")
println("* High blood glucose or diabetes.
* High blood pressure.
* High blood cholesterol.
* Heart attack and stroke.
* Bone and joint problems.
* Sleep apnea.
* Gallstones and liver problems.
* Some cancers.")
end
