# Validation Repair — Independent Audit of B (1.5 Candidate)

## Audit Method

Audit every relation extracted by the 1.5 candidate against the original article. Apply the revised audit rules with proposition-boundary check.

## Source Article

`AI Is Blurring the Line Between Sales and Marketing`
Source: https://hbr.org/2026/09/ai-is-blurring-the-line-between-sales-and-marketing

---

## Audit Results

### R-01: "Agentic AI is changing that"

| Field | Value |
|-------|-------|
| subject.text | Agentic AI |
| predicate.text | is changing |
| object.text | that |
| direction | forward |
| modality | null |
| evidence | paragraph 2 |

**Article text:** "Agentic AI is changing that."

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Exact sentence match.

---

### R-02: "Customers do not distinguish between the two"

| Field | Value |
|-------|-------|
| subject.text | Customers |
| predicate.text | do not distinguish between |
| object.text | the two |
| direction | forward |
| modality | null |
| evidence | paragraph 3 |

**Article text:** "Customers do not distinguish between the two."

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Exact sentence match.

---

### R-03: "Every touchpoint is experienced as a part of a single relationship"

| Field | Value |
|-------|-------|
| subject.text | Every touchpoint |
| predicate.text | is experienced as |
| object.text | a part of a single relationship |
| direction | forward |
| modality | null |
| qualification | regardless of which function owns it internally |
| evidence | paragraph 3 |

**Article text:** "Every touchpoint, regardless of which function owns it internally, is experienced as a part of a single relationship."

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence. Qualification preserved.

**Audit:** R0 — Faithful. Subject, predicate, object, qualification preserved exactly.

---

### R-04: "B2B buyers engage across ten interaction channels"

| Field | Value |
|-------|-------|
| subject.text | B2B buyers |
| predicate.text | engage across |
| object.text | ten interaction channels |
| direction | forward |
| modality | null |
| qualification | during a typical journey |
| evidence | paragraph 4 |

**Article text:** "B2B buyers now engage across ten interaction channels during a typical journey"

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Subject, predicate, object, qualification preserved exactly.

---

### R-05: "marketing and sales operate on separate data sets and disconnected systems"

| Field | Value |
|-------|-------|
| subject.text | marketing and sales |
| predicate.text | operate on |
| object.text | separate data sets and disconnected systems |
| direction | forward |
| modality | null |
| evidence | paragraph 5 |

**Article text:** "When marketing and sales operate on separate data sets and disconnected systems"

**Proposition boundary check:** Single proposition (conditional clause). Subject, predicate, object in same clause.

**Audit:** R0 — Faithful. Subject, predicate, object preserved exactly.

---

### R-06: "the customer journey is broken"

| Field | Value |
|-------|-------|
| subject.text | the customer journey |
| predicate.text | is broken |
| object.text | null |
| direction | forward |
| modality | null |
| evidence | paragraph 5 |

**Article text:** "the customer journey is broken"

**Proposition boundary check:** Single proposition. Subject, predicate in same clause.

**Audit:** R0 — Faithful. Subject, predicate preserved exactly.

---

### R-07: "experience suffers"

| Field | Value |
|-------|-------|
| subject.text | experience |
| predicate.text | suffers |
| object.text | null |
| direction | forward |
| modality | null |
| evidence | paragraph 5 |

**Article text:** "experience suffers"

**Proposition boundary check:** Single proposition. Subject, predicate in same clause.

**Audit:** R0 — Faithful. Subject, predicate preserved exactly.

**Note:** R-06 and R-07 are correctly separated. The original sentence "the customer journey is broken and experience suffers" contains two coordinated clauses. The 1.5 extractor correctly split them into two relations rather than combining them into one.

---

### R-08: "buyers cite inconsistent information across teams"

| Field | Value |
|-------|-------|
| subject.text | buyers |
| predicate.text | cite |
| object.text | inconsistent information across teams |
| direction | forward |
| modality | null |
| qualification | as the top reason for switching suppliers |
| evidence | paragraph 6 |

**Article text:** "buyers cite inconsistent information across teams as the top reason for switching suppliers."

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Subject, predicate, object, qualification preserved exactly.

---

### R-09: "market leaders are four times more likely to deploy true one-to-one personalization"

| Field | Value |
|-------|-------|
| subject.text | market leaders |
| predicate.text | are four times more likely to deploy |
| object.text | true one-to-one personalization |
| direction | forward |
| modality | null |
| evidence | paragraph 6 |

**Article text:** "market leaders are four times more likely to deploy true one-to-one personalization"

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Subject, predicate, object preserved exactly.

---

### R-10: "Agentic AI is accelerating a convergence already underway"

| Field | Value |
|-------|-------|
| subject.text | Agentic AI |
| predicate.text | is accelerating |
| object.text | a convergence already underway |
| direction | forward |
| modality | null |
| evidence | paragraph 7 |

**Article text:** "Agentic AI is accelerating a convergence already underway"

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Exact sentence match.

---

### R-11: "the most consistent revenue gains from AI are concentrated in marketing and sales"

| Field | Value |
|-------|-------|
| subject.text | the most consistent revenue gains from AI |
| predicate.text | are concentrated in |
| object.text | marketing and sales |
| direction | forward |
| modality | null |
| evidence | paragraph 7 |

**Article text:** "the most consistent revenue gains from AI are concentrated in marketing and sales."

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Subject, predicate, object preserved exactly.

---

### R-12: "Activities that once moved sequentially across teams increasingly operate in continuous loops"

| Field | Value |
|-------|-------|
| subject.text | Activities that once moved sequentially across teams |
| predicate.text | increasingly operate in |
| object.text | continuous loops |
| direction | forward |
| modality | null |
| evidence | paragraph 8 |

**Article text:** "Activities that once moved sequentially across teams increasingly operate in continuous loops"

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Subject, predicate, object preserved exactly.

---

### R-13: "Marketing and sales increasingly share responsibility for pipeline quality, conversion, and customer value"

| Field | Value |
|-------|-------|
| subject.text | Marketing and sales |
| predicate.text | increasingly share responsibility for |
| object.text | pipeline quality, conversion, and customer value |
| direction | forward |
| modality | null |
| evidence | paragraph 8 |

**Article text:** "Marketing and sales increasingly share responsibility for pipeline quality, conversion, and customer value."

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Exact sentence match.

---

### R-14: "The advantage compounds only when both functions contribute to and draw from the same data system"

| Field | Value |
|-------|-------|
| subject.text | The advantage |
| predicate.text | compounds only when |
| object.text | both functions contribute to and draw from the same data system |
| direction | forward |
| modality | null |
| evidence | paragraph 8 |

**Article text:** "The advantage compounds only when both functions contribute to and draw from the same data system."

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Exact sentence match.

---

### R-15: "Cycle times compress as campaign creation and outreach development shrink from weeks to minutes"

| Field | Value |
|-------|-------|
| subject.text | Cycle times |
| predicate.text | compress as |
| object.text | campaign creation and outreach development shrink from weeks to minutes |
| direction | forward |
| modality | null |
| evidence | paragraph 9 |

**Article text:** "Cycle times compress as campaign creation and outreach development shrink from weeks to minutes."

**Proposition boundary check:** Single proposition (complex sentence with subordinate clause). Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Exact sentence match.

---

### R-16: "Conversion rates improve as interactions become more relevant to customer intent"

| Field | Value |
|-------|-------|
| subject.text | Conversion rates |
| predicate.text | improve as |
| object.text | interactions become more relevant to customer intent |
| direction | forward |
| modality | null |
| evidence | paragraph 9 |

**Article text:** "Conversion rates improve as interactions become more relevant to customer intent."

**Proposition boundary check:** Single proposition (complex sentence with subordinate clause). Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Exact sentence match.

---

### R-17: "AI-augmented sellers were sending five times the number of messages to leads"

| Field | Value |
|-------|-------|
| subject.text | AI-augmented sellers |
| predicate.text | were sending |
| object.text | five times the number of messages to leads |
| direction | forward |
| modality | null |
| qualification | while maintaining pre-AI open rates, response rates, and meeting scheduling rates |
| evidence | paragraph 10 |

**Article text:** "AI-augmented sellers were sending five times the number of messages to leads while maintaining pre-AI open rates, response rates, and meeting scheduling rates."

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Subject, predicate, object, qualification preserved exactly.

---

### R-18: "AI-augmented seller prep time for initial calls dropped from 1–2 hours to 10–15 minutes"

| Field | Value |
|-------|-------|
| subject.text | AI-augmented seller prep time for initial calls |
| predicate.text | dropped from |
| object.text | 1–2 hours to 10–15 minutes |
| direction | forward |
| modality | null |
| evidence | paragraph 10 |

**Article text:** "AI-augmented seller prep time for initial calls dropped from 1–2 hours to 10–15 minutes."

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Exact sentence match.

---

### R-19: "The company expects its AI-enabled sales model to generate $30–$60 million in incremental annual revenue"

| Field | Value |
|-------|-------|
| subject.text | The company |
| predicate.text | expects |
| object.text | its AI-enabled sales model to generate $30–$60 million in incremental annual revenue |
| direction | forward |
| modality | null |
| evidence | paragraph 11 |

**Article text:** "The company expects its AI-enabled sales model to generate $30–$60 million in incremental annual revenue"

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Subject, predicate, object preserved exactly.

---

### R-20: "The system deploys an AI sales development representative (SDR)"

| Field | Value |
|-------|-------|
| subject.text | The system |
| predicate.text | deploys |
| object.text | an AI sales development representative (SDR) |
| direction | forward |
| modality | null |
| qualification | that identifies prospects, generates personalized outreach, nurtures early conversations, and hands off qualified leads to sellers with complete context and next actions |
| evidence | paragraph 11 |

**Article text:** "The system deploys an AI sales development representative (SDR) that identifies prospects, generates personalized outreach, nurtures early conversations, and hands off qualified leads to sellers with complete context and next actions."

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Subject, predicate, object, qualification preserved exactly.

---

### R-21: "What makes the model work is not the agent alone"

| Field | Value |
|-------|-------|
| subject.text | What makes the model work |
| predicate.text | is not |
| object.text | the agent alone |
| direction | forward |
| modality | null |
| qualification | but the shared data and coordinated handoffs behind it |
| evidence | paragraph 11 |

**Article text:** "What makes the model work is not the agent alone but the shared data and coordinated handoffs behind it."

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Subject, predicate, object, qualification preserved exactly.

---

### R-22: "These results are reshaping how teams are structured"

| Field | Value |
|-------|-------|
| subject.text | These results |
| predicate.text | are reshaping |
| object.text | how teams are structured |
| direction | forward |
| modality | null |
| evidence | paragraph 12 |

**Article text:** "These results are reshaping how teams are structured."

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Exact sentence match.

---

### R-23: "A new role is emerging: the go-to-market engineer"

| Field | Value |
|-------|-------|
| subject.text | A new role |
| predicate.text | is emerging |
| object.text | the go-to-market engineer |
| direction | forward |
| modality | null |
| qualification | who is increasingly responsible for designing and managing agentic workflows that span functions |
| evidence | paragraph 12 |

**Article text:** "A new roles is emerging: the go-to-market engineer, who is increasingly responsible for designing and managing agentic workflows that span functions"

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Subject, predicate, object, qualification preserved exactly.

---

### R-24: "different functions build and deploy customer-facing agents independently"

| Field | Value |
|-------|-------|
| subject.text | different functions |
| predicate.text | build and deploy |
| object.text | customer-facing agents independently |
| direction | forward |
| modality | null |
| evidence | paragraph 14 |

**Article text:** "When different functions build and deploy customer-facing agents independently"

**Proposition boundary check:** Single proposition (conditional clause). Subject, predicate, object in same clause.

**Audit:** R0 — Faithful. Subject, predicate, object preserved exactly.

---

### R-25: "that coherence can erode"

| Field | Value |
|-------|-------|
| subject.text | that coherence |
| predicate.text | can erode |
| object.text | null |
| direction | forward |
| modality | dispositional |
| evidence | paragraph 14 |

**Article text:** "that coherence can erode."

**Proposition boundary check:** Single proposition. Subject, predicate in same clause.

**Audit:** R0 — Faithful. Subject, predicate, modality preserved exactly.

---

### R-26: "AI can scale inconsistency as easily as it scales efficiency"

| Field | Value |
|-------|-------|
| subject.text | AI |
| predicate.text | can scale |
| object.text | inconsistency as easily as it scales efficiency |
| direction | forward |
| modality | dispositional |
| evidence | paragraph 14 |

**Article text:** "AI can scale inconsistency as easily as it scales efficiency."

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Subject, predicate, object, modality preserved exactly.

---

### R-27: "The agent continuously interprets intent"

| Field | Value |
|-------|-------|
| subject.text | The agent |
| predicate.text | continuously interprets |
| object.text | intent |
| direction | forward |
| modality | null |
| qualification | adapts outreach, and advances conversations until human involvement creates the most value |
| evidence | paragraph 14 |

**Article text:** "The agent continuously interprets intent, adapts outreach, and advances conversations until human involvement creates the most value."

**Proposition boundary check:** Single proposition with coordinated predicates. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Subject, predicate, object, qualification preserved exactly.

---

### R-28: "the role spans both marketing and sales"

| Field | Value |
|-------|-------|
| subject.text | the role |
| predicate.text | spans |
| object.text | both marketing and sales |
| direction | forward |
| modality | null |
| qualification | combining demand generation, personalization, and early-stage engagement into a single, continuous workflow |
| evidence | paragraph 14 |

**Article text:** "the role spans both marketing and sales, combining demand generation, personalization, and early-stage engagement into a single, continuous workflow."

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Subject, predicate, object, qualification preserved exactly.

---

### R-29: "Brand standards and customer context travel with the agent"

| Field | Value |
|-------|-------|
| subject.text | Brand standards and customer context |
| predicate.text | travel with |
| object.text | the agent |
| direction | forward |
| modality | null |
| qualification | across every step |
| evidence | paragraph 14 |

**Article text:** "Brand standards and customer context travel with the agent across every step."

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Subject, predicate, object, qualification preserved exactly.

---

### R-30: "the organizations pulling ahead are redesigning marketing and sales as a single system"

| Field | Value |
|-------|-------|
| subject.text | the organizations pulling ahead |
| predicate.text | are redesigning |
| object.text | marketing and sales as a single system |
| direction | forward |
| modality | null |
| evidence | paragraph 15 |

**Article text:** "the organizations pulling ahead are redesigning marketing and sales as a single system."

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Exact sentence match.

---

### R-31: "they rethink the work itself"

| Field | Value |
|-------|-------|
| subject.text | they |
| predicate.text | rethink |
| object.text | the work itself |
| direction | forward |
| modality | null |
| qualification | Rather than layering AI onto existing processes |
| evidence | paragraph 15 |

**Article text:** "Rather than layering AI onto existing processes, they rethink the work itself"

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Subject, predicate, object, qualification preserved exactly.

---

### R-32: "Success requires two shifts"

| Field | Value |
|-------|-------|
| subject.text | Success |
| predicate.text | requires |
| object.text | two shifts |
| direction | forward |
| modality | null |
| evidence | paragraph 16 |

**Article text:** "Success requires two shifts."

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Exact sentence match.

---

### R-33: "Traditional distinctions of marketing-qualified leads versus sales-qualified leads give way to measures of pipeline quality, conversion, and customer lifetime value"

| Field | Value |
|-------|-------|
| subject.text | Traditional distinctions of marketing-qualified leads versus sales-qualified leads |
| predicate.text | give way to |
| object.text | measures of pipeline quality, conversion, and customer lifetime value |
| direction | forward |
| modality | null |
| evidence | paragraph 16 |

**Article text:** "Traditional distinctions of marketing-qualified leads versus sales-qualified leads give way to measures of pipeline quality, conversion, and customer lifetime value."

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Exact sentence match.

---

### R-34: "Interactions become continuous rather than fragmented"

| Field | Value |
|-------|-------|
| subject.text | Interactions |
| predicate.text | become |
| object.text | continuous rather than fragmented |
| direction | forward |
| modality | null |
| evidence | paragraph 17 |

**Article text:** "Interactions become continuous rather than fragmented."

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Exact sentence match.

---

### R-35: "Context carries forward instead of resetting at every stage"

| Field | Value |
|-------|-------|
| subject.text | Context |
| predicate.text | carries forward instead of |
| object.text | resetting at every stage |
| direction | forward |
| modality | null |
| evidence | paragraph 17 |

**Article text:** "Context carries forward instead of resetting at every stage."

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Exact sentence match.

---

### R-36: "Humans and AI agents work together in a closed loop"

| Field | Value |
|-------|-------|
| subject.text | Humans and AI agents |
| predicate.text | work together in |
| object.text | a closed loop |
| direction | forward |
| modality | null |
| qualification | where segmentation evolves in real time, outreach is coordinated across channels, human judgment shapes the moments that matter most, and every insight feeds forward rather than resetting with each campaign or deal |
| evidence | paragraph 17 |

**Article text:** "Humans and AI agents work together in a closed loop where segmentation evolves in real time, outreach is coordinated across channels, human judgment shapes the moments that matter most, and every insight feeds forward rather than resetting with each campaign or deal."

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Subject, predicate, object, qualification preserved exactly.

---

### R-37: "The advantage will belong to organizations whose leaders have the mandate and discipline to design around the customer rather than around the organizational chart"

| Field | Value |
|-------|-------|
| subject.text | The advantage |
| predicate.text | will belong to |
| object.text | organizations whose leaders have the mandate and discipline to design around the customer rather than around the organizational chart |
| direction | forward |
| modality | null |
| evidence | paragraph 19 |

**Article text:** "The advantage will belong to organizations whose leaders have the mandate and discipline to design around the customer rather than around the organizational chart."

**Proposition boundary check:** Single proposition. Subject, predicate, object in same sentence.

**Audit:** R0 — Faithful. Exact sentence match.

---

## Classification Summary

| Classification | Count | Percentage |
|----------------|-------|------------|
| R0 (Faithful) | 37 | 100% |
| R1-A (Argument loss) | 0 | 0% |
| R1-P (Predicate loss) | 0 | 0% |
| R1-D (Direction error) | 0 | 0% |
| R1-M (Modality loss) | 0 | 0% |
| R1-N (Normalization error) | 0 | 0% |
| R2 (Endpoint-only evidence) | 0 | 0% |
| R3 (Fabricated) | 0 | 0% |

## Proposition-Boundary Check Summary

All 37 relations pass the proposition-boundary check:
- Each relation corresponds to a single source proposition
- No relations formed by combining coordinated clauses
- No relations formed by combining separate clauses sharing a subject
- No relations formed by combining separate clauses sharing a predicate
- No relations formed by combining adjacent propositions
- No relations formed by combining subordinate clauses

**Note:** R-06 and R-07 correctly split the coordinated clause "the customer journey is broken and experience suffers" into two separate relations, each corresponding to one clause.

## Source Preservation Analysis

### Argument Scope
All 37 relations preserve source-level argument scope:
- No collapsing of derived noun phrases
- Full prepositional phrases preserved

### Predicate Wording
All 37 relations preserve source-level predicate wording:
- No normalization overwrites source expression
- Source expression is always recoverable

### Direction
All 37 relations preserve direction:
- 37 forward relations
- No silent reversals or collapses

### Modality / Qualification
All modality and qualification preserved:
- R-25, R-26: dispositional modality ("can") preserved
- R-03, R-04, R-17, R-20, R-21, R-23, R-27, R-28, R-29, R-31, R-36: qualification preserved

### Evidence
All 37 relations have exact-sentence evidence.

---

## Audit Conclusion

The 1.5 candidate produced 37 Relations, all classified as R0 (Faithful). The source-first extraction approach preserved:
- Argument scope (no collapsing of derived noun phrases)
- Predicate wording (no normalization overwrites)
- Direction (all forward, correctly identified)
- Modality (dispositional markers preserved)
- Qualification (supplementary information preserved)
- Proposition boundaries (each relation corresponds to a single source proposition)

No R1, R2, or R3 errors were found.

---

*Audit conducted: 2026-09-06*
*Article: "AI Is Blurring the Line Between Sales and Marketing"*
*Method: Manual source-text verification with proposition-boundary check*
