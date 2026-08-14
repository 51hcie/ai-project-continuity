# Resource availability

This example records safe ways to check for non-public inputs without storing their values.

| Resource | Safe locator | Scope or owner | Check before asking |
| --- | --- | --- | --- |
| Repository access | `gh auth status` | Maintainer account | Run the command in the current environment |
| Local configuration | Names from `.env.example` | Local developer | Check the environment or credential helper |

Values, keys, customer data, host addresses, and absolute paths remain outside the repository.
