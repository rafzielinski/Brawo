# Development docs

Contributor and engine maintainer documentation. For using Brawo CMS in your app, start at [../index.md](../index.md).

## Topics

| Topic | Doc |
|-------|-----|
| Contributing | [contributing.md](contributing.md) |
| Testing & OpenAPI | [testing.md](testing.md) |
| Admin implementation | [admin-internals.md](admin-internals.md) |
| Admin styling | [admin-styling.md](admin-styling.md) |
| Docker demo | [docker.md](docker.md) |
| Engine routes | [routes.md](routes.md) |
| Security | [security.md](security.md) |
| Agent onboarding | [../../AGENTS.md](../../AGENTS.md) |

## Quick commands

```bash
bundle exec rspec                    # full suite (boots test/dummy)
bundle exec rake openapi:generate  # regen openapi/v1/swagger.yaml
```

After new engine migrations, sync to dummy (see [testing.md](testing.md) or `./setup.sh`).
