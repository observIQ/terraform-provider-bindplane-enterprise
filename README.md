BindPlane Terraform Provider
==========================

[![CI](https://github.com/observIQ/terraform-provider-bindplane-enterprise/actions/workflows/ci.yml/badge.svg)](https://github.com/observIQ/terraform-provider-bindplane-enterprise/actions/workflows/ci.yml)

Terraform provider for observIQ's agent management platform, [BindPlane OP](https://github.com/observIQ/bindplane-op).

## Enterprise and Cloud

This provider is an extension of the [BindPlane OP Provider](https://github.com/observIQ/terraform-provider-bindplane/tree/main) and is intended for use with BindPlane OP Enterprise and BindPlane OP Cloud.

- [Resource Configuration](https://github.com/observIQ/terraform-provider-bindplane/tree/main/docs/resources)
- [Example Usage](https://github.com/observIQ/terraform-provider-bindplane/tree/main/example)

## Provider Configuration

The provider can be configured with options
and environment variables.

| Option                      | Evironment                | Description                  |
| --------------------------- | ------------------------- | ---------------------------- |
| `remote_url`                | `BINDPLANE_TF_REMOTE_URL` | The URL for the BindPlane server.  |
| `api_key`                   | `BINDPLANE_TF_API_KEY`    | The API key to use for authentication as an alternative to `username` and `password`. |
| `username`                  | `BINDPLANE_TF_USERNAME`   | The BindPlane basic auth username. |
| `password`                  | `BINDPLANE_TF_PASSWORD`   | The BindPlane basic auth password. |
| `tls_certificate_authority` | `BINDPLANE_TF_TLS_CA`     | Path to x509 PEM encoded certificate authority to trust when connecting to BindPlane. |
| `tls_certificate`           | `BINDPLANE_TF_TLS_CERT`   | Path to x509 PEM encoded client certificate to use when mTLS is desired. |
| `tls_private_key`           | `BINDPLANE_TF_TLS_KEY`    | Path to x509 PEM encoded private key to use when mTLS is desired. |

## Usage

The BindPlane OP Enterprise provider is a drop in replacement for
the [BindPlane OP Provider](https://github.com/observIQ/terraform-provider-bindplane).
The only required change is a modification of the `required_providers` configuration.

```tf
terraform {
  required_providers {
    bindplane = {
      source = "observiq/bindplane-enterprise"
    }
  }
}
```

See [Example Usage](https://github.com/observIQ/terraform-provider-bindplane/tree/main/example)
for detailed examples. 
