import json
import requests
import os
from os.path import join as pjoin

import pandas as pd

class NomismaPipeline(object):
    """Extracts data from figgy, validates that it meets our required schema, 
    and generates an RDF that follows Nomisma's guidelines.
    """
    def __init__(self, data_dir='data'):
        self.data_dir = data_dir
        self.raw = pjoin(data_dir, 'coin-list-raw.json')
        self.trimmed = pjoin(data_dir, 'coin-list-trimmed.csv')
        self.rdf_prep = pjoin(data_dir, 'coin-list-rdf.csv')
        self.rdf = 'princeton-nomisma.rdf'

        if not os.path.exists(data_dir):
            os.mkdir(data_dir)


    def collect(self):
        """ Paginate through all items in Figgy listed as "Coins". Place all 
        JSON data into one file.
        """

        # From first page of figgy's selection of Coins, collect the data and
        #  the maximum pagination
        main_url = ("https://figgy.princeton.edu/catalog.json?f%5B" +
            "human_readable_type_ssim%5D%5B%5D=Coin&per_page=100")
        req = requests.get(main_url)
        coin_json = json.loads(req.text)
        max_page = coin_json['response']['pages']['total_pages']
        print(f'Max: {max_page}')

        # Iterate through pages and create a json of all coin data
        # NOTE: This approach may lead to heavy memory usage if dataset
        # expands, especially because of list concatenation.
        coin_list = coin_json['response']['docs']
        for page in range(2, max_page+1):
            url = ("https://figgy.princeton.edu/catalog.json?f%5B" +
                "human_readable_type_ssim%5D%5B%5D=Coin&page={page}&per_page=100")
            req = requests.get(url)
            coin_list += json.loads(req.text)['response']['docs']
            print(page, end=', ')
            
        with open(self.raw, 'w') as f:
            json.dump(coin_list, f, indent=4)


    def trim(self):
        """ Collect only the useful components of the raw JSON data and output 
        into a CSV.
        """
        with open(self.raw) as f:
            coin_list = json.load(f)

        coin_list_trimmed = []
        for coin in coin_list:
            coin_list_trimmed.append({
                'coin_number_tsi': coin['coin_number_tsi']
            })
        df = pd.DataFrame(coin_list_trimmed)

        df.to_csv(pjoin(self.trimmed), index=False)


    def validate(self):
        """Apply tests to trimmed CSV to assure that data matches the expected 
        schema.
        """
        def no_empty_cells(series):
            return series.shape[0] == series.dropna().shape[0]
        
        df = pd.read_csv(self.trimmed)

        assert no_empty_cells(df['coin_number_tsi'])
        assert all([cn.startswith('integer-') for cn in df['coin_number_tsi']])


    def transform(self):
        """Transform trimmed data from figgy into data ultimately used in the 
        RDF.
        """
        df = pd.read_csv(self.trimmed)

        df['identifier'] = df['coin_number_tsi'].str.replace('integer', 'coin')
        df['full_link'] = 'https://catalog.princeton.edu/catalog/' + df['identifier']
        df['title'] = df['identifier'].apply(lambda x: x.replace('-', ' ').capitalize())
        
        cols = ['identifier', 'full_link', 'title']
        df_o = df[cols]
        df_o.to_csv(self.rdf_prep, index=False)


    def generate_rdf(self):
        """Turn the CSV into the published RDF file."""
        df = pd.read_csv(self.rdf_prep)

        rdf = """<rdf:RDF xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:void="http://rdfs.org/ns/void#"
    xmlns:nmo="http://nomisma.org/ontology#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema#">
"""

        for i, r in df.iterrows():
            rdf += (f"""
    <nmo:NumismaticObject rdf:about="{r['full_link']}">
        <dcterms:title>{r['title']}</dcterms:title>
        <dcterms:identifier>{r['identifier']}</dcterms:identifier>
        <void:inDataset rdf:resource="https://library.princeton.edu/special-collections/databases/princeton-numismatic-collection-database"/>
    </nmo:NumismaticObject>""")

        rdf += "\n</rdf:RDF>\n"

        with open(self.rdf, 'w') as f:
            f.write(rdf)

    def run_pipeline(self, scrape=True):
        """Iterate through entire pipeline"""
        if scrape:
            self.collect()
        self.trim()
        self.validate()
        self.transform()
        self.generate_rdf()


if __name__ == '__main__':
    nm = NomismaPipeline()
    nm.run_pipeline(scrape=False)