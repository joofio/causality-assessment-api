import json
import os
from typing import Dict, List, Tuple

import numpy as np
from flask import Flask, Response, jsonify, request, send_file


ALLOWED_VALUES = {
    "DESCRIBED": ["No", "Yes"],
    "REINTRODUCED": ["No", "Yes"],
    "REAPPEARED": ["No", "Yes", "NA"],
    "ADMINISTRATION": ["Oral", "Injectable", "Topical"],
    "NOTIFIER": ["Physician", "Nurse", "Pharmacist"],
    "SUSPENDED": ["No", "Yes", "Reduced", "NA"],
    "IMPROVED": ["No", "Yes", "NA"],
    "CONCOMITANT": ["No", "Yes"],
    "INTERACT": ["No", "Yes"],
    "INEFFECTIVE": ["No", "Yes"],
    "PHARMAGROUP": [
        "DrugsForSkinDisorders",
        "DrugsForEyeDisorders",
        "AntiallergicMedication",
        "Antiinfectious",
        "AntineoplasticDrugsImmunemodulators",
        "CardiovascularSystem",
        "GastrointestinalSystem",
        "GenitourinarySystem",
        "LocomotorSystem",
        "RespiratorySystem",
        "Hormones",
        "DiagnosisMedia",
        "Nutrition",
        "Blood",
        "CentralNervousSystem",
        "DrugsToTreatPoisoning",
        "VaccinesImmunoglobulins",
    ],
}


class BayesianModel:
    def __init__(self, model_json_path: str):
        self.variables = [
            "Described",
            "Reintroduced",
            "Reappeared",
            "Administration",
            "Notifier",
            "Suspended",
            "ImprovedAfterSuspension",
            "Concomitant",
            "SuspectedInteraction",
            "DrugIneffective",
            "PharmaGroup",
            "Definite",
            "Probable",
            "Possible",
            "Conditional",
        ]
        self.var_to_idx = {v: i for i, v in enumerate(self.variables)}
        self.state_to_idx: Dict[str, Dict[str, int]] = {}
        self.factors: List[Tuple[List[str], np.ndarray]] = []

        self._load_model_json(model_json_path)
        self._build_joint()

    def _load_model_json(self, model_json_path: str) -> None:
        with open(model_json_path, "r", encoding="utf-8") as f:
            payload = json.load(f)

        for factor in payload["factors"]:
            factor_vars = factor["variables"]
            factor_shape = tuple(factor["shape"])
            factor_values = np.array(factor["values"], dtype=np.float64).reshape(factor_shape, order="C")

            for var in factor_vars:
                if var not in self.state_to_idx:
                    states = factor["states"][var]
                    self.state_to_idx[var] = {state: idx for idx, state in enumerate(states)}

            self.factors.append((factor_vars, factor_values))

    def _build_joint(self) -> None:
        dims = [len(self.state_to_idx[var]) for var in self.variables]
        total_states = int(np.prod(dims))
        joint_flat = np.ones(total_states, dtype=np.float64)

        global_strides = []
        running = 1
        for d in reversed(dims):
            global_strides.append(running)
            running *= d
        global_strides = list(reversed(global_strides))
        assignments = np.arange(total_states, dtype=np.int64)

        for factor_vars, cpt in self.factors:
            factor_dims = [len(self.state_to_idx[v]) for v in factor_vars]
            factor_strides = []
            running = 1
            for d in reversed(factor_dims):
                factor_strides.append(running)
                running *= d
            factor_strides = list(reversed(factor_strides))

            factor_linear = np.zeros(total_states, dtype=np.int64)
            for i, var in enumerate(factor_vars):
                gpos = self.var_to_idx[var]
                state_idx = (assignments // global_strides[gpos]) % dims[gpos]
                factor_linear += state_idx * factor_strides[i]

            joint_flat *= cpt.ravel(order="C")[factor_linear]

        self._joint = joint_flat.reshape(tuple(dims), order="C")

    def posterior_yes(self, outcome: str, evidence: Dict[str, str]) -> float:
        slicer = [slice(None)] * len(self.variables)
        for var, state in evidence.items():
            if var == outcome:
                continue
            slicer[self.var_to_idx[var]] = self.state_to_idx[var][state]

        dist = self._joint[tuple(slicer)]
        remaining_vars = [v for v in self.variables if not isinstance(slicer[self.var_to_idx[v]], int)]
        outcome_axis = remaining_vars.index(outcome)
        sum_axes = tuple(i for i in range(dist.ndim) if i != outcome_axis)
        probs = dist.sum(axis=sum_axes)
        probs = probs / probs.sum()
        yes_idx = self.state_to_idx[outcome]["Yes"]
        return float(np.round(probs[yes_idx], 2))


MODEL_PATH = os.path.join(os.path.dirname(__file__), "model_weights.json")
MODEL = BayesianModel(MODEL_PATH)

app = Flask(__name__)


@app.get("/")
def root():
    return jsonify({"hello": "world"})


@app.get("/api/docs/")
def swagger_docs():
    return Response(
        """<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <title>Causality Assessment API Docs</title>
    <link rel="stylesheet" href="https://unpkg.com/swagger-ui-dist@5/swagger-ui.css" />
  </head>
  <body>
    <div id="swagger-ui"></div>
    <script src="https://unpkg.com/swagger-ui-dist@5/swagger-ui-bundle.js"></script>
    <script>
      SwaggerUIBundle({
        url: "/api/docs/openapi.yaml",
        dom_id: "#swagger-ui"
      });
    </script>
  </body>
</html>
""",
        mimetype="text/html",
    )


@app.get("/api/docs/openapi.yaml")
def swagger_spec():
    return send_file(
        os.path.join(os.path.dirname(__file__), "api-spec.yaml"),
        mimetype="application/yaml",
    )


@app.post("/eval_causality")
def eval_causality():
    data = request.get_json(silent=True)
    if data is None:
        return jsonify({"error": "No data"}), 400

    described_r = str(data.get("DESCRIBED", ""))
    reintroduced_r = str(data.get("REINTRODUCED", ""))
    reappeared_r = str(data.get("REAPPEARED", ""))
    administration_r = str(data.get("ADMINISTRATION", ""))
    notifier_r = str(data.get("NOTIFIER", ""))
    suspended_r = str(data.get("SUSPENDED", ""))
    improved_r = str(data.get("IMPROVED", ""))
    concomitant_r = str(data.get("CONCOMITANT", ""))
    interact_r = str(data.get("INTERACT", ""))
    ineffective_r = str(data.get("INEFFECTIVE", ""))
    pharmagroup_r = str(data.get("PHARMAGROUP", ""))

    data_correct = True
    input_error: List[str] = []

    def _check(value: str, allowed: List[str], error_name: str):
        nonlocal data_correct
        if value and value not in allowed:
            input_error.append(error_name)
            data_correct = False

    _check(described_r, ALLOWED_VALUES["DESCRIBED"], "described")
    _check(reintroduced_r, ALLOWED_VALUES["REINTRODUCED"], "reintroduced")
    _check(reappeared_r, ALLOWED_VALUES["REAPPEARED"], "reappeared_r")
    _check(administration_r, ALLOWED_VALUES["ADMINISTRATION"], "administration")
    _check(notifier_r, ALLOWED_VALUES["NOTIFIER"], "notifier")
    _check(suspended_r, ALLOWED_VALUES["SUSPENDED"], "suspended")
    _check(improved_r, ALLOWED_VALUES["IMPROVED"], "improved")
    _check(concomitant_r, ALLOWED_VALUES["CONCOMITANT"], "concomitant")
    _check(interact_r, ALLOWED_VALUES["INTERACT"], "interact")
    _check(ineffective_r, ALLOWED_VALUES["INEFFECTIVE"], "ineffective")
    _check(pharmagroup_r, ALLOWED_VALUES["PHARMAGROUP"], "pharmagroup")

    if not data_correct:
        return jsonify({"error": "Error in input data", "input_error": input_error}), 400

    evidence: Dict[str, str] = {}
    if described_r:
        evidence["Described"] = described_r
    if reintroduced_r:
        evidence["Reintroduced"] = reintroduced_r
    if reappeared_r:
        evidence["Reappeared"] = reappeared_r
    if administration_r:
        evidence["Administration"] = administration_r
    if ineffective_r:
        evidence["DrugIneffective"] = ineffective_r
    if pharmagroup_r:
        evidence["PharmaGroup"] = pharmagroup_r
    if notifier_r:
        evidence["Notifier"] = notifier_r
    if concomitant_r:
        evidence["Concomitant"] = concomitant_r
    if interact_r:
        evidence["SuspectedInteraction"] = interact_r
    if suspended_r:
        evidence["Suspended"] = suspended_r
    if improved_r:
        evidence["ImprovedAfterSuspension"] = improved_r

    return jsonify(
        {
            "definitve_score": MODEL.posterior_yes("Definite", evidence),
            "probable_score": MODEL.posterior_yes("Probable", evidence),
            "possible_score": MODEL.posterior_yes("Possible", evidence),
            "conditional_score": MODEL.posterior_yes("Conditional", evidence),
        }
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.getenv("PORT", "8000")))
