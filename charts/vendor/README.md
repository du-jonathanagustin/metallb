# Vendored MetalLB chart

The MetalLB 0.16.2 chart comes from the published Helm repository. The upstream archive SHA-256 is `96667a810bdf9b9d1e6d320af16a4e66c63ba56301bc21005e645cd7a1c298a4`. [MetalLB Helm repository](https://metallb.github.io/metallb/)

The vendored chart marks nine MetalLB definitions and four optional FRR-K8s definitions for Helm retention so an app uninstall cannot cascade-delete configuration managed by another release. The other chart sources are unchanged.
