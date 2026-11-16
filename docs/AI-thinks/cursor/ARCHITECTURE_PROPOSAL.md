# ARCHITECTURE_PROPOSAL — Meeting Manager (Candidate Meeting Scheduler)

> **Historical proposal.** Data access was later changed from Drizzle to Prisma — see [ADR-003](../../discussion/finally/adr/ADR-003-data-access.md).

> Status: **Planning only. No application code has been written.** Awaiting architecture review.
> Legend used throughout: **[REQ]** = explicit in the assignment · **[ASM]** = my engineering assumption · **[REC]** = my recommendation.

This proposal has been modularized and split into separate documentation files within the [architecture-proposal](./architecture-proposal/) directory for maximum readability and structured reviews.

---

## Table of Contents

### Part I: Executive & Requirements Analysis
- [01. Executive Summary](./architecture-proposal/01_executive_summary.md) — Core highlights, recommendations, and principles.
- [02. Assignment Understanding](./architecture-proposal/02_assignment_understanding.md) — Scope, deliverables, and wireframe pages.
- [03. Requirements Matrix](./architecture-proposal/03_requirements_matrix.md) — Detailed mapping of mandatory and optional requirements.
- [04. Ambiguities and Assumptions](./architecture-proposal/04_ambiguities_and_assumptions.md) — Resolving the Core vs. Wireframe mismatch, enums, timezone, and date interpretations.

### Part II: Architecture & Technology Strategy
- [05. Proposed Solution Approaches](./architecture-proposal/05_proposed_solution_approaches.md) — Evaluation of Approaches A (MVP), B (Balanced - Recommended), and C (Enterprise).
- [06. Architecture Comparison Matrix](./architecture-proposal/06_architecture_comparison_matrix.md) — Key complexity, performance, scalability, effort, and risk metrics.
- [07. Recommended Technology Stack](./architecture-proposal/07_recommended_technology_stack.md) — Concrete stack choices (Vite, TS, Tailwind, Express, Postgres, Drizzle, etc.) and justifications.

### Part III: Detailed Technical Design
- [08. System Architecture](./architecture-proposal/08_system_architecture.md) — Component layout, request lifecycles, and deployment topology diagrams.
- [09. Data Model](./architecture-proposal/09_data_model.md) — Entity-relationship diagram, field definitions, status lifecycle, and migration strategy.
- [10. API Design](./architecture-proposal/10_api_design.md) — Endpoint specifications, JSON query strings, and error schemas.
- [11. Frontend Design](./architecture-proposal/11_frontend_design.md) — Routes, UI layout hierarchy, accessibility considerations, and states.
- [12. Backend Design](./architecture-proposal/12_backend_design.md) — Express application layout, controllers, services, and optimistic concurrency locks.

### Part IV: Security, Operations, & Execution
- [13. Security Considerations](./architecture-proposal/13_security_considerations.md) — Attack vectors, CORS boundaries, and secure HTTP-Only cookie JWT auth plans.
- [14. Testing Strategy](./architecture-proposal/14_testing_strategy.md) — API integration suites, component unit tests, and the pre-submit manual QA checklist.
- [15. Docker and Deployment Strategy](./architecture-proposal/15_docker_and_deployment_strategy.md) — Multi-stage production container profiles and Docker Compose manifests.
- [16. CI/CD Strategy](./architecture-proposal/16_cicd_strategy.md) — GitHub Actions lint/type/test/build build-loops.
- [17. Seven-Day Implementation Plan](./architecture-proposal/17_seven_day_implementation_plan.md) — Daily tasks, deliverables, and definition of done check-gates.
- [18. Risks and Mitigations](./architecture-proposal/18_risks_and_mitigations.md) — Structural risks, timezone traps, and data-loss remedies.
- [19. Trade-offs and Rejected Alternatives](./architecture-proposal/19_tradeoffs_and_rejected_alternatives.md) — Critical technical decisions, technical debt targets, and interview talking-points.

### Part V: Conclusions & Supporting Matrixes
- [20. Open Questions](./architecture-proposal/20_open_questions.md) — Outstanding scope confirmations for the hiring team.
- [21. Final Recommendation](./architecture-proposal/21_final_recommendation.md) — Tactical defense of Approach B.
- [22. Architecture Decision Records](./architecture-proposal/22_architecture_decision_records.md) — ADR-001 through ADR-013.
- [23. Edge Case Matrix](./architecture-proposal/23_edge_case_matrix.md) — Complete checklist of essential safeguards and validation exceptions.
