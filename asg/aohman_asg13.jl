# Anders Ohman
# Assignment 13
#=
Gets Date Completed (“DCOM” element in MEDLINE format): https://www.nlm.nih.gov/bsd/mms/medlineelements.html#dcom

Converts Date Completed and Date Created to the same format. For example,
Element | Format | Example | New Format
DCOM | YYYYMMDD | 20151001 | October 01, 2015
CRDT | YYYY/MM/DD HH:MM | 2016/06/01 06:00 | June 01, 2016

Note: consider exploring use of existing Date modules for conversion:
https://docs.julialang.org/en/stable/manual/dates/
https://en.wikibooks.org/wiki/Introducing_Julia/Working_with_dates_and_times
=#
#

using Requests, StatsBase
#output_file_one = open("aohman_asg12_output.txt", "w")
#output_file_two = open("aohman_asg12_output2.txt", "w")
output_file_three = open("aohman_asg13.output.txt", "w")

#Runs EFetch for the PMIDs returned by ESearch for the following search term: "brown university"[ad] and "electronic health records"[mh]
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
fetch_result = readstring(post(base_fetch_query; data = Dict("db" => "pubmed", "id" => id_string, "rettype" => "medline", "retmode" => "text")))

#Reads each line from EFetch results in MEDLINE format
# Converts Date Completed and Date Created to the same format. For example:
# DCOM, CRDT
pmid_full = date_created_converted = date_completed_converted = ""
empty_flag = 0
println("--------|------------|------------")
println("PubMedID| Date Crea. | Date Comp. ")
println("--------|------------|------------")
write(output_file_three, "--------|------------|------------\nPubMedID| Date Crea. | Date Comp. \n--------|------------|------------\n")
for fetch_line in split(fetch_result, "\n") # check if empty line; skip first empty line,
	if isempty(fetch_line)
		if empty_flag == 0
			empty_flag = 1
		else
			# Otherwise: Reports output into a file called netid_asg13_output.txt
		    # Format: pmid|converted_date_completed|converted_date_created
		    # Example: 26422543|October 01, 2015|June 01, 2016
			# NOTE: The instructions have Completed/Created reversed in the Format text
			date_completed_converted = Dates.format(date_completed_converted, "u mm, yyyy")
			date_created_converted = Dates.format(date_created_converted, "u mm, yyyy")
			println("$pmid_full|$date_created_converted|$date_completed_converted")
			write(output_file_three, "$pmid_full|$date_created_converted|$date_completed_converted\n")
		end
	end

  # get pmid
  pmid = match(r"PMID- ([0-9]+)", fetch_line)
  if pmid != nothing
	  	#println("PMID: $pmid")
		pmid_full = pmid[1]
  end

  # get date created - year, month, day
  date_created = match(r"CRDT- (([0-9]{4})\/([0-9]{2})\/([0-9]{2}))", fetch_line)
  if date_created != nothing
	  	#println("CRDT Raw: $date_created")
		date_created_full = date_created[1]
		date_created_year = parse(Int64, date_created[2])
		date_created_month = parse(Int64, date_created[3])
		date_created_day = parse(Int64, date_created[4])
        date_created_converted = Dates.Date(date_created_year,date_created_month,date_created_day)
		#println("CRDT Conv: $date_created_converted")
	end

  # get date completed
  date_completed = match(r"DCOM- (\d+)", fetch_line)
  if date_completed != nothing
	  	#println("DCOM Raw: $date_completed")
		date_completed_full = date_completed[1]
		date_completed_year = match(r"(^\d{4})", date_completed_full)
		date_completed_month = match(r"^\d{4}(\d{2})", date_completed_full)
		date_completed_day = match(r"(\d{2}$)", date_completed_full)
        date_completed_converted = Dates.Date(parse(Int64, date_completed_year[1]),parse(Int64, date_completed_month[1]),parse(Int64,date_completed_day[1]))
		#println("DCOM Conv: $date_completed_converted")
  end
end

close(output_file_three)
