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
just dependencies
just run

# Provision infrastructure
just deploy

## RELEASE PROCESS
# Release new code
just release
# At this point, you have to modify .env to point to new image
# And then we can deploy the new image.
just deploy
```
