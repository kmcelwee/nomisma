[Nomisma.org](http://nomisma.org) is a dataset of numismatic datasets. We provide them `voID.rdf`, which points to our RDF `princeton-nomisma.rdf` hosted here on GitHub.

## Data Pipeline

`collect` paginates through items in Figgy listed as "Coins" and places all JSON data into one file, `coin-list-raw.json`

`trim` grabs only the essential information from the raw coin JSON and creates `coin-list-trimmed.csv`

`validate` drops any rows in `coin-list-trimmed.csv` that does not follow the schema we've defined. All correctly-formed rows are placed into `coin-list-clean.csv`.

`transform` turns all fields in `coin-list-clean.csv` into the fields that will ultimately populate the RDF. It outputs a CSV, `coin-list-rdf.csv`.

`generate_rdf` turns `coin-list-rdf.csv` into `princeton-nomisma.rdf`, the published data link.

## Quick run

`python NomismaPipeline.py` will execute the `run_pipeline` function, which will iterate through all four steps outlined in "Data Pipeline" above.

## Notes

- The location of `princeton-nomisma.rdf` should not be changed unless `voID.rdf` is updated and given to Nomisma.