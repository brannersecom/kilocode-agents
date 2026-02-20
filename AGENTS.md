# AGENTS.md instructions for Multi-Agent

<INSTRUCTIONS>
Codex Base Agent System

Scope: Repository root and all subfolders.

Source of truth
- Canonical plugin catalog: `.claude-plugin/marketplace.json`
- Kilo adapter output: `.kilocodemodes` (generated)
- Codex adapter outputs: `AGENTS.md`, `.codex/registry.json`, `.codex/*-index.md` (generated)

Generation commands
- Regenerate Kilo modes: `python scripts/generate_kilocodemodes.py`
- Regenerate Codex assets: `python scripts/generate_codex_assets.py`

Codex working rules
- Prefer plugin assets under `plugins/*` as canonical content.
- Use `.codex/registry.json` for discovery and `.codex/*-index.md` for quick lookup.
- Keep adapters generated; do not hand-edit generated files.
- For new work, update plugin sources first, then regenerate adapters.

## Skills
A skill is a set of local instructions stored in a `SKILL.md` file.
### Available skills
- api-design-principles: Master REST and GraphQL API design principles to build intuitive, scalable, and maintainable APIs that delight developers. Use when desig... (plugin: `backend-development`, file: `plugins/backend-development/skills/api-design-principles/SKILL.md`)
- architecture-patterns: Implement proven backend architecture patterns including Clean Architecture, Hexagonal Architecture, and Domain-Driven Design. Use when a... (plugin: `backend-development`, file: `plugins/backend-development/skills/architecture-patterns/SKILL.md`)
- microservices-patterns: Design microservices architectures with service boundaries, event-driven communication, and resilience patterns. Use when building distri... (plugin: `backend-development`, file: `plugins/backend-development/skills/microservices-patterns/SKILL.md`)
- workflow-orchestration-patterns: Design durable workflows with Temporal for distributed systems. Covers workflow vs activity separation, saga patterns, state management,... (plugin: `backend-development`, file: `plugins/backend-development/skills/workflow-orchestration-patterns/SKILL.md`)
- temporal-python-testing: Test Temporal workflows with pytest, time-skipping, and mocking strategies. Covers unit testing, integration testing, replay testing, and... (plugin: `backend-development`, file: `plugins/backend-development/skills/temporal-python-testing/SKILL.md`)
- langchain-architecture: Design LLM applications using the LangChain framework with agents, memory, and tool integration patterns. Use when building LangChain app... (plugin: `llm-application-dev`, file: `plugins/llm-application-dev/skills/langchain-architecture/SKILL.md`)
- llm-evaluation: Implement comprehensive evaluation strategies for LLM applications using automated metrics, human feedback, and benchmarking. Use when te... (plugin: `llm-application-dev`, file: `plugins/llm-application-dev/skills/llm-evaluation/SKILL.md`)
- prompt-engineering-patterns: Master advanced prompt engineering techniques to maximize LLM performance, reliability, and controllability in production. Use when optim... (plugin: `llm-application-dev`, file: `plugins/llm-application-dev/skills/prompt-engineering-patterns/SKILL.md`)
- rag-implementation: Build Retrieval-Augmented Generation (RAG) systems for LLM applications with vector databases and semantic search. Use when implementing... (plugin: `llm-application-dev`, file: `plugins/llm-application-dev/skills/rag-implementation/SKILL.md`)
- ml-pipeline-workflow: Build end-to-end MLOps pipelines from data preparation through model training, validation, and production deployment. Use when creating M... (plugin: `machine-learning-ops`, file: `plugins/machine-learning-ops/skills/ml-pipeline-workflow/SKILL.md`)
- distributed-tracing: Implement distributed tracing with Jaeger and Tempo to track requests across microservices and identify performance bottlenecks. Use when... (plugin: `observability-monitoring`, file: `plugins/observability-monitoring/skills/distributed-tracing/SKILL.md`)
- grafana-dashboards: Create and manage production Grafana dashboards for real-time visualization of system and application metrics. Use when building monitori... (plugin: `observability-monitoring`, file: `plugins/observability-monitoring/skills/grafana-dashboards/SKILL.md`)
- prometheus-configuration: Set up Prometheus for comprehensive metric collection, storage, and monitoring of infrastructure and applications. Use when implementing... (plugin: `observability-monitoring`, file: `plugins/observability-monitoring/skills/prometheus-configuration/SKILL.md`)
- slo-implementation: Define and implement Service Level Indicators (SLIs) and Service Level Objectives (SLOs) with error budgets and alerting. Use when establ... (plugin: `observability-monitoring`, file: `plugins/observability-monitoring/skills/slo-implementation/SKILL.md`)
- gitops-workflow: Implement GitOps workflows with ArgoCD and Flux for automated, declarative Kubernetes deployments with continuous reconciliation. Use whe... (plugin: `kubernetes-operations`, file: `plugins/kubernetes-operations/skills/gitops-workflow/SKILL.md`)
- helm-chart-scaffolding: Design, organize, and manage Helm charts for templating and packaging Kubernetes applications with reusable configurations. Use when crea... (plugin: `kubernetes-operations`, file: `plugins/kubernetes-operations/skills/helm-chart-scaffolding/SKILL.md`)
- k8s-manifest-generator: Create production-ready Kubernetes manifests for Deployments, Services, ConfigMaps, and Secrets following best practices and security sta... (plugin: `kubernetes-operations`, file: `plugins/kubernetes-operations/skills/k8s-manifest-generator/SKILL.md`)
- k8s-security-policies: Implement Kubernetes security policies including NetworkPolicy, PodSecurityPolicy, and RBAC for production-grade security. Use when secur... (plugin: `kubernetes-operations`, file: `plugins/kubernetes-operations/skills/k8s-security-policies/SKILL.md`)
- cost-optimization: Optimize cloud costs through resource rightsizing, tagging strategies, reserved instances, and spending analysis. Use when reducing cloud... (plugin: `cloud-infrastructure`, file: `plugins/cloud-infrastructure/skills/cost-optimization/SKILL.md`)
- hybrid-cloud-networking: Configure secure, high-performance connectivity between on-premises infrastructure and cloud platforms using VPN and dedicated connection... (plugin: `cloud-infrastructure`, file: `plugins/cloud-infrastructure/skills/hybrid-cloud-networking/SKILL.md`)
- multi-cloud-architecture: Design multi-cloud architectures using a decision framework to select and integrate services across AWS, Azure, and GCP. Use when buildin... (plugin: `cloud-infrastructure`, file: `plugins/cloud-infrastructure/skills/multi-cloud-architecture/SKILL.md`)
- terraform-module-library: Build reusable Terraform modules for AWS, Azure, and GCP infrastructure following infrastructure-as-code best practices. Use when creatin... (plugin: `cloud-infrastructure`, file: `plugins/cloud-infrastructure/skills/terraform-module-library/SKILL.md`)
- deployment-pipeline-design: Design multi-stage CI/CD pipelines with approval gates, security checks, and deployment orchestration. Use when architecting deployment w... (plugin: `cicd-automation`, file: `plugins/cicd-automation/skills/deployment-pipeline-design/SKILL.md`)
- github-actions-templates: Create production-ready GitHub Actions workflows for automated testing, building, and deploying applications. Use when setting up CI/CD w... (plugin: `cicd-automation`, file: `plugins/cicd-automation/skills/github-actions-templates/SKILL.md`)
- gitlab-ci-patterns: Build GitLab CI/CD pipelines with multi-stage workflows, caching, and distributed runners for scalable automation. Use when implementing... (plugin: `cicd-automation`, file: `plugins/cicd-automation/skills/gitlab-ci-patterns/SKILL.md`)
- secrets-management: Implement secure secrets management for CI/CD pipelines using Vault, AWS Secrets Manager, or native platform solutions. Use when handling... (plugin: `cicd-automation`, file: `plugins/cicd-automation/skills/secrets-management/SKILL.md`)
- angular-migration: Migrate from AngularJS to Angular using hybrid mode, incremental component rewriting, and dependency injection updates. Use when upgradin... (plugin: `framework-migration`, file: `plugins/framework-migration/skills/angular-migration/SKILL.md`)
- database-migration: Execute database migrations across ORMs and platforms with zero-downtime strategies, data transformation, and rollback procedures. Use wh... (plugin: `framework-migration`, file: `plugins/framework-migration/skills/database-migration/SKILL.md`)
- dependency-upgrade: Manage major dependency version upgrades with compatibility analysis, staged rollout, and comprehensive testing. Use when upgrading frame... (plugin: `framework-migration`, file: `plugins/framework-migration/skills/dependency-upgrade/SKILL.md`)
- react-modernization: Upgrade React applications to latest versions, migrate from class components to hooks, and adopt concurrent features. Use when modernizin... (plugin: `framework-migration`, file: `plugins/framework-migration/skills/react-modernization/SKILL.md`)
- postgresql-table-design: Design a PostgreSQL-specific schema. Covers best-practices, data types, indexing, constraints, performance patterns, and advanced features (plugin: `database-design`, file: `plugins/database-design/skills/postgresql/SKILL.md`)
- sast-configuration: Configure Static Application Security Testing (SAST) tools for automated vulnerability detection in application code. Use when setting up... (plugin: `security-scanning`, file: `plugins/security-scanning/skills/sast-configuration/SKILL.md`)
- fastapi-templates: Create production-ready FastAPI projects with async patterns, dependency injection, and comprehensive error handling. Use when building n... (plugin: `api-scaffolding`, file: `plugins/api-scaffolding/skills/fastapi-templates/SKILL.md`)
- defi-protocol-templates: Implement DeFi protocols with production-ready templates for staking, AMMs, governance, and lending systems. Use when building decentrali... (plugin: `blockchain-web3`, file: `plugins/blockchain-web3/skills/defi-protocol-templates/SKILL.md`)
- nft-standards: Implement NFT standards (ERC-721, ERC-1155) with proper metadata handling, minting strategies, and marketplace integration. Use when crea... (plugin: `blockchain-web3`, file: `plugins/blockchain-web3/skills/nft-standards/SKILL.md`)
- solidity-security: Master smart contract security best practices to prevent common vulnerabilities and implement secure Solidity patterns. Use when writing... (plugin: `blockchain-web3`, file: `plugins/blockchain-web3/skills/solidity-security/SKILL.md`)
- web3-testing: Test smart contracts comprehensively using Hardhat and Foundry with unit tests, integration tests, and mainnet forking. Use when testing... (plugin: `blockchain-web3`, file: `plugins/blockchain-web3/skills/web3-testing/SKILL.md`)
- billing-automation: Build automated billing systems for recurring payments, invoicing, subscription lifecycle, and dunning management. Use when implementing... (plugin: `payment-processing`, file: `plugins/payment-processing/skills/billing-automation/SKILL.md`)
- paypal-integration: Integrate PayPal payment processing with support for express checkout, subscriptions, and refund management. Use when implementing PayPal... (plugin: `payment-processing`, file: `plugins/payment-processing/skills/paypal-integration/SKILL.md`)
- pci-compliance: Implement PCI DSS compliance requirements for secure handling of payment card data and payment systems. Use when securing payment process... (plugin: `payment-processing`, file: `plugins/payment-processing/skills/pci-compliance/SKILL.md`)
- stripe-integration: Implement Stripe payment processing for robust, PCI-compliant payment flows including checkout, subscriptions, and webhooks. Use when int... (plugin: `payment-processing`, file: `plugins/payment-processing/skills/stripe-integration/SKILL.md`)
- async-python-patterns: Master Python asyncio, concurrent programming, and async/await patterns for high-performance applications. Use when building async APIs,... (plugin: `python-development`, file: `plugins/python-development/skills/async-python-patterns/SKILL.md`)
- python-testing-patterns: Implement comprehensive testing strategies with pytest, fixtures, mocking, and test-driven development. Use when writing Python tests, se... (plugin: `python-development`, file: `plugins/python-development/skills/python-testing-patterns/SKILL.md`)
- python-packaging: Create distributable Python packages with proper project structure, setup.py/pyproject.toml, and publishing to PyPI. Use when packaging P... (plugin: `python-development`, file: `plugins/python-development/skills/python-packaging/SKILL.md`)
- python-performance-optimization: Profile and optimize Python code using cProfile, memory profilers, and performance best practices. Use when debugging slow Python code, o... (plugin: `python-development`, file: `plugins/python-development/skills/python-performance-optimization/SKILL.md`)
- uv-package-manager: Master the uv package manager for fast Python dependency management, virtual environments, and modern Python project workflows. Use when... (plugin: `python-development`, file: `plugins/python-development/skills/uv-package-manager/SKILL.md`)
- typescript-advanced-types: Master TypeScript's advanced type system including generics, conditional types, mapped types, template literals, and utility types for bu... (plugin: `javascript-typescript`, file: `plugins/javascript-typescript/skills/typescript-advanced-types/SKILL.md`)
- nodejs-backend-patterns: Build production-ready Node.js backend services with Express/Fastify, implementing middleware patterns, error handling, authentication, d... (plugin: `javascript-typescript`, file: `plugins/javascript-typescript/skills/nodejs-backend-patterns/SKILL.md`)
- javascript-testing-patterns: Implement comprehensive testing strategies using Jest, Vitest, and Testing Library for unit tests, integration tests, and end-to-end test... (plugin: `javascript-typescript`, file: `plugins/javascript-typescript/skills/javascript-testing-patterns/SKILL.md`)
- modern-javascript-patterns: Master ES6+ features including async/await, destructuring, spread operators, arrow functions, promises, modules, iterators, generators, a... (plugin: `javascript-typescript`, file: `plugins/javascript-typescript/skills/modern-javascript-patterns/SKILL.md`)
- bash-defensive-patterns: Master defensive Bash programming techniques for production-grade scripts. Use when writing robust shell scripts, CI/CD pipelines, or sys... (plugin: `shell-scripting`, file: `plugins/shell-scripting/skills/bash-defensive-patterns/SKILL.md`)
- shellcheck-configuration: Master ShellCheck static analysis configuration and usage for shell script quality. Use when setting up linting infrastructure, fixing co... (plugin: `shell-scripting`, file: `plugins/shell-scripting/skills/shellcheck-configuration/SKILL.md`)
- bats-testing-patterns: Master Bash Automated Testing System (Bats) for comprehensive shell script testing. Use when writing tests for shell scripts, CI/CD pipel... (plugin: `shell-scripting`, file: `plugins/shell-scripting/skills/bats-testing-patterns/SKILL.md`)
- git-advanced-workflows: Master advanced Git workflows including rebasing, cherry-picking, bisect, worktrees, and reflog to maintain clean history and recover fro... (plugin: `developer-essentials`, file: `plugins/developer-essentials/skills/git-advanced-workflows/SKILL.md`)
- sql-optimization-patterns: Master SQL query optimization, indexing strategies, and EXPLAIN analysis to dramatically improve database performance and eliminate slow... (plugin: `developer-essentials`, file: `plugins/developer-essentials/skills/sql-optimization-patterns/SKILL.md`)
- error-handling-patterns: Master error handling patterns across languages including exceptions, Result types, error propagation, and graceful degradation to build... (plugin: `developer-essentials`, file: `plugins/developer-essentials/skills/error-handling-patterns/SKILL.md`)
- code-review-excellence: Master effective code review practices to provide constructive feedback, catch bugs early, and foster knowledge sharing while maintaining... (plugin: `developer-essentials`, file: `plugins/developer-essentials/skills/code-review-excellence/SKILL.md`)
- e2e-testing-patterns: Master end-to-end testing with Playwright and Cypress to build reliable test suites that catch bugs, improve confidence, and enable fast... (plugin: `developer-essentials`, file: `plugins/developer-essentials/skills/e2e-testing-patterns/SKILL.md`)
- auth-implementation-patterns: Master authentication and authorization patterns including JWT, OAuth2, session management, and RBAC to build secure, scalable access con... (plugin: `developer-essentials`, file: `plugins/developer-essentials/skills/auth-implementation-patterns/SKILL.md`)
- debugging-strategies: Master systematic debugging techniques, profiling tools, and root cause analysis to efficiently track down bugs across any codebase or te... (plugin: `developer-essentials`, file: `plugins/developer-essentials/skills/debugging-strategies/SKILL.md`)
- monorepo-management: Master monorepo management with Turborepo, Nx, and pnpm workspaces to build efficient, scalable multi-package repositories with optimized... (plugin: `developer-essentials`, file: `plugins/developer-essentials/skills/monorepo-management/SKILL.md`)
### How to use skills
- Trigger when the user names a skill or the task clearly matches a skill description.
- Open only the specific `SKILL.md` file needed for the current task.
- Resolve relative references in the skill file relative to its folder first.
- Prefer scripts/assets in a skill directory over rewriting large blocks manually.
- Keep context lean by loading only files required for the current request.
</INSTRUCTIONS>
