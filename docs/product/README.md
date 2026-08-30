# Product Build Baseline

This directory defines the requirements and engineering boundaries for turning
the tested mobile remote-access guide into an installable product.

The product goal is secure and reliable mobile management of an AI agent on the
user's own Windows computer, including device identity, permissions, approvals,
audit, recovery, diagnostics, and rollback.

The current direct browser path remains available as **Legacy Bridge Mode**.
The product defaults to **Managed Gateway Mode**, where a local Windows gateway
authenticates the phone and applies policy before forwarding to Harness.

The authoritative V1 engineering specifications are currently maintained in
Chinese:

- [Product requirements](product-requirements-v1.zh.md)
- [System architecture](system-architecture-v1.zh.md)
- [Security model](security-model-v1.zh.md)
- [Compatibility program](compatibility-program-v1.zh.md)
- [Delivery roadmap](roadmap.zh.md)
- [ADR-0001: Managed gateway](../adr/0001-managed-gateway.md)
- [ADR-0002: Native clients with a shared protocol](../adr/0002-native-clients-shared-protocol.md)

These documents define direction and acceptance gates. They do not claim that
the installer, gateway, or native clients have already been implemented.
