import json
import requests
import os
from os.path import join as pjoin

import pandas as pd

class NomismaPipeline(object):
    """Extracts data from figgy, validates that it meets our required schema, 
    and generates an RDF that follows Nomisma's guidelines.
    """
    def __init__(self, data_dir='data', raw_dir='data/raw'):
        self.data_dir = data_dir
        self.raw_dir = raw_dir
        self.trimmed = pjoin(data_dir, 'coin-list-trimmed.csv')
        self.rdf_prep = pjoin(data_dir, 'coin-list-rdf.csv')
        self.rdf = 'princeton-nomisma.rdf'

        if not os.path.exists(data_dir):
            os.mkdir(data_dir)
        if not os.path.exists(raw_dir):
            os.mkdir(raw_dir)

        self.raw_json = None


    def get_raw_json(self):
        """Collect all the raw json files from the raw directory and combine
         cache it into working memory.
        """
        raw_json_paths = [
            pjoin(self.raw_dir, filename) for filename in os.listdir(self.raw_dir)
                if filename.endswith('.json')
        ]
        raw_json = []
        for json_path in raw_json_paths:
            with open(json_path) as f:
                raw_json.extend(json.load(f))

        self.raw_json = raw_json
        return raw_json


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
        zfill_max = len(str(max_page))
        print(f'Max: {max_page}')

        # Iterate through pages and create a json of all coin data
        for page in range(1, max_page+1):
            url = ("https://figgy.princeton.edu/catalog.json?f%5B" +
                f"human_readable_type_ssim%5D%5B%5D=Coin&page={page}&per_page=100")
            req = requests.get(url)
            coin_list = json.loads(req.text)['response']['docs']
            print(page, end=', ')
            
            json_filename = f'coin-list-raw-{str(page).zfill(zfill_max)}.json'
            json_path = pjoin(self.raw_dir, json_filename)
            with open(json_path, 'w') as f:
                json.dump(coin_list, f, indent=4)


    def trim(self):
        """ Collect only the useful components of the raw JSON data and output 
        into a CSV.
        """
        coin_list = self.get_raw_json()

        coin_list_trimmed = []
        for coin in coin_list:
            coin_list_trimmed.append({
                'coin_number': coin['coin_number_tsi'],
                'weight': coin.get('weight_tesi')
            })
        df = pd.DataFrame(coin_list_trimmed)

        # arbitrary sorting to provide clearer diffs
        # df = df.sort_values('coin_number')

        df.to_csv(self.trimmed, index=False)


    def validate(self):
        """Apply tests to trimmed CSV to assure that data matches the expected 
        schema.
        """
        def no_empty_cells(series):
            return series.shape[0] == series.dropna().shape[0]
        def unique_values(series):
            return series.shape[0] == series.unique().shape[0]
        
        df = pd.read_csv(self.trimmed)

        # assert unique_values(df['coin_number'])
        assert no_empty_cells(df['coin_number'])
        assert all([cn.startswith('integer-') for cn in df['coin_number']])


    def transform(self):
        """Transform trimmed data from figgy into data ultimately used in the 
        RDF.
        """
        df = pd.read_csv(self.trimmed)

        df['identifier'] = df['coin_number'].str.replace('integer', 'coin')
        df['full_link'] = 'https://catalog.princeton.edu/catalog/' + df['identifier']
        df['title'] = df['identifier'].apply(lambda x: x.replace('-', ' ').capitalize())
        
        cols = ['identifier', 'full_link', 'title', 'weight']
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
""")
            if not pd.isna(r['weight']):
                rdf += f"""        <nmo:hasWeight rdf:datatype="http://www.w3.org/2001/XMLSchema#decimal">{r['weight']}</nmo:hasWeight>\n"""

            rdf += "    </nmo:NumismaticObject>"

        rdf += "\n</rdf:RDF>\n"

        with open(self.rdf, 'w') as f:
            f.write(rdf)


    def run_pipeline(self, scrape=True):
        """Iterate through entire pipeline"""
        if scrape:
            self.collect()
        print('Trimming raw data...')
        self.trim()
        print('Running basic validation...')
        self.validate()
        print('Preparing data for RDF generation...')
        self.transform()
        print('Creating RDF...')
        self.generate_rdf()


if __name__ == '__main__':
    nm = NomismaPipeline()
    nm.run_pipeline(scrape=False)