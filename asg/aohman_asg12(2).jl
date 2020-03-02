# Anders Ohman
# Assignment 12
#
#Write a Julia program called netid_asg12.jl where netid is your Brown username (e.g., bcbi_asg12.jl) that:

using Requests, StatsBase
output_file_one = open("aohman_asg12_output.txt", "w")
output_file_two = open("aohman_asg12_output2.txt", "w")

#Runs EFetch for the PMIDs returned by ESearch for the following search term:
# "brown university"[ad] and "electronic health records"[mh]
base_search_query = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi"
query_term = "\"brown university\"[ad] and \"electronic health records\"[mh]"
search_result = post(base_search_query; data = Dict("db" => "pubmed", "term" => "$(query_term)", "retmax" => 1000))
pmid_set = Set()
for result_line in split(readstring(search_result), "\n")
    pmid = match(r"<Id>(\d+)<\/Id>", result_line)
    if pmid != nothing
        push!(pmid_set, pmid[1])
    end
end
id_string = join(collect(pmid_set), ",")
base_fetch_query = "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi"
fetch_result = post(base_fetch_query; data = Dict("db" => "pubmed", "id" => id_string, "rettype" => "medline", "retmode" => "text"))

#Reads each line from EFetch results in MEDLINE format and gets
# PubMed Unique Identifier (“PMID” element in MEDLINE format)
# Date Created (“DA” element in MEDLINE format)
# MeSH Date (“MHDA” element in MEDLINE format)

pmid_array = []
date_array = []
mesh_array = []

for fetch_line in split(readstring(fetch_result), "\n")
    pmid = match(r"PMID- (\d+)", fetch_line)
    if pmid != nothing
        #println("PMID: $(pmid[1])")
        push!(pmid_array, pmid[1])
    end
end
for fetch_line in split(readstring(fetch_result), "\n")
    date_created = match(r"DA- (\d+)", fetch_line)
    if date_created != nothing
        #println("Date Created: $(date_created[1])")
        push!(date_array, date_created[1])
    end
end
for fetch_line in split(readstring(fetch_result), "\n")
    mesh_date = match(r"MHDA- (\d{4}/\d{2}/\d{2})", fetch_line)
    if mesh_date != nothing
        #println("MeSH date: $(mesh_date[1])")
        push!(mesh_array, mesh_date[1])
    end
end

#Reports output into a file called netid_asg12_output.txt where netid is your Brown username (e.g., bcbi_asg12_output.txt).
# Format: 	pmid|date_created|mesh_date
# Examples:	26422543|20151001|2016/06/01

# NOTE: I know this is dumb.
# I was only able to get a "for" implementaiton to return the last line for some reason
i = 1
while i <= length(pmid_array)
    println("$(pmid_array[i])|$(date_array[i])|$(mesh_array[i])")
    write(output_file_one, "$(pmid_array[i])|$(date_array[i])|$(mesh_array[i])\n")
    i += 1
end

#Summarizes the number of articles per year based on Date Created and prints the output into another file called netid_asg12_output2.txt
    summary = countmap(date_array) #NOTE: This requires StatsBase package
    for k in sort(collect(keys(summary)))
        println("Articles in $k: $(summary[k]).")
        write(output_file_two, "Articles in $k: $(summary[k]).")
    end

close(output_file_one)
close(output_file_two)
