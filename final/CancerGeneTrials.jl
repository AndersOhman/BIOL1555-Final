#===============================================================================
# Program:                  CancerGeneTrials.jl
# Purpose:                  To investigate potentially already-extant therapies
#                               for one cancer that could work in another based
#                               on having a common genetic target.
# Description:             Parses JSON files from TCGA for a list of genes per
#                               cancer, and then searches ClinicalTrials.gov
#                               for matches for both terms. Tabulates responses,
#                               with a focus on those genes that have trials,
#                               but omit one or multiple cancers.
# Created by: 				Anders Ohman (anders_ohman@brown.edu)
# Created for:              Methods in Biomedical Informatics (BIOL 1555)
#                               at Brown University
# Created on:               2018-05-15 (Spring 2018 Semester)
==============================================================================#

# Libraries
using Requests, CSV, DataFrames, LightXML
import JSON

println("*Welcome to the Cancer Gene Trial Search.*")
# Skip to line 282 to bypass functions and definitions

# Cancer Set under investigation (with TCGA data)
cancer_set = Set(["Adrenal_Gland","Bile_Duct","Bladder",
"Bone_Marrow","Brain","Breast","Cervix","Colorectal","Esophagus",
"Eye","Head_and_Neck","Kidney","Liver","Lung","Lymph_Nodes",
"Ovary","Pancreas","Pleura","Prostate","Skin",
"Soft_Tissue","Stomach","Testis","Thymus","Thyroid","Uterus"])

# Dictionary to translate spaces into underscores for file writing and frames
cancer_dict = Dict(["Adrenal_Gland"=>"Adrenal Gland","Bile_Duct"=>"Bile Duct",
"Bladder"=>"Bladder","Bone_Marrow"=>"Bone Marrow","Brain"=>"Brain","Breast"=>"Breast","Cervix"=>"Cervix","Colorectal"=>"Colorectal","Esophagus"=>"Esophagus",
"Eye"=>"Eye","Head_and_Neck"=>"Head and Neck","Kidney"=>"Kidney","Liver"=>"Liver","Lung"=>"Lung","Lymph_Nodes"=>"Lymph Nodes",
"Ovary"=>"Ovary","Pancreas"=>"Pancreas","Pleura"=>"Pleura","Prostate"=>"Prostate","Skin"=>"Skin",
"Soft_Tissue"=>"Soft Tissue","Stomach"=>"Stomach","Testis"=>"Testis","Thymus"=>"Thymus","Thyroid"=>"Thyroid","Uterus"=>"Uterus"])

# Another dictionary to translate underscores into plus signs for ClinicalTrials searching format
cancer_dict2 = Dict(["Adrenal_Gland"=>"Adrenal+Gland","Bile_Duct"=>"Bile+Duct","Bladder"=>"Bladder",
"Bone_Marrow"=>"Bone+Marrow","Brain"=>"Brain","Breast"=>"Breast","Cervix"=>"Cervix","Colorectal"=>"Colorectal","Esophagus"=>"Esophagus",
"Eye"=>"Eye","Head_and_Neck"=>"Head+and+Neck","Kidney"=>"Kidney","Liver"=>"Liver","Lung"=>"Lung","Lymph_Nodes"=>"Lymph+Nodes",
"Ovary"=>"Ovary","Pancreas"=>"Pancreas","Pleura"=>"Pleura","Prostate"=>"Prostate","Skin"=>"Skin",
"Soft_Tissue"=>"Soft+Tissue","Stomach"=>"Stomach","Testis"=>"Testis","Thymus"=>"Thymus","Thyroid"=>"Thyroid","Uterus"=>"Uterus"])

# Function 0.1: Parse JSON file from TCGA for a gene type, save as CSV
total_gene_set = Set() # Declare set for storing master list of genes between function runs
function tcga_parse(cancer)
    println("Converting $(cancer_dict[cancer]) from JSON to CSV...")

    # Initialize gene symbol set and open JSON file
    filename = "json/genes.$cancer.json" # NOTE: These need to be manually saved currently
    symbol_set = Set()

    # Look for symbol row of file
    cancer_file = open("$filename", "r")
    for line in eachline(cancer_file)
        # JSON.parse(readstring(search_result)) # NOTE: Look into JSON implementaiton
        # NOTE: for reference, regular_exp = "\"symbol\": \"(.+)\","
        symbol_match = match(r"\"symbol\": \"(.+)\",", line)
        if symbol_match != nothing
            #println("$line")
            push!(symbol_set, symbol_match[1])
            push!(total_gene_set, symbol_match[1])
        end
    end
    close(cancer_file)

    # Create DataFrame export CSV file
    df = DataFrame(v1 = [], v2 = [])
    new_names = ["Gene", "$cancer"]
    names!(df.colindex, map(parse, new_names))
    for item in symbol_set
        #println("$item")
        push!(df, [item, true])
    end
    CSV.write("csv/$cancer.csv", df)
end

# Function 0.2: Download results from ClinicalTrials.gov, parse XML into DataFrame/CSV
function clintrials_parse(gene, cancer, sleep_time)
    format = "xml"
    cancer_name = cancer_dict[cancer]
    #println("Searching CT.g for gene $gene and $cancer_name cancer.")
    cancer_plus = cancer_dict2[cancer] # To ensure proper search format
    if typeof(sleep_time) != Float64
        sleep_time = parse(Float64, sleep_time) #1.5
    end
    sleep(sleep_time) # To prevent disconnection errors
    search_url = "https://clinicaltrials.gov/ct2/results/download_fields?cond=$cancer_plus+cancer&term=$gene&down_count=10000&down_fmt=$format&down_chunk=1"
    r = get(search_url)
    save(r, "xml/$cancer-$gene.xml") # NOTE: Can consider deleting these after
    xdoc = parse_file("xml/$cancer-$gene.xml")
    xroot = root(xdoc)
    search_results = parse(Int64, attribute(xroot, "count"))
    #println("ClinicalTrials Results for $gene and $cancer: $search_results.")
    return search_results
end

# Function 1.0: Initialization of files into their proper formats
function initialize_files()
    # Convert all gene JSON files to gene symbol CSVs
    println("*Converting TCGA Cancer Gene JSON files to CSVs.*")
    for cancer in cancer_set
        tcga_parse(cancer) # Loops through function 0.1
    end

    # Create master DataFrame of genes
    println("*Creating master Gene file.*")
    joined_df = DataFrame(Gene = [])
    for gene in total_gene_set
        push!(joined_df, [gene])
        # Add row to Gene column with $gene
        CSV.write("csv/Genes.csv", joined_df)
    end

    println("Gene list file:")
    println(joined_df)

    joined_df = CSV.read("csv/Genes.csv")

    # Join dataframe columns to gene dataframe
    println("*Joining all DataFrames to Genes.*")
    for cancer in cancer_set
        println("Joining $cancer")
        csv_df = CSV.read("csv/$cancer.csv")
        #println(csv_df)
        joined_df = join(joined_df, csv_df, on = :Gene, kind = :left)
    end
    CSV.write("csv/Joined.csv", joined_df)

    joined_df = CSV.read("csv/Joined.csv")

    # Replate all missing values with false
    for (_, col) in eachcol(joined_df)
        col[ismissing.(col)] = false
    end
    CSV.write("csv/GeneHits.csv", joined_df)

    println("Joined list file:")
    println(joined_df)

    # Duplicate table for CinTrials, mark all false to start
    hits_df = CSV.read("csv/GeneHits.csv")
    for cancer in cancer_set
        hits_df[Symbol(cancer)] = recode(hits_df[Symbol(cancer)], true=>false)
        hits_df[Symbol(cancer)] = recode(hits_df[Symbol(cancer)], false=>0)
    end
    #println(hits_df)
    CSV.write("csv/ClinTrialsHits.csv", hits_df)
end

# Function 2.0: Searches ClinicalTrials for cancer/gene combinations, saves results as CSV
function search_trials(resume)
    main_df = CSV.read("csv/GeneHits.csv"; use_mmap=false)
    clin_hits_df = CSV.read("csv/ClinTrialsHits.csv"; use_mmap=false)
    #println(clin_hits_df)
    resume_point = parse(Int64, resume) #4988
    row_num = 1
    for row in eachrow(main_df)
        if row_num > resume_point # to resome from ECONNRESET error
            println("Gene $(row[:Gene]): ")
            for cancer in cancer_set
                    if row[Symbol(cancer)] == true
                        result = clintrials_parse(row[:Gene], cancer, 1.5)
                        if result > 0
                            clin_hits_df[row_num, [Symbol(cancer)]] = result
                            print("$(cancer_dict[cancer]) ")
                            print(" ($result) \n")
                        end
                    #else
                    #    println("$cancer FALSE")
                    end
            end
        else
            print("Row $row_num.")
        end
        print("\n")
        row_num += 1
        CSV.write("csv/ClinTrialsHits.csv", clin_hits_df)
    end
    #println(clin_hits_df)
    CSV.write("csv/ClinTrialsHits.csv", clin_hits_df)
end

# Function 3.0: Parses result table into more interesting data and outputs as text
function parse_results()
    results_output_file = open("CancerGeneTrials_results.txt", "w")
    gene_df = CSV.read("csv/GeneHits.csv"; use_mmap=false)
    #results_df = CSV.read("ClinTrialsResults.csv"; use_mmap=false) #NOTE: manually renamed here
    results_df = CSV.read("csv/ClinTrialsHits.csv"; use_mmap=false)
    row_num = 1
    #println(results_df)
    gene_total_dict = Dict()
    cancer_hits_dict = Dict()
    cancer_miss_dict = Dict()
    genes_most_missed = Dict()
    for cancer in cancer_set
        cancer_hits_dict[cancer] = 0
        cancer_miss_dict[cancer] = 0
    end

    for row in eachrow(results_df)
        definite_array = []
        possible_array = []
        sum = 0
        for cancer in cancer_set
            cell = Array(results_df[row_num, [Symbol(cancer)]])
            #println(cell[1])
            sum += cell[1]
            if sum > 0
                push!(definite_array, cancer_dict[cancer])
                gene_total_dict[row[:Gene]] = sum #Set value to sum, # of trials
                cancer_hits_dict[cancer] += 1
            end
        end
        if sum > 0 # row has sum > 0
            for cancer in cancer_set
                cell = Array(gene_df[row_num, [Symbol(cancer)]])
                if cell[1] == true && (cancer_dict[cancer] in definite_array) == false
                    push!(possible_array, cancer_dict[cancer])
                    cancer_miss_dict[cancer] += 1
                end
            end

            if length(possible_array) > 0
                if length(definite_array) > 0
                    print("Gene $(row[:Gene]) ")
                    print("has $sum ClinicalTrials.gov hits ")
                    #print("in the following cancers: $definite_array")
                    print("\n")
                    write(results_output_file, "$(row[:Gene]) has $sum CT.g hits \n")
                #else
                #    println("No clinical trials were found for this gene.")
                end
                if length(possible_array) > 0
                    print("And may also be a target for: ")
                    print(join(map(string, possible_array), ", "))
                    print("\n\n")
                    genes_most_missed[row[:Gene]] = length(possible_array)
                    write(results_output_file, "and may also be a target for: $(join(map(string, possible_array), ", "))\n")
                #else
                #    println("No additional cancers found.")
                #    print("\n")
                end
            end
        #else
            #println("No hits for gene $(row[:Gene]).")
        end
        row_num += 1
    end

    # Quasi-Visualization and Data Table Output
    println("Top Gene CT.g Hits:")
    write(results_output_file, "\nTop Gene CT.g Hits:\n")
    for key in sort(collect(keys(gene_total_dict)))
    #for key in sort(collect(values(gene_total_dict)))
        println("* $key : $(gene_total_dict[key])")
        write(results_output_file, "$key,$(gene_total_dict[key])\n")
    end
    println("\nTop Cancer CT.g Hits:")
    write(results_output_file, "\nTop Cancer CT.g Hits:\n")
    for key in sort(collect(keys(cancer_hits_dict)))
        println("* $key : $(cancer_hits_dict[key])")
        write(results_output_file, "$key,$(cancer_hits_dict[key])\n")
    end
    println("\nTop Cancer CT.g Misses:")
    write(results_output_file, "\nTop Cancer CT.g Misses:\n")
    for key in sort(collect(keys(cancer_miss_dict)))
        println("* $key : $(cancer_miss_dict[key])")
        write(results_output_file, "$key,$(cancer_miss_dict[key])\n")
    end

    println("\nGenes with the most Misses:")
    write(results_output_file, "\nGenes with the most Misses:\n")
    for key in sort(collect(keys(genes_most_missed)))
        println("* $key : $(genes_most_missed[key])")
        write(results_output_file, "$key,$(genes_most_missed[key])\n")
    end
    close(results_output_file)
end

# Main Program Run with user input
println("What operation do you want to perform?")
print("(Initialize, Search, Parse): ")
response = readline(STDIN)
if response == "Initialize"
    initialize_files()
elseif response == "Search"
    print("Resume from row # (0 if none): ")
    resume = readline(STDIN)
    search_trials(resume)
elseif response == "Parse"
    parse_results()
else
    println("Not a valid command. Please try again.")
end
