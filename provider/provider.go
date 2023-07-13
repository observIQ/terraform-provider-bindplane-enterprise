package provider

import (
	"context"
	"fmt"

	"github.com/hashicorp/terraform-plugin-sdk/v2/diag"
	"github.com/hashicorp/terraform-plugin-sdk/v2/helper/schema"
	"github.com/observiq/bindplane-op-enterprise/client"
	"github.com/observiq/bindplane-op-enterprise/config"
	ossClient "github.com/observiq/terraform-provider-bindplane/client"
	ossProvider "github.com/observiq/terraform-provider-bindplane/provider"
)

const (
	envAPIKey = "BINDPLANE_TF_API_KEY"
)

// Provider returns a *schema.Provider.
func Provider() *schema.Provider {
	provider := ProviderWithSchema()

	provider.ConfigureContextFunc = func(_ context.Context, d *schema.ResourceData) (any, diag.Diagnostics) {
		return providerConfigure(d, provider)
	}

	return provider
}

func ProviderWithSchema() *schema.Provider {
	p := ossProvider.ProviderWithSchema()

	// Add Enterprise API key to the schema
	apiKey := schema.Schema{
		Type:     schema.TypeString,
		Optional: true,
		DefaultFunc: schema.MultiEnvDefaultFunc([]string{
			envAPIKey,
		}, nil),
		Description: "The endpoint used to connect to the BindPlane OP instance.",
	}
	p.Schema["api_key"] = &apiKey

	return p
}

func providerConfigure(d *schema.ResourceData, _ *schema.Provider) (any, diag.Diagnostics) {
	config := &config.Config{}

	if v, ok := d.Get("api_key").(string); ok && v != "" {
		config.Auth.APIKey = v
	}

	if v, ok := d.Get("username").(string); ok && v != "" {
		config.Auth.Username = v
	}

	if v, ok := d.Get("password").(string); ok && v != "" {
		config.Auth.Password = v
	}

	if v, ok := d.Get("remote_url").(string); ok && v != "" {
		config.Network.RemoteURL = v
	}

	if v, ok := d.Get("tls_certificate_authority").(string); ok && v != "" {
		config.Network.TLS.CertificateAuthority = []string{v}
	}

	if crt, ok := d.Get("tls_certificate").(string); ok && crt != "" {
		if key, ok := d.Get("tls_private_key").(string); ok && key != "" {
			config.Network.TLS.Certificate = crt
			config.Network.TLS.PrivateKey = key
		}
	}

	logger, err := ossProvider.NewLogger()
	if err != nil {
		return nil, diag.FromErr(err)
	}

	c, err := client.NewBindPlane(config, logger)
	if err != nil {
		err = fmt.Errorf("failed to initialize bindplane client: %w", err)
		return nil, diag.FromErr(err)
	}

	return &ossClient.BindPlane{
		Client: c,
	}, nil
}
