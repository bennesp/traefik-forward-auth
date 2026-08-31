# Fork maintenance

This repository tracks
[`mesosphere/traefik-forward-auth`](https://github.com/mesosphere/traefik-forward-auth)
and keeps its application-level delta deliberately small.

## Patch set

| Patch | Source | Purpose |
| --- | --- | --- |
| Configurable OIDC claim headers | [Mesosphere PR #72](https://github.com/mesosphere/traefik-forward-auth/pull/72) | Map selected string claims to headers returned by forward auth. |
| Concurrent CSRF transactions | [Thomseddon PR #187](https://github.com/thomseddon/traefik-forward-auth/pull/187) | Use nonce-scoped CSRF cookies so parallel OAuth flows do not overwrite state. |

Workflow and documentation files are fork infrastructure, not application
features.

## Branches

- `main` should be the only long-lived fork branch and the default branch.
- Feature and maintenance branches should be short-lived and deleted after
  merge.
- Upstream releases should be referenced by their original tags; duplicate
  long-lived `v2`, `v3`, or upstream feature branches are unnecessary.

Until the default branch is renamed, `add-github-action-workflow` serves the
role described above for `main`.

## Updating from upstream

1. Fetch `mesosphere/traefik-forward-auth` and its tags.
2. Merge the desired upstream release tag into `main`.
3. Keep the two patches above as separate, reviewable commits whenever conflict
   resolution requires replaying them.
4. Run `go test -race ./...`, `go vet ./...`, and build the binary.
5. Review `git diff <upstream-tag>...main`. Application code should differ only
   for the two documented patches.
6. Publish a fork release after CI succeeds.

## Releases

Fork releases use this format:

```text
v<upstream-version>-r<revision>
```

For example, the first fork release based on Mesosphere `v3.3.0` is
`v3.3.0-r1`. Increment the fork revision for changes that do not move the
upstream baseline. Start again at `r1` when adopting a new upstream version.

GitHub Releases build a multi-platform image for `linux/amd64` and
`linux/arm64`. Deployments should pin the release tag or resulting digest.
