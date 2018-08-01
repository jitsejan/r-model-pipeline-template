library(plumber)

serve_model <- plumb("/opt/scripts/expose.R")
serve_model$run(host='0.0.0.0', port=8000)