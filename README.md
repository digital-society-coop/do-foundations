# do-foundations
Foundations for DigitalOcean-based services

This repository defines a `foundation` service whose purpose is to provide the necessary interfaces to seamlessly deploy other services to DigitalOcean.

In particular, an `<environment>` instance of `foundation` provides:

- A `<environment>-foundation-terraform` DigitalOcean Spaces Object Storage bucket for Terraform state.

## Deployment

The service is continuously deployed by GitHub Actions.

### Manual deployment

#### Prerequisites

##### Tools

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
  
  Note that AWS itself is not used, but DigitalOcean's CLI does [not support](https://github.com/digitalocean/doctl/issues/258) Spaces operations.

- [Terraform CLI](https://developer.hashicorp.com/terraform/cli)

##### Environment

- The AWS CLI must be able to interact with the DigitalOcean Spaces API.
  This can be configured by obtaining a [Spaces Key](https://cloud.digitalocean.com/account/api/spaces) for your target account.

  Conventionally, these should be configured in an AWS credentials profile in `~/.aws/credentials`, e.g.:

  ```ini
  [DO-<team slug>-<user email>]
  aws_access_key_id = <your access key>
  aws_secret_access_key = <your secret key>
  ```

  You will also need a corresponding AWS configuration profile defined in `~/.aws/config`, e.g.:

  ```ini
  [profile DO-<team slug>-<user email>]
  region = <region>
  services = digitalocean-<region>

  [services digitalocean-<region>]
  s3 =
    endpoint_url = https://<region>.digitaloceanspaces.com
  ```

  You can then configure most AWS tools to use that profile by setting `AWS_PROFILE=DO-<team slug>-<user email>`.

  Note that DigitalOcean's access boundary is the team, so if you want strong isolation between environments you must create a team per environment.

#### Steps

1. Run the deployment script:

   ```sh
   ./deploy.sh '<env>'
   ```
