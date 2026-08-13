# Reusable prompts

Keep only tested, project-specific prompts that will be reused. Prompts should point to facts that are traceable inside the repository and must not contain secrets, personal information, or short-lived work state.

Name prompt files with a lowercase verb and noun, for example `review-api.md`. Keep this index current so a new contributor can discover prompts without scanning the directory.

| Prompt | When to use | Inputs | Expected output |
| --- | --- | --- | --- |
| [`_template.md`](_template.md) | Copy when adding a reviewed prompt | Repository facts named by the prompt | The format stated by the prompt |
