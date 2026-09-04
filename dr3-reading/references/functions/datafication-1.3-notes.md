# Datafication 1.3 implementation notes

This file is intentionally temporary and should be removed after merging the 1.3 changes into the canonical `datafication.md`.

## 1.3 changes

1. Each relation and constraint gets its own `origin` and `evidence`.
2. Do not upgrade co-mention into `requires`, `causes`, `independent_of`, or `additive` without explicit evidence.
3. Do not infer `mutually_exclusive` or `no_intermediate_state` merely from two displayed endpoints/categories.
4. Do not infer factor independence or additive effects merely because multiple factors affect an outcome.
5. Separate `scope` (where the structure exists) from `importance.role` (how important it is to the article).
6. A central structure can still have a local scope.
7. Under restricted inference, unsupported relations/constraints are omitted rather than guessed.
8. Preserve the structure-first approach from 1.2.

The canonical file must remain `references/functions/datafication.md`; Git history provides versioning.
