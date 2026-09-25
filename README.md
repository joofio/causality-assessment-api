# Causality Assessment API

## How to

Python (default Dockerfile):

```bash
docker build -t causality-assessment-api:py .
docker run -p 8000:8000 causality-assessment-api:py
```

R runtime (legacy):

```bash
docker build -t causality-assessment-api:r -f Dockerfile.r .
docker run -v logs:/app/logs -p 8000:8000 causality-assessment-api:r
```

Run the Python app locally:

```bash
cd app
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python main.py
```

Send JSON to the Python API:

```bash
curl -X POST http://127.0.0.1:8000/eval_causality \
  -H "Content-Type: application/json" \
  -d '{
    "DESCRIBED": "Yes",
    "REINTRODUCED": "No",
    "REAPPEARED": "NA",
    "ADMINISTRATION": "Oral",
    "NOTIFIER": "Physician",
    "SUSPENDED": "Yes",
    "IMPROVED": "Yes",
    "CONCOMITANT": "No",
    "INTERACT": "No",
    "INEFFECTIVE": "No",
    "PHARMAGROUP": "Antiinfectious"
  }'
```

The Python runtime loads the Bayesian network weights from `app/model_weights.json` and exposes Swagger UI at `http://127.0.0.1:8000/api/docs/`.

## Paper

from the [paper](https://reader.elsevier.com/reader/sd/pii/S0933365717306152?token=7C9DD4DB0AAA4D2C980DC907F0862DC8462D0E70F0E5525BCB87C73FE6AFE2B3D3A843466442383E581BED5FF4B39CFF&originRegion=eu-west-1&originCreation=20221205142619):
<https://reader.elsevier.com/reader/sd/pii/S0933365717306152?token=7C9DD4DB0AAA4D2C980DC907F0862DC8462D0E70F0E5525BCB87C73FE6AFE2B3D3A843466442383E581BED5FF4B39CFF&>

```The nomenclature used for drug classification was the
one adopted by Portuguese Authority of Medicines and Health Products
(INFARMED, IP) according to national legislation (Despacho no 21844/
2004, de 12 de outubro) which includes a correspondence with the in-
ternational ATC. Variable modeled with (anti-infectious/central ner-
vous system/cardiovascular system/blood/respiratory system/gastro-
intestinal system/genitourinary system/hormones and drugs used to
treat endocrine diseases/loco-motor system/anti-allergic medication/
nutrition/corrective agents in blood volume and electrolyte dis-
turbances/ drugs for skin disorders/drugs used in otorhinolar-
yngological disorders/drugs for eye disorders/antineoplastic drugs and
immune-modulators/drugs used to treat poisoning/vaccines and im-
munoglobulins/diagnosis media)
```
