
# Traefik Forward Auth

> [!IMPORTANT]
> This repository is a small, production-oriented fork of
> [`mesosphere/traefik-forward-auth`](https://github.com/mesosphere/traefik-forward-auth).
> It tracks upstream and intentionally carries only two application features:
>
> 1. configurable OIDC claims forwarded as response headers, from
>    [mesosphere/traefik-forward-auth#72](https://github.com/mesosphere/traefik-forward-auth/pull/72);
> 2. nonce-scoped CSRF cookies, adapted from
>    [thomseddon/traefik-forward-auth#187](https://github.com/thomseddon/traefik-forward-auth/pull/187),
>    so simultaneous OAuth flows cannot overwrite one another.

The current code baseline is Mesosphere `v3.3.0`. Fork provenance, maintenance
rules, and release naming are documented in [FORK.md](FORK.md).

## Container image

Images are published to GitHub Container Registry for `linux/amd64` and
`linux/arm64`:

```text
ghcr.io/bennesp/traefik-forward-auth:<release-tag>
```

Production deployments should use an immutable release tag or digest, not
`latest`.

## Fork features

### Forward selected OIDC claims

`EXTRA_CLAIMS` maps response-header names to string-valued ID-token claims:

```text
EXTRA_CLAIMS=X-Forwarded-Locale:locale,X-Forwarded-Picture:picture
```

The corresponding headers must also be included in Traefik's
`forwardAuth.authResponseHeaders` or `authResponseHeadersRegex` configuration.

### Concurrent OAuth flows

Each OAuth transaction receives a nonce-scoped temporary CSRF cookie. A
callback selects and clears only its own cookie, allowing parallel browser
requests or tabs to complete authentication independently.

The original [`thomseddon/traefik-forward-auth`](https://github.com/thomseddon/traefik-forward-auth) is a "minimal forward authentication service that provides Google oauth based login and authentication for the [traefik](https://github.com/containous/traefik) reverse proxy/load balancer."

This is a partial rewrite to support generic OIDC Providers that provide [OpenID Provider Issuer Discovery](https://openid.net/specs/openid-connect-discovery-1_0.html) but may not support the `UserInfo` endpoint.

[`noelcatt/traefik-forward-auth`](https://github.com/noelcatt/traefik-forward-auth) and [`funkypenguin/traefik-forward-auth`](https://github.com/funkypenguin/traefik-forward-auth) also made [`thomseddon/traefik-forward-auth`](https://github.com/thomseddon/traefik-forward-auth) apply to generic OIDC, but they are now based on an older version which does not support rules and also require the UserInfo endpoint to be supported.

This version optionally implements RBAC within Kuberbetes by using `ClusterRole` and `ClusterRoleBinding`. It extends from the original Kubernetes usage as it also allows specifying full URLs (including a scheme and domain) within `nonResourceURLs` attribute of `ClusterRole`. And unlike the original behavior, `*` wildcard character matches within one path component only. There is a special globstar `**` to match within multiple paths (inspired by Bash, Python and JS libraries).

The raw id-token received from OIDC provider can optionally be passed upstream via a custom header.

## Differences to the original

The instructions for [`thomseddon/traefik-forward-auth`](https://github.com/thomseddon/traefik-forward-auth) are useful, keeping in mind that this version:

- Does not support legacy configuration (`cookie-domains`, `cookie-secret`, `cookie-secure`, `prompt`).
- Does not support Google-specific configuration (`providers`, `providers.google.client-id`, `providers.google.client-secret`, `providers.google.prompt`).
- Does support `provider-uri`, `client-id`, `client-secret` configuration.
- Uses an OIDC Discovery endpoint to find authorization and token endpoints.
- Does not require the OIDC Provider to support the optional UserInfo endpoint.
- Returns 401 rather than redirect to OIDC Login if an unauthenticated request is not for HTML (e.g. AJAX calls, images).
- Sends a username cookie as well
- If `auth-host` is set and `cookie-domains` is not set, traefik-forward-auth will redirect any requests using other hostnames to `auth-host`. Set `auth-host` to the OIDC redirect host to ensure that use of the IP or other DNS names will be redirected and get a suitable cookie.

## Upgrading from 2.x version to 3.0 (Breaking Changes):

- config `session-key` (`SESSION_KEY` env) is now called `encryption-key` (`ENCRYPTION_KEY` env) and is `REQUIRED`
- config `groups-session-name` (`GROUPS_SESSION_NAME`) is deprecated as both email and groups are part of the single cookie `cookie-name` (`COOKIE_NAME` env)
- character `*` in existing RBAC rules now works within one path component only, so a single `*` has to be replaced with `**` to match the previous behavior (whether to use `*` or `**` is up to the person writing those rules)
