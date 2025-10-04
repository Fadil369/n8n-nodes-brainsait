# Security Policy

## 1. Summary  
We take security seriously. If you discover a vulnerability in this project, please report it responsibly so we can fix it and protect users.

## 2. Scope  
This policy applies to:  
- The code and modules in this repository (`n8n-nodes-brainsait`)  
- Any related configuration, APIs, or infrastructure intimately linked to this repo  
- Dependencies (where feasible)  

It **does not** apply to:  
- External systems not maintained by us  
- Misconfigurations by end users in their deployment  

## 3. Reporting a Vulnerability  

### Preferred contact  
- Send an email to **security@brainsait.com** (or another secure address you control)  
- Use “Security Vulnerability Report” in the subject line  

### Information to include  
To help us triage and fix faster, please provide:  
- A clear description of the vulnerability  
- Steps to reproduce (minimal test case)  
- Affected version(s), branch, commit, or environment  
- Potential impact (data disclosure, code execution, etc.)  
- Any proof-of-concept code or exploit  
- Optional: suggestions to fix or mitigate  

### Private disclosure  
Please **do not open a public issue** or post details publicly before coordinating with us.  
We ask for a grace period to address the issue before public disclosure.

## 4. Response Process & Timelines  

| Stage | Target Time | Description |
|------|-------------|-------------|
| Acknowledgment | Within **48 hours** | We’ll confirm we’ve received your report |
| Initial triage | Within **5 business days** | Assess severity, reproduce internally |
| Fix development | Depending on severity | Develop patch or mitigation |
| Disclosure | After fix or coordination | Public advisory, release notes, credit (if desired) |

We may contact you for clarifications or updates during this process.

## 5. Disclosure & Advisory  
Once a fix is ready:  
- We’ll patch supported versions (main + recent stable branches)  
- We’ll publish a security advisory or release notes  
- We aim to credit the reporter (if they consent)  
- We’ll coordinate timing of public disclosure to balance transparency and protection  

## 6. Security Best Practices (for Contributors / Maintainers)  

- Use **least privilege access** for systems and APIs  
- Require **two-factor authentication (2FA)** for contributor accounts  
- Do **not commit secrets or credentials** in code  
- Use secret management (env vars, vaults)  
- Enable code scanning tools (e.g. CodeQL) and dependency vulnerability alerts  
- Review and audit dependencies regularly  
- Use branch protection rules (require reviews, CI checks, etc.)  
- Run security reviews or external pentests periodically  

## 7. Supported Versions & Maintenance  
We will support security fixes for the **latest stable version** and at least one prior minor version (if feasible).  
If a version is no longer maintained, we may not backport fixes.

## 8. Legal Safe Harbor  
By reporting a vulnerability in good faith, you agree not to initiate legal action, assuming ethical disclosure.  
We reserve the right to refuse or anonymize credit, or patch without disclosure when necessary.

## 9. Acknowledgments  
We may list security researchers who contributed valid reports (with permission) in a `SECURITY_ACKNOWLEDGMENTS.md` or similar file.

---

Thank you for helping keep this project secure.  
— The BrainSAIT / n8n-nodes-brainsait Team  
