# Always use devbox environment to run commands.
set shell := ["devbox", "run"]
# Load dotenv
set dotenv-load

export TF_VAR_name := env("APP_NAME")
export GIT_SHA := `git rev-parse --short HEAD`

# Run server locally
run:
  initdb --username=postgres || true
  devbox services start postgresql
  python src/app.py

dependencies:
  pip install -r src/requirements.txt

dependencies-lock:
  pip freeze -l > src/requirements.txt

release:
  #!/bin/env bash
  USERNAME="00000000-0000-0000-0000-000000000000"
  REGISTRY=$(terraform -chdir=terraform output -raw container_registry_name)

  TAG=${REGISTRY}.azurecr.io/develop:${GIT_SHA}-$(date +"%F-%H-%M-%S")

  docker build -t ${TAG} .

  # For podman support we must use this hacks,
  # otherwise az acr login would also do the docker login.
  docker login \
    --username=${USERNAME} \
    --password=$(az acr login --name ${REGISTRY} --expose-token 2>/dev/null | jq -r '.accessToken') \
    "${REGISTRY}.azurecr.io"

  docker push ${TAG}

  echo "Image pushed to ${TAG}"
  echo "Modify your .env with TF_VAR_image=${TAG}"

deploy:
  terraform -chdir=terraform init
  terraform -chdir=terraform apply

destroy:
  terraform -chdir=terraform destroy
