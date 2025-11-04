library(plumber)
# library(bnlearn)

load("ufn_form.RData")



#* @filter cors
cors <- function(req, res) {
  res$setHeader("Acess-Control-Allow-Origin", "*")
  if (req$REQUEST_METHOD == "OPTIONS") {
    res$setHeader("Access-Control-Allow-Methods", "*")
    res$setHeader("Access-Control-Allow-Headers", req$HTTP_ACCESS_CONTROL_REQUEST_HEADERS)
    res$status <- 200
    return(list())
  } else {
    plumber::forward()
  }
}

#* @get /
#* @parser json
#* @serializer json

function(req, res) {
  ret <- list(hello = "world")
  ret
}
#* @post /eval_causality
#* @parser json
#* @serializer json
#* @body InputData
function(req, res) {
  data <- tryCatch(jsonlite::parse_json(req$postBody, simplifyVector = TRUE), error = function(e) NULL)
  # data <- req$postBody
  if (is.null(data)) {
    res$status <- 400
    return(list(error = jsonlite::unbox("No data")))
  }


  ## Instanciar dois futuros vectores como nulos, para opcoes de N/A ##
  vec <- NULL
  st <- NULL
  ## Obter os valores das opcoes selecionadas do form html para o R ##
  described_r <- as.character(data$DESCRIBED)
  reintroduced_r <- as.character(data$REINTRODUCED)
  reappeared_r <- as.character(data$REAPPEARED)
  administration_r <- as.character(data$ADMINISTRATION)
  notifier_r <- as.character(data$NOTIFIER)
  suspended_r <- as.character(data$SUSPENDED)
  improved_r <- as.character(data$IMPROVED)
  concomitant_r <- as.character(data$CONCOMITANT)
  interact_r <- as.character(data$INTERACT)
  ineffective_r <- as.character(data$INEFFECTIVE)
  pharmagroup_r <- as.character(data$PHARMAGROUP)

  print(described_r)
  print(reintroduced_r)
  print(reappeared_r)
  print(administration_r)
  print(notifier_r)
  print(suspended_r)
  print(improved_r)
  print(concomitant_r)
  print(interact_r)
  print(ineffective_r)
  print(pharmagroup_r)







  data_correct <- TRUE
  input_error <- c()

  ### Described chr 1:2] "No" "Yes"

  if (!described_r %in% c("No", "Yes") && length(described_r) > 0) {
    print("error in described_r")
    input_error <- append(input_error, c("described"))
    data_correct <- FALSE
  }


  ##  Reintroduced chr 1:2] "No" "Yes"
  if (!reintroduced_r %in% c("No", "Yes") && length(reintroduced_r) > 0) {
    print("error in reintroduced_r")
    input_error <- append(input_error, c("reintroduced"))
    data_correct <- FALSE
  }
  ### Reappeared chr [1:3] "NA" "No" "Yes'

  if (!reappeared_r %in% c("No", "Yes", "NA") && length(reappeared_r) > 0) {
    print("error in reappeared_r")
    input_error <- append(input_error, c("reappeared_r"))
    data_correct <- FALSE
  }

  ### Administration chr [1:3] "Injectable" "Oral" "Topical"

  if (!administration_r %in% c("Oral", "Injectable", "Topical") && length(administration_r) > 0) {
    print("error in administration_r")
    input_error <- append(input_error, c("administration"))
    data_correct <- FALSE
  }

  ### $Notifier
  ### [1] "Nurse"      "Pharmacist" "Physician"

  if (!notifier_r %in% c("Physician", "Nurse", "Pharmacist") && length(notifier_r) > 0) {
    print("error in notifier_r")
    input_error <- append(input_error, c("notifier"))
    data_correct <- FALSE
  }

  ### Suspended  "NA" "No" "Reduced" "Yes"

  if (!suspended_r %in% c("No", "Yes", "Reduced", "NA") && length(suspended_r) > 0) {
    print("error in suspended_r")
    input_error <- append(input_error, c("suspended"))
    data_correct <- FALSE
  }

  ### $ImprovedAfterSuspension
  ### [1] "NA"  "No"  "Yes"

  if (!improved_r %in% c("No", "Yes", "NA") && length(improved_r) > 0) {
    print("error in improved_r")
    input_error <- append(input_error, c("improved"))
    data_correct <- FALSE
  }

  ### $Concomitant
  ### [1] "No"  "Yes"

  if (!concomitant_r %in% c("No", "Yes") && length(concomitant_r) > 0) {
    print("error in concomitant_r")
    input_error <- append(input_error, c("concomitant"))
    data_correct <- FALSE
  }

  ## SuspectedInteraction chr [1:2] "No" "Yes"
  if (!interact_r %in% c("No", "Yes") && length(interact_r) > 0) {
    print("error in interact_r")
    input_error <- append(input_error, c("described"))
    data_correct <- FALSE
  }

  ### DrugIneffective chr [1:2] "No" "Yes"

  if (!ineffective_r %in% c("No", "Yes") && length(ineffective_r) > 0) {
    print("error in ineffective_r")
    input_error <- append(input_error, c("ineffective"))
    data_correct <- FALSE
  }
  if (!pharmagroup_r %in% c(
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
    "VaccinesImmunoglobulins"
  ) && length(pharmagroup_r) > 0) {
    print("error in pharmagroup_r")
    input_error <- append(input_error, c("pharmagroup"))
    data_correct <- FALSE
  }


  print(data_correct)
  if (!data_correct) {
    res$status <- 400
    return(list(error = jsonlite::unbox("Error in input data"), input_error = input_error))
  }

  ## Atribuir o label e o respetivo valor aos vectores instanciados ##
  if (length(described_r) > 0) {
    vec <- c(vec, as.character("Described"))
    st <- c(st, as.character(data$DESCRIBED))
  }
  if (length(reintroduced_r) > 0) {
    vec <- c(vec, as.character("Reintroduced"))
    st <- c(st, as.character(data$REINTRODUCED))
  }
  if (length(reappeared_r) > 0) {
    vec <- c(vec, as.character("Reappeared"))
    st <- c(st, as.character(data$REAPPEARED))
  }
  if (length(administration_r) > 0) {
    vec <- c(vec, as.character("Administration"))
    st <- c(st, as.character(data$ADMINISTRATION))
  }
  if (length(ineffective_r) > 0) {
    vec <- c(vec, as.character("DrugIneffective"))
    st <- c(st, as.character(data$INEFFECTIVE))
  }
  if (length(pharmagroup_r) > 0) {
    vec <- c(vec, as.character("PharmaGroup"))
    st <- c(st, as.character(data$PHARMAGROUP))
  }
  if (length(notifier_r) > 0) {
    vec <- c(vec, as.character("Notifier"))
    st <- c(st, as.character(data$NOTIFIER))
  }
  if (length(concomitant_r) > 0) {
    vec <- c(vec, as.character("Concomitant"))
    st <- c(st, as.character(data$SUSPENDED))
  }
  if (length(interact_r) > 0) {
    vec <- c(vec, as.character("SuspectedInteraction"))
    st <- c(st, as.character(data$INTERACT))
  }
  if (length(suspended_r) > 0) {
    vec <- c(vec, as.character("Suspended"))
    st <- c(st, as.character(data$SUSPENDED))
  }
  if (length(improved_r) > 0) {
    vec <- c(vec, as.character("ImprovedAfterSuspension"))
    st <- c(st, as.character(data$IMPROVED))
  }


  print(c(st = st, vec = vec))
  ## Resultados da funcao / chamada ##
  result_definite <- query(model = ufn.net, outcome = "Definite", factors = vec, states = st)
  result_probable <- query(model = ufn.net, outcome = "Probable", factors = vec, states = st)
  result_possible <- query(model = ufn.net, outcome = "Possible", factors = vec, states = st)
  result_conditional <- query(model = ufn.net, outcome = "Conditional", factors = vec, states = st)


  def_score_yes <- result_definite[c(FALSE, TRUE)]
  def_score_no <- result_definite[c(TRUE, FALSE)]
  def_score_yes_int <- as.numeric(def_score_yes)
  def_score_no_int <- as.numeric(def_score_no)
  def_score_yes_round <- round(def_score_yes_int, digits = 2)
  def_score_no_round <- round(def_score_no_int, digits = 2)
  pro_score_yes <- result_probable[c(FALSE, TRUE)]
  pro_score_no <- result_probable[c(TRUE, FALSE)]
  pro_score_yes_int <- as.numeric(pro_score_yes)
  pro_score_no_int <- as.numeric(pro_score_no)
  pro_score_yes_round <- round(pro_score_yes_int, digits = 2)
  pro_score_no_round <- round(pro_score_no_int, digits = 2)
  pos_score_yes <- result_possible[c(FALSE, TRUE)]
  pos_score_no <- result_possible[c(TRUE, FALSE)]
  pos_score_yes_int <- as.numeric(pos_score_yes)
  pos_score_no_int <- as.numeric(pos_score_no)
  pos_score_yes_round <- round(pos_score_yes_int, digits = 2)
  pos_score_no_round <- round(pos_score_no_int, digits = 2)
  con_score_yes <- result_conditional[c(FALSE, TRUE)]
  con_score_no <- result_conditional[c(TRUE, FALSE)]
  con_score_yes_int <- as.numeric(con_score_yes)
  con_score_no_int <- as.numeric(con_score_no)
  con_score_yes_round <- round(con_score_yes_int, digits = 2)
  con_score_no_round <- round(con_score_no_int, digits = 2)

  ret <- list(definitve_score = def_score_yes_round, probable_score = pro_score_yes_round, possible_score = pos_score_yes_round, conditional_score = con_score_yes_round)
  return(ret)
}
#* @plumber
function(pr) {
  pr %>%
    pr_set_api_spec("api-spec.yaml") %>%
    validate_api_spec()
}
