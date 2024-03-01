# Always use devbox environment to run commands.
set shell := ["devbox", "run"]
# Load dotenv
set dotenv-load

export TF_VAR_name := env("APP_NAME")

# Run server locally
run:
  flask --app src/server run

dependencies:
  pip install -r src/requirements.txt

dependencies-lock:
  pip freeze -l > src/requirements.txt

deploy:

terraform-apply:
  terraform -chdir=terraform init
  terraform -chdir=terraform apply

terraform-destroy:
  terraform -chdir=terraform destroy
