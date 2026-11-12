# 6. Architecture Comparison Matrix

Effort estimates assume one experienced full-stack dev, focused hours, ±30% uncertainty.

| Dimension | A — Minimal | B — Balanced | C — Extensible |
|---|---|---|---|
| Dev complexity | Low | Medium | High |
| Effort | ~2–3 days | ~5–6 days (+1 buffer) | 9–12 days |
| Maintainability | Fair (single file sprawl) | Good | Very good *if* it grows; otherwise ceremony |
| Testability | Low–Med | High | High (but more mocks) |
| Deployment complexity | Very low | Low–Med (3 containers) | High |
| Performance | Fine | Fine | Fine (cache unneeded) |
| Security | Basic | Good (validation, helmet, CORS, rate limit) | Good+ (RBAC) |
| Scalability | Poor | Adequate (stateless API, indexed DB) | High but unneeded |
| Wireframe coverage | Weak | Full | Full |
| Main risk | Looks under-engineered; ignores wireframes | Time pressure on bonus items | Overengineering; unfinished core |
| Interview story | "Got it working" | "Pragmatic, structured, tested, deployed" | "Overbuilt" |
