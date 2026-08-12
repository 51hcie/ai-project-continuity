# Security policy

## Supported versions

Security fixes are applied to the latest release and the default branch.

## Reporting a vulnerability or privacy exposure

Do not open a public issue containing credentials, private data, or an exploitable vulnerability. Use GitHub's **Report a vulnerability** feature on the repository Security page. If that feature is unavailable, contact the maintainer privately through the GitHub profile without including the secret itself.

If a real credential was committed, revoke or rotate it immediately. Removing a file or making a new commit does not remove the value from Git history.

Please include:

- the affected version or commit;
- impact and reproduction steps using synthetic data;
- any suggested remediation;
- whether the issue is already public.

Expect acknowledgement within seven days and a status update within fourteen days. Timelines may vary for a volunteer-maintained project.

## Scope and limitations

The included validator catches a narrow set of common secret-shaped strings, sensitive filenames, and machine-specific paths. False negatives and false positives are possible. It is a guardrail, not a substitute for code review, least-privilege credentials, history scanning, or a dedicated secret scanner.
