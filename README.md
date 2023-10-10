BindPlane Enterprise Terraform Provider
==========================

### Archived

The enterprise features of this provider have been ported to [observIQ/terraform-provider-bindplane](https://github.com/observIQ/terraform-provider-bindplane).

### Migration

To migrate from `observiq/bindplane-enterprise` to `observiq/bindplane` by updating
your `required_providers` configuration.

**Before**

```tf
terraform {
  required_providers {
    bindplane = {
      source = "observiq/bindplane-enterprise"
    }
  }
}
```

**After**

```
terraform {
  required_providers {
    bindplane = {
      source = "observiq/bindplane"
    }
  }
}
```
