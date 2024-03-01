# `python-azure-example`

Just an example of a way to deploy Python app to Azure using Terraform.

# Development

### Dependencies
 * [devbox](https://www.jetpack.io/devbox)
 * [justfile](https://github.com/casey/just) (optional, `devbox run -- just` can be used instead)

```sh
# Configure
cp example.env .env

# Start local dev
just run

# Provision infrastructure
just terraform apply

# Deploy new code
just deploy
```
