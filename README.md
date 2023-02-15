# Github secret scanning alert service :microscope: :warning:

This repo holds the API and infrastructure code for the [Github secret scanning alert service](https://docs.github.com/en/developers/overview/secret-scanning-partner-program#create-a-secret-alert-service).

When GitHub detects our registered secrets in public repositories, it will send an alert to this service.  The detected secret will be logged and an alarm triggered so the impacted team can take action.

## Local development
1. Start the [devcontainer](https://code.visualstudio.com/docs/devcontainers/containers).
1. Make a copy of `api/.env.example` and name it `api/.env`.
1. Run `cd api && make dev` and access on `localhost:8000`.

Your requests to the API will need an `X-CloudFront-Header` with the value you set in the `api/.env` file for `CLOUDFRONT_HEADER`:

```sh
curl http://localhost:8000/version \
    -H "X-CloudFront-Header: some-secret-value"
```

Alternatively, you can set `CLOUDFRONT_HEADER=localhost` to disable this check.
