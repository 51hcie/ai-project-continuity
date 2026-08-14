# Resource availability

Record only how a non-public input can be obtained. Never record the value itself.

| Resource | Safe locator | Scope or owner | Check before asking |
| --- | --- | --- | --- |
| Repository access | `gh auth status` | Maintainer account | Run the command in the current environment |
| Deployment configuration | Names from `.env.example` | Deployment role | Check the environment or credential helper |

## Rules

- Use logical names, commands, secret-manager references, or repository-relative locations only.
- Keep tokens, passwords, keys, customer data, host addresses, and absolute paths outside Git.
- If a locator is unavailable, ask the user to provide the resource again at action time.
