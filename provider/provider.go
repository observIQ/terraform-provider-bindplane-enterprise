package provider

import (
	"context"
	"fmt"

	"github.com/hashicorp/terraform-plugin-sdk/v2/diag"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"github.com/observiq/terraform-provider-bindplane/client"
	"github.com/observiq/terraform-provider-bindplane/provider"
)

// Provider returns a *schema.Provider.
func Provider() *schema.Provider {
	provider := provider.Schema()

	provider.ConfigureContextFunc = func(ctx context.Context, d *schema.ResourceData) (any, diag.Diagnostics) {
		return providerConfigure(ctx, d, provider)
	}

	return provider
}

// providerConfigure configures the BindPlane client, which can be accessed from data / resource
// functions with with 'bindplane := meta.(client.BindPlane)'
func providerConfigure(_ context.Context, d *schema.ResourceData, _ *schema.Provider) (any, diag.Diagnostics) {
	clientOpts := provider.Options([]client.Option{}, d)

	i, err := client.New(clientOpts...)
	if err != nil {
		err = fmt.Errorf("failed to initialize bindplane client: %w", err)
		return nil, diag.FromErr(err)
	}

	return i, nil
}
