[Nomisma.org](http://nomisma.org) is a dataset of numismatic datasets. We provide them `voID.rdf`, which points to our RDF `princeton-nomisma.rdf` hosted here on GitHub.

[![Code style: black](https://img.shields.io/badge/code%20style-black-000000.svg)](https://github.com/psf/black)
[![Pipeline smoke test](https://github.com/pulibrary/nomisma/actions/workflows/run-pipeline.yaml/badge.svg)](https://github.com/pulibrary/nomisma/actions/workflows/run-pipeline.yaml)

## NomismaPipeline.py

`collect` paginates through items in the Catalog listed as "Coins" and places all raw JSON data into `data/raw`,

`preprocessing` grabs only the essential information from the raw coin JSON and transforms it into the fields that will ultimatley populate the RDF. It outputs a CSV, `coin-list.csv`.

`validate` runs tests on `coin-list.csv` to ensure that our assumptions about the data's schema are correct.

`generate_rdf` turns `coin-list.csv` into `princeton-nomisma.rdf`: the published data link.

## Quick run

Create a python 3.8 environment and install dependencies using the command `pip install -r requirements.txt`

`python NomismaPipeline.py --scrape` will execute the `run_pipeline` function, which will iterate through all steps outlined above. The scraping process is time-intensive, so dropping the `--scrape` flag will run the process with the raw data found locally. This is useful for debugging.

## Notes

- The location of `princeton-nomisma.rdf` should not be changed unless `voID.rdf` is updated and given to Nomisma.
- If `princeton-nomisma.rdf` is updated with new data, Nomisma should be contacted to run another ingestion. Preferably, do not contact them more than once every month.