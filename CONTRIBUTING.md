# Contributing to n8n-nodes-brainsait

First off, thank you for considering contributing to BrainSAIT! It's people like you that make healthcare technology better for everyone.

## Code of Conduct

This project and everyone participating in it is governed by our Code of Conduct. By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When creating a bug report, include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples**
- **Describe the behavior you observed and what you expected**
- **Include screenshots if relevant**
- **Note your environment** (N8N version, Node version, OS, etc.)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Use a clear and descriptive title**
- **Provide a detailed description of the suggested enhancement**
- **Provide specific examples to demonstrate the steps**
- **Describe the current behavior and expected behavior**
- **Explain why this enhancement would be useful**

### Pull Requests

1. Fork the repo and create your branch from `main`
2. If you've added code that should be tested, add tests
3. If you've changed APIs, update the documentation
4. Ensure the test suite passes
5. Make sure your code follows the existing code style
6. Issue that pull request!

## Development Process

```bash
# 1. Clone your fork
git clone https://github.com/YOUR_USERNAME/n8n-nodes-brainsait.git
cd n8n-nodes-brainsait

# 2. Add upstream remote
git remote add upstream https://github.com/Fadil369/n8n-nodes-brainsait.git

# 3. Create a branch
git checkout -b feature/my-feature

# 4. Make your changes
# ... code code code ...

# 5. Run tests
npm test

# 6. Commit your changes
git add .
git commit -m "feat: add amazing feature"

# 7. Push to your fork
git push origin feature/my-feature

# 8. Open a Pull Request
```

## Commit Message Guidelines

We follow Conventional Commits:

- `feat:` A new feature
- `fix:` A bug fix
- `docs:` Documentation only changes
- `style:` Changes that don't affect code meaning
- `refactor:` Code change that neither fixes a bug nor adds a feature
- `perf:` Performance improvement
- `test:` Adding missing tests
- `chore:` Changes to build process or auxiliary tools

Examples:
```
feat: add drug interaction checking to CLINICALLINC
fix: resolve NPHIES claim submission timeout
docs: update installation guide for Docker deployment
refactor: improve HIPAA audit logging performance
```

## Coding Standards

### TypeScript Style

- Use TypeScript strict mode
- Prefer interfaces over types
- Use async/await over promises
- Document public APIs with JSDoc comments
- Follow existing naming conventions

### Security Requirements

- Never commit secrets or API keys
- Always validate user input
- Use parameterized queries for database operations
- Encrypt PHI data at rest and in transit
- Follow HIPAA compliance guidelines

### Testing Requirements

- Write unit tests for new features
- Maintain >80% code coverage
- Include integration tests for workflows
- Test error handling paths
- Verify HIPAA audit logging

### Documentation Requirements

- Update README.md if adding features
- Add inline code comments for complex logic
- Update API documentation
- Include usage examples
- Document breaking changes

## Healthcare-Specific Guidelines

When contributing to healthcare-related features:

1. **HIPAA Compliance**: Ensure all patient data handling follows HIPAA guidelines
2. **NPHIES Standards**: Follow Saudi NPHIES integration specifications
3. **FHIR Compatibility**: Use FHIR R4 standards for healthcare resources
4. **Medical Accuracy**: Consult with healthcare professionals for clinical features
5. **Bilingual Support**: Test Arabic and English interfaces thoroughly
6. **Accessibility**: Follow WCAG 2.1 AA standards

## Review Process

1. Automated checks must pass (tests, linting, type checking)
2. At least one core maintainer approval required
3. Security review for any authentication/authorization changes
4. HIPAA compliance review for PHI-related changes
5. Documentation review

## Community

### Questions

Feel free to ask questions in:
- [GitHub Discussions](https://github.com/Fadil369/n8n-nodes-brainsait/discussions)
- Email: dev@brainsait.com

### Regular Contributors

Regular contributors may be invited to join the core team with commit access.

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to BrainSAIT! 🏥✨

**Dr. Mohamed El Fadil**
Founder, BrainSAIT
fadil@brainsait.com
