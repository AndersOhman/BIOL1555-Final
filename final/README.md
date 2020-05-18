## CancerGeneTrials.jl README
This is a final course project for Methods in Informatics and Data Science for Health (BIOL 1555), a course at Brown University in the Spring 2018 semester.

### Core Concept
The idea behind the project is to locate cancer-related clinical trials involving genes that may play a role in additional cancers, and identify that set to inform potential blindspots in existing therapies or those under investigation. It accomplishes this by gathering data from the NIH resource The Cancer Genome Atlas on a per-cancer basis, combines all individual cancers into a master list, and queries the NIH resource ClinicalTrials.gov for any trials matching that gene and any of the cancers. After this, it outputs potential interesting "misses" - that is, a list of cancers which are associated with a gene mutation that is under investigation in clinical trials for OTHER cancers.

Consists of the following core functions:
- 1.0: Initialization of files into their proper formats\
`function initialize_files()`
- 2.0: Searches ClinicalTrials for cancer/gene combinations, saves results as CSV\
`function search_trials(resume)`
- 3.0: Parses result table into more interesting data and outputs as text\
`function parse_results()`

And the following support functions:
- 0.1: Parse JSON file from TCGA for a gene type, save as CSV\
`function tcga_parse(cancer)`
- 0.2: Download results from ClinicalTrials.gov, parse XML into DataFrame/CSV\
`function clintrials_parse(gene, cancer, sleep_time)`

### Getting Started
Setup Instructions:
- Place script in a directory
- Create a subfolder called "json"
- Download the TCGA GDC Gene JSON files per cancer in the cancer_set
```{Julia}
"Adrenal_Gland","Bile_Duct","Bladder","Bone_Marrow","Brain",
"Breast","Cervix","Colorectal","Esophagus","Eye",
"Head_and_Neck","Kidney","Liver","Lung","Lymph_Nodes",
"Ovary","Pancreas","Pleura","Prostate","Skin","Soft_Tissue",
"Stomach","Testis","Thymus","Thyroid","Uterus"
```
- Rename to format `genes.$cancer.json`
- Run Initialize to prepare DataFrames and CSV files
- Run Search to begin querying ClinicalTrials
- Run Parse to process the data into a legible output
- Manually inspect and follow-up with interesting hits

### Dependencies
- Julia
- Developed and ran using both OS X 10.13 and Windows 10
- Internet access to connect to [TCGA](https://portal.gdc.cancer.gov/) and [ClinicalTrials.gov](https://clinicaltrials.gov/).

Julia Packages:
- [Requests](https://github.com/JuliaWeb/Requests.jl)
- [CSV](https://github.com/JuliaData/CSV.jl)
- [DataFrames](https://github.com/JuliaData/DataFrames.jl)
- [LightXML](https://github.com/JuliaIO/LightXML.jl)

### Known Bugs
If you encounter the error `(ECONNRESET)` when searching for trials, you are querying the ClinicalTrials site faster than it likes. I have a 1.5 second delay set currently after 1 second was insufficient, but still occasionally was disconnected. You can change the time when invoking
```{Julia}
clintrials_parse(gene, cancer, sleep_time)
```
Where sleep_time is the delay in seconds.

The CSV file `ClinTrialsResults.csv` is saved every row, which allows resuming from failed runs. This is accomplished by allowing the search function `search_trials(resume)` to be given a row to resume from. If your run failed on row 100, and that row is gene BRCA2, invoke `search_trials(100)` to start from that point.

On Windows 10, CSV handles reading and writing to the same file badly. I had to invoke the following flag in order to prevent an error when reading. (See bug report [here](https://github.com/JuliaData/CSV.jl/issues/170))
```{Julia}
gene_df = CSV.read("csv/GeneHits.csv"; use_mmap=false)
```
I also ran into an issue saving the results file to the `/csv/` subfolder, so in one case had to avoid doing so, and saved to the root directory instead.

### TODO
Next steps:
- Code cleanup and additional commenting
- More tidy data output and preparation for analysis (i.e. clean CSV output of tables, sorted by top hit)

Features planned:
- Preclinical test investigation via PubMed mesh terms

### Contact
Anders Ohman\
Doctoral Student, Brown University\
Pathobiology PhD Program\
anders_ohman@brown.edu
