#   Anders Ohman
#   Assignment 5
#   aohman_asg5.jl
# BMI = ((weight in pounds) / (height in inches) x (height in inches)) x 703
# NOTE: This provided formula has incorrect PEMDAS.
# Should be: (weight/(height*height)) * 703

println("Welcome to the BMI Calculator.")
# Query user
print("Please provide your weight in pounds: ")
weight = parse(Float64, readline(STDIN))
print("Please provide your height in inches: ")
height = parse(Float64, readline(STDIN))
# Performs BMI calculation
bmi = (weight / (height * height)) * 703
println("BMI: $bmi")

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
