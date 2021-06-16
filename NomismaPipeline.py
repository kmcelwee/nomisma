import json
import requests
import os
import typer
from os.path import join as pjoin

import pandas as pd

from rdflib import Graph, Literal, RDF, URIRef, Namespace
from rdflib.namespace import FOAF, XSD, VOID, DCTERMS

app = typer.Typer(name="Nomisma Pipeline", add_completion=False)


class NomismaPipeline(object):
    """Extracts data from the catalog, validates that it meets our required schema,
    and generates an RDF that follows Nomisma's guidelines.
    """

    def __init__(self, data_dir="data", raw_dir="data/raw"):
        self.data_dir = data_dir
        self.raw_dir = raw_dir
        self.rdf_prep = pjoin(data_dir, "coin-list.csv")
        self.rdf = "princeton-nomisma.rdf"

        if not os.path.exists(data_dir):
            os.mkdir(data_dir)
        if not os.path.exists(raw_dir):
            os.mkdir(raw_dir)

    def get_raw_json(self):
        """Collect all the raw json files from the raw directory and combine
        cache it into working memory.
        """
        raw_json_paths = [
            pjoin(self.raw_dir, filename)
            for filename in os.listdir(self.raw_dir)
            if filename.endswith(".json")
        ]
        raw_json = []
        for json_path in raw_json_paths:
            with open(json_path) as f:
                raw_json.append(json.load(f))

        return raw_json

    def collect(self):
        """Paginate through all items in the Catalog listed as "Coins". Place all
        JSON data into `raw_dir`.
        """

        def get_coin_json(coin):
            r = requests.get(coin["links"]["self"] + "/raw")

            json_filename = f"{coin['id']}.json"
            json_path = pjoin(self.raw_dir, json_filename)

            coin_json = json.loads(r.text)
            with open(json_path, "w") as f:
                json.dump(coin_json, f, indent=4)

        main_url = "https://catalog.princeton.edu/catalog?f[format][]=Coin&format=json&per_page=100"
        req = requests.get(main_url)
        coin_json = json.loads(req.text)
        max_page = coin_json["meta"]["pages"]["total_pages"]
        zfill_max = len(str(max_page))
        print(f"Max: {max_page}")

        # Iterate through pages and create a json of all coin data
        for page in range(1, max_page + 1):
            url = f"{main_url}&page={page}"
            req = requests.get(url)
            coin_list = json.loads(req.text)["data"]

            for coin in coin_list:
                get_coin_json(coin)

            print(page, end=", ")

    def preprocessing(self):
        """Collect only the useful components of the raw JSON data and output
        into a CSV.
        """
        coin_list = self.get_raw_json()

        coin_list_trimmed = []
        for coin in coin_list:
            coin_list_trimmed.append(
                {
                    "identifier": coin["id"],
                    "title": coin.get(
                        "pub_created_display", coin["id"].replace("-", " ").capitalize()
                    ),
                    "weight": coin.get("weight_s"),
                    "axis": coin.get("die_axis_s"),
                    "diameter": coin.get("size_s"),
                    "material": coin.get("issue_metal_s"),
                }
            )
        df = pd.DataFrame(coin_list_trimmed)

        # arbitrary sorting to provide clearer diffs
        df = df.sort_values("identifier")

        # `weight` and `pub_created_display` exist in arrays of length 1, take that value out of its array
        assert all([True if isinstance(a, str) else len(a) == 1 for a in df["title"]])
        df["title"] = [x if isinstance(x, str) else x[0] for x in df["title"]]

        assert all([True if pd.isna(a) else len(a) == 1 for a in df["weight"]])
        df["weight"] = [None if pd.isna(x) else x[0] for x in df["weight"]]

        assert all([True if pd.isna(a) else len(a) == 1 for a in df["axis"]])
        df["axis"] = [None if pd.isna(x) else x[0] for x in df["axis"]]

        assert all([True if pd.isna(a) else len(a) == 1 for a in df["diameter"]])
        df["diameter"] = [None if pd.isna(x) else x[0] for x in df["diameter"]]

        assert all([True if pd.isna(a) else len(a) == 1 for a in df["material"]])
        df["material"] = [None if pd.isna(x) else x[0] for x in df["material"]]

        df["full_link"] = "https://catalog.princeton.edu/catalog/" + df["identifier"]

        cols = [
            "identifier",
            "full_link",
            "title",
            "weight",
            "axis",
            "diameter",
            "material",
        ]
        df_o = df[cols]
        df_o.to_csv(self.rdf_prep, index=False)

    def validate(self):
        """Apply tests to trimmed CSV to assure that data matches the expected
        schema.
        """

        def no_empty_cells(series):
            return series.shape[0] == series.dropna().shape[0]

        def unique_values(series):
            return series.shape[0] == series.unique().shape[0]

        df = pd.read_csv(self.rdf_prep)

        assert unique_values(df["identifier"])
        assert no_empty_cells(df["identifier"])
        assert all([cn.startswith("coin-") for cn in df["identifier"]])

        # Ensure no columns are empty
        #   (this would happen if we had used .get() on an unknown key)
        for col in df.columns:
            assert df[col].dropna().shape[0] != 0

    def generate_rdf(self):
        """Turn the CSV into the published RDF file."""
        df = pd.read_csv(self.rdf_prep)

        # create RDF graph
        g = Graph()

        # load / create namespaces
        NMO = Namespace("http://nomisma.org/ontology#")

        g.bind("dcterms", DCTERMS)
        g.bind("nmo", NMO)
        g.bind("void", VOID)

        for i, r in df.iterrows():
            coin = URIRef(r["full_link"])

            g.add((coin, RDF.type, NMO.NumismaticObject))
            g.add((coin, NMO.ObjectType, Literal("coin")))

            g.add((coin, DCTERMS.title, Literal(r["title"])))
            g.add((coin, DCTERMS.identifier, Literal(r["identifier"])))
            g.add(
                (
                    coin,
                    VOID.inDataset,
                    URIRef(
                        "https://library.princeton.edu/special-collections/databases/princeton-numismatic-collection-database"
                    ),
                )
            )

            if not pd.isna(r["weight"]):
                g.add((coin, NMO.hasWeight, Literal(r["weight"], datatype=XSD.decimal)))

            if not pd.isna(r["axis"]):
                g.add(
                    (coin, NMO.hasAxis, Literal(int(r["axis"]), datatype=XSD.integer))
                )

            if not pd.isna(r["diameter"]):
                g.add(
                    (
                        coin,
                        NMO.hasDiameter,
                        Literal(r["diameter"], datatype=XSD.decimal),
                    )
                )

            if not pd.isna(r["material"]):
                g.add((coin, NMO.hasMaterial, Literal(r["material"])))

        with open(self.rdf, "w") as f:
            f.write(g.serialize(format="pretty-xml").decode("utf-8"))

    def run_pipeline(self, scrape=True):
        """Iterate through entire pipeline"""
        if scrape:
            self.collect()
        print("Preprocessing data...")
        self.preprocessing()
        print("Running basic validation...")
        self.validate()
        print("Creating RDF...")
        self.generate_rdf()


@app.command()
def main(
    scrape: bool = typer.Option(
        False,
        "--scrape",
        "-s",
        help="Initiate scrape of the PUL catalog for new coin data.",
    )
):
    """Run the Nomisma Pipeline without scraping"""
    nm = NomismaPipeline()
    nm.run_pipeline(scrape=scrape)


if __name__ == "__main__":
    app()
