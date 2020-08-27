### Provision alerts for demo application

Once the demo-deployer has successfully deployed your application, you can run the following commands to provision alerts for that application.

#### Requirements `.tfvars.json`

- `account_id` must be a valid New Relic account ID
- `api_key` value must be a valid New Relic Personal API Key and is associated with the New Relic account mentioned above.

```
docker run --rm \
  --mount type=bind,source="$(pwd)/terraform",target='/terraform' \
  -w /terraform \
  -it hashicorp/terraform plan \
  -var-file ".tfvars.json"
```

<small>**Note:** The path `$(pwd)/terraform` refers to the `./terraform` directory within this repository.</small>
