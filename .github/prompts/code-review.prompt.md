---
mode: agent
model: gpt-4
tools: ['codebase', 'search', 'problems', 'changes']
description: 'Comprehensive code review with Python best practices focus'
---

# Systematic Code Review Workflow

## Context Loading Phase
1. Review [Python instructions](../instructions/python.instructions.md)
2. Check [pyproject.toml](../../pyproject.toml) for configuration
3. Review [CONTRIBUTING.md](../../CONTRIBUTING.md)

## Review Categories

### 1. Code Quality Assessment
Evaluate the code for:
- [ ] Adherence to PEP 8 and project style (black, isort)
- [ ] Proper type hinting (mypy compliance)
- [ ] Code readability and docstring quality
- [ ] Appropriate use of Python idioms

### 2. Security Analysis
Check for common vulnerabilities:
- [ ] Input validation for CLI args
- [ ] Safe file handling
- [ ] Secret management
- [ ] Subprocess safety (avoid `shell=True` where possible)

### 3. Testing Coverage
Validate testing approach:
- [ ] Unit test coverage for new logic
- [ ] Integration test scenarios
- [ ] Use of pytest fixtures and parametrization

## Review Output Structure
Provide findings in this format:

### Critical Issues (Must Fix)
- **Issue**: [Description]
- **Risk**: [Impact]
- **Solution**: [Specific remediation]
- **Code Location**: [File and line references]

### Recommendations (Should Fix)
- **Improvement**: [Description]
- **Benefit**: [Expected improvement]
- **Implementation**: [Suggested approach]

### Observations (Consider)
- **Pattern**: [Code pattern observed]
- **Alternative**: [Potential improvement]
