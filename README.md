# uds-package-metallb

A Zarf Package containing a standalone version of [MetalLB](https://metallb.org/) to act as a standalone load-balancer or be a pre-req to UDS Core.

## Prerequisites

This package requires a Zarf-initialized kubernetes cluster to be installed.  This repo uses UDS to create a K3d cluster and initialize it via a bundle.

## Using

### Deploy

Use a deploy-time values file to define the address range MetalLB may allocate, since that range must belong to the target network and be reserved for MetalLB.

```yaml
addresspools:
  default:
    ipAddressPoolCIDR: 192.0.2.32/27
  interface: eth0
```

The example uses a documentation-only network. For dedicated UDS Core gateways, set both `addresspools.adminIngress.ipAddressPool` and `addresspools.tenantIngress.ipAddressPool` to reserved addresses so each gateway has a matching pool. The passthrough gateway can use `addresspools.passthroughIngress.ipAddressPool` when enabled.

```sh
uds zarf package deploy "$VERIFIED_METALLB_ARCHIVE" --values ./metallb-values.yaml --confirm
```

The command takes the local archive of the release verified in the section below and the values file containing the deployment's addresses. See [Test bundle configuration](docs/configuration.md#test-bundle) for the bundled workflow.

## Releases

The released packages can be found in [ghcr](https://github.com/uds-packages/metallb/pkgs/container/metallb).

### Verify a Package

Packages are signed using [Zarf's Keyless Signing](https://docs.zarf.dev/ref/package-signing/#using-keyless-signing).

Packages are signed from the following versions onwards:

| Flavor | First Signed Version |
| --- | --- |
| `upstream` | `0.16.1-uds.6` |
| `registry1` | `0.16.1-uds.38` |
| `unicorn` | `0.16.1-uds.38` |

To verify a package, follow the below example:

```bash
uds zarf package verify "oci://ghcr.io/uds-packages/metallb:0.16.1-uds.6-upstream" \
  --certificate-identity "https://github.com/uds-packages/metallb/.github/workflows/release.yaml@refs/heads/main" \
  --certificate-oidc-issuer "https://token.actions.githubusercontent.com"
```

For a `unicorn` package, use `oci://ghcr.io/uds-packages/private/metallb:<VERSION>-unicorn`
as the package source.

## Known Issues

This package is meant as a simple way to get MetalLB working for smaller clusters and doesn't support many of the more advanced options that MetalLB has.
