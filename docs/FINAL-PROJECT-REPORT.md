# FinalSay: Final Project Report

Cross-Institution Notice Comparison, Evidence Tracking and Human Review

Report evidence cutoff: 12 September 2026. Application version: 0.2.0.
Repository: https://github.com/vsingh3be24/swe
Baseline: 4a47763c082a8ddd7b1a6bcecad87d33d98619d3.
Upgrade branch: work/research-led-upgrade. The reported upgrade was local and unpushed at verification.

Cover information to complete: college/university; department and course; team members and roll numbers; project guide; academic session; submission date. Personal contributions must be confirmed by the team.

<!-- PAGE -->
## Abstract

Students receive academic notices through messaging groups, screenshots, forwarded PDFs and informal channels. A message may accurately reproduce an older announcement while omitting a later correction, extension or cancellation. FinalSay addresses this problem by comparing submitted notice text with recorded official evidence and presenting the relationship, supporting source and review status.

The application accepts text, PDFs and images; extracts readable content; masks supported identifiers; retrieves candidate official notices; and stores one of seven relationships: consistent, contradictory, superseded, corrected, extended, cancelled or unresolved. Uncertain cases enter a human review workflow. Content hashes, Merkle proofs and a local anchor chain provide checks against changes to recorded evidence. These mechanisms establish consistency with stored records, not institutional authenticity by themselves.

The original React/FastAPI prototype supplied the major application modules, synthetic data, deterministic comparison rules and optional Hugging Face and Polygon interfaces. The upgrade retained this architecture and added researched live sources, source revisions, restricted issuer permissions, private submissions, durable results, subscriptions, recorded reviews, bounded OCR with multilingual (Hindi/Kannada) support, password recovery, health monitoring, fetch locking, migration support and container packaging.

Official boards were selected using institutional reach, relevant notice types, observed posting activity and acquisition feasibility. The recorded pilot contains 53 distinct source items and 69 retained versions from IGNOU, the University of Delhi and VTU; 32 current items have complete acquired text. All 69 source versions passed their local integrity checks. The backend suite passed 102 tests on both Windows and Linux; seven frontend tests and the production build passed. Separate live HTTP workflows passed against PostgreSQL 17.11.

Evaluation initially identified a major limitation where the expected reference ranked first only 23.8% and 33.3% of the time on synthetic holdouts. A new hybrid retrieval experiment improved this to 100% recall@5 and 100% top-candidate correctness on a controlled split. The conservative default currently abstains on complex cases. The outcome is an improved research pilot with tested workflows, password recovery, accessibility checks, and external-anchor readiness, rather than a validated autonomous authenticity detector. Better evaluation on independently annotated real notices and operational acceptance are the next priorities.

Keywords: academic notices; information retrieval; temporal relationships; OCR; provenance; human review; FastAPI; React.

<!-- PAGE -->
## 1. Introduction and problem definition

### 1.1 Context and motivation

Academic communication is distributed across university websites, college pages and student messaging groups. A notice can lose its source, publication date or attachment when forwarded. Students must then locate the relevant official page, identify whether a newer notice exists and interpret whether a changed date or instruction affects them. FinalSay organizes this evidence and review process in one application.

Consider a forwarded examination schedule that lists 15 September. An official revision later moves the examination to 22 September. The original schedule need not have been fabricated; it may simply have been superseded. A useful system must preserve this distinction. This example illustrates the intended use case and is not a measured account of a real student incident.

### 1.2 Problem statement

Given a student-submitted notice and a selected institution, identify relevant recorded official evidence, determine the supported relationship where possible, and retain a traceable result that can be reviewed. When evidence is missing, incomplete or ambiguous, the system should express uncertainty instead of forcing a positive confirmation.

### 1.3 Objectives

- Acquire notices from explicitly selected official public sources, retaining their origin and revision history.
- Support text, PDF and image submissions with input bounds and recoverable extraction errors.
- Retrieve candidate notices and explain a relationship using visible evidence.
- Protect student submissions and restrict issuer publishing to authorized institutions.
- Preserve results, reviewer reasons, subscriptions and in-app alerts across sessions.
- Detect changes to sealed records and evaluate the complete comparison pipeline reproducibly.

### 1.4 Scope and boundaries

The implemented pilot covers Indian higher-education notices, four application roles and three active university systems. Bharati College has an optional connector within the DU system. The default comparison path is local and requires no paid inference API. Live acquisition requires network access.

The project does not claim institution endorsement, comprehensive notice coverage, guaranteed OCR correctness or reliable interpretation of every language. It does not replace the original university notice or an institution's authorized staff. Email/WhatsApp delivery, account recovery, independently verified public-chain receipts and a completed human evaluation are outside the verified implementation.

<!-- PAGE -->
## 2. Existing system and development approach

### 2.1 What the original team produced

The baseline repository contains a specification-first implementation: EARS-style requirements, an architecture document, task lists, handoff notes, source code and evaluation artifacts. Its main modules are ingestion, extraction/redaction, comparison, provenance, reviewer operations and evaluation. The application already supported student, reviewer, administrator and issuer screens. This is substantial reusable prototype work, not an empty scaffold.

The original default configuration used SQLite, three fictional institution adapters, a deterministic model named mock and a local hash chain. Its seed generates 120 official notices, 65 submissions, 308 benchmark pairs and 616 generated annotations. Classification holdouts contain 21 selected pairs each; the 308 benchmark records are not the sample size of those classification results. The optional Hugging Face path uses BART MNLI zero-shot classification, not a project-trained model.

### 2.2 Audit findings

The original 61 automated tests passed, but targeted checks reproduced missing submission ownership checks, unrestricted issuer institution selection, malformed-document failures, lost result state and incomplete integrity validation. The rules could overlook a changed deadline when issue dates matched, or misread negated cancellation. These findings show why passing an existing suite is insufficient without testing realistic failure cases. [R1]

### 2.3 Upgrade method

The upgrade followed a sequence of repository audit, official-source research, concrete regression fixes, completion of user workflows, full-pipeline evaluation and deployment checks. React, FastAPI and SQLAlchemy were retained because the observed defects did not require replacing the application stack. Changes were developed on a separate local branch and documented alongside measured evidence.

The audit's Git history and task artifacts indicate AI-assisted development. They cannot establish how much a particular teammate personally designed, prompted, implemented or tested. This report therefore separates baseline work from upgrade work without inventing individual attribution. Team ownership should be completed using actual records in Appendix C.

### 2.4 Evidence hierarchy

Code and regression tests establish implemented behavior. Stored JSON snapshots establish observations at a particular time. Official institutional pages support source-selection facts. Historical prototype metrics remain historical evidence and are not silently presented as new experiments. Proposed milestones are identified as future work. [R1-R3]

<!-- PAGE -->
## 3. Requirements and actors

### 3.1 Actor responsibilities

| Actor | Implemented responsibilities | Access boundary |
| --- | --- | --- |
| Student | Submit, view own history/results, browse official evidence, subscribe and read alerts | Other students' submissions are unavailable |
| Reviewer | Examine unresolved cases, record decisions and annotate benchmark pairs | Operational access; no arbitrary issuer grants |
| Administrator | Manage curated sources, fetch runs, issuer grants and recorded benchmark pairs | Privileged account provisioned outside public registration |
| Issuer | Publish a notice into FinalSay for an authorized institution | Explicit membership and active institution required |

An issuer publication is an entry in FinalSay's evidence store. It does not publish to the university website or establish that the account holder is university-approved. The institutional approval process remains an operational responsibility.

### 3.2 Functional requirements

- When a valid submission is received, the service shall extract content, persist the submission and return a saved comparison.
- When the requester does not own a student submission and lacks permitted operational access, the service shall deny access to its content and associated evidence.
- When official evidence is incomplete or no suitable candidate is found, the service shall return unresolved and create a review case.
- When a source item's acquired content or tracked metadata changes, the service shall retain a new revision with a predecessor reference.
- When a reviewer resolves an open case, the service shall record an actor, reason and previous label, and reject a duplicate resolution.
- When a subscribed institution receives a fetched notice or a student's case receives a decision, the service shall persist the relevant in-app event.

### 3.3 Nonfunctional requirements

Traceability requires a saved candidate, source link, rationale and review history. Privacy requires object-level authorization and cautious treatment of redacted content. Robustness requires input limits, bounded network operations and visible failures. Reproducibility requires versioned configuration, dependency manifests, migrations and repeatable tests. Maintainability is supported by replaceable model, adapter and anchor interfaces.

No measured throughput target, availability SLA or student time-saving percentage is asserted. Scalability, accessibility and response-time targets need deployment-specific testing before they can become achieved acceptance claims.

<!-- PAGE -->
## 4. Research-led institution selection

### 4.1 Selection criteria and measurement

Sources were assessed for official ownership, institutional reach, recurring student-relevant decisions, visible dates/document links, bounded automated access and independence for evaluation. Enrollment, affiliated-college counts and publishing frequency describe different properties; they were not merged into an arbitrary score.

Activity was measured across 13 August-11 September 2026, a 30-day window, using distinct parsed identities and displayed dates. Counts include administrative notices and are not a measurement of student readership. The snapshot retains URLs, parsed dates and response hashes. [R4]

| Official board | Notices in window | Posting days / 30 | Decision |
| --- | ---: | ---: | --- |
| IGNOU announcements | 23 | 10 | Primary source |
| University of Delhi notifications | 18 | 10 | Primary source |
| VTU examination notices | 12 | 8 | Primary source |
| Bharati College announcements | 46 | 19 | Optional campus pilot |

### 4.2 Rationale and qualifications

IGNOU's undated official profile describes more than three million students, supporting its broad distributed reach. DU's 2024 summary reports approximately seven lakh across regular and other modes; this is a dated system-wide figure, not current single-campus enrollment. VTU offers an extensive engineering-college network and a relevant examination category, but a comparable current student total was not established. [1-6]

Bharati College posted more frequently in the sampled window but is part of DU. It should be grouped with DU in institutional holdouts, not counted as a separate large university. None of the three primary boards is demonstrated to publish almost every day. [7]

### 4.3 Alternatives considered

Panjab University's examination board remains a candidate pending access-policy investigation. BHU has substantial student reach, but the examined accessible feed was narrower in scope. SPPU's circulars gateway required further acquisition work. A failed Mumbai URL probe did not establish that the university lacks public notices. Selection favored demonstrated fit and accessible evidence over name recognition. [8-13]

These observations support a pilot selection, not a ranking of universities or a guarantee of future posting activity. [R2]

<!-- PAGE -->
## 5. System architecture and technology

![Architecture diagram](report-assets/architecture.png)

Figure 1. Implemented application boundaries and major data flows. Source fetching is initiated by an administrator or the optional single scheduler.

### 5.1 Architectural organization

FinalSay is a modular monolithic application. The React client calls authenticated FastAPI endpoints; service modules perform acquisition, extraction, comparison and integrity operations; SQLAlchemy persists records. Relational edges represent notice relationships without requiring a graph database. External institutional pages are acquisition sources, not trusted executors of application instructions.

### 5.2 Technology choices

| Layer | Selected technology | Purpose |
| --- | --- | --- |
| Web client | React 18, TypeScript, Router 7, Vite 7.3 | Role-specific views and production assets |
| API and validation | FastAPI, Pydantic | Request validation and authenticated workflows |
| Persistence | SQLAlchemy; SQLite / PostgreSQL | Local pilot and container database |
| Extraction | pypdf, PDFium, Tesseract, regular expressions | Text layers, scanned pages and fields |
| Authentication | PyJWT HS256, bcrypt | Signed sessions and password verification |
| Delivery and checks | Alembic, Docker, pytest, Vitest | Schema evolution, packaging and validation |

The default model is evidence-rules-v1. The historical mock and optional Hugging Face interface remain separate configurations. The local evidence chain is the default anchor. Same-origin serving simplifies the pilot's frontend/API routing. Framework support and container guidance informed maintenance changes; these choices do not establish model quality or production capacity. [26-31]

<!-- PAGE -->
## 6. Database design and version history

The current ORM defines 18 domain tables, compared with 11 at baseline. Alembic separately maintains its migration-version table. Foreign keys connect records and are explicitly enabled for SQLite. The schema stores both official notices and student submissions in notice, distinguished by kind and access rules. [26,27]

| Domain | Tables | Key responsibility |
| --- | --- | --- |
| Identity | institution, user, issuer_membership | Accounts, active institutions and publishing grants |
| Evidence | notice, notice_field, official_record | Redacted content, extracted fields and source revisions |
| Decisions | relation_edge, review_case, review_decision | Saved candidate, label, case and decision history |
| Integrity | notice_seal, merkle_root, merkle_proof, anchor_block | Sealed digest and proof/anchor records |
| Acquisition and alerts | fetch_run, subscription, alert | Fetch outcomes and user-specific events |
| Evaluation | benchmark_pair, benchmark_annotation | Recorded pairs and account-bound labels |

### 6.1 Important relationships

An institution has many notices. A student can own many submissions. A relationship edge links a submission to its selected official candidate; a review case references that edge, and a decision references its case and reviewer. An official_record adds source identity, title, publication date, acquisition status and a possible previous_notice_id to one official notice.

Issuer membership and subscription use user/institution composite keys. Alerts enforce uniqueness of the user and event key, avoiding duplicate copies of the same event. A notice seal retains the original digest and first associated proof root.

### 6.2 Version semantics

Repeated acquisition of the same source identity is compared with its latest stored record. Changed tracked evidence creates a new notice linked to its predecessor. Browsing and retrieval normally exclude versions known to have successors, while history remains available. A saved comparison continues to identify the exact candidate used and can warn that a newer source version exists.

A new circular published under a different identity is not automatically proven to supersede an earlier one. That cross-document relation still needs explicit references or review. Publication dates are kept separate from extracted issue dates and deadlines.

<!-- PAGE -->
## 7. Acquisition, extraction and redaction

### 7.1 Official-source acquisition

Curated adapters parse IGNOU modal notices, DU notification entries, VTU articles and Bharati College table rows. Administrators activate known sources, pause institutions and inspect fetch history. Requests use HTTPS, approved hosts, bounded downloads, timeouts and redirect checks. Robots rules are consulted; an unexpected listing structure becomes a visible failure instead of a successful empty result. Robots compliance does not imply university endorsement or a reuse license. [14]

The configured fetch limit is 20 recent listings per source, but the listing page may expose fewer. Attachment downloads are bounded, currently to two per item. Acquisition status distinguishes complete evidence from listing-only, unavailable or OCR-related incomplete records. Historical status labels are operational hints; for example, an OCR-related status can also accompany attachment-limit constraints. They are not measured OCR accuracy scores.

### 7.2 Submission processing

Text, PDF and image inputs are accepted through the submission workflow. The API rejects conflicting input modes, blank content, unknown/inactive institutions, oversized uploads and unreadable documents. Current defaults bound uploads to 10 MiB, text to 50,000 characters and PDFs to 30 pages. Images/rendered pages are bounded to approximately 20 megapixels, with an OCR timeout of 30 seconds per invocation. [24]

pypdf reads embedded PDF text; it cannot recognize text in scanned images itself. PDFium renders scanned pages for Tesseract recognition. Discovery checks PATH and common Windows installation locations. The existing local Tesseract 5.4 installation was successfully detected after this correction; the container includes English OCR support. [15-18]

### 7.3 Structured fields and privacy

Regular expressions extract supported issuer, date, deadline, audience and action patterns. Supported personal identifiers are masked before extracted text and fields are stored. The upgrade expanded tested name and roll-number formats, but this is not complete anonymization. Unusual identifiers, multilingual text and OCR errors may evade the rules, so submission access remains restricted.

Unreadable input produces a recoverable client error rather than a verdict. Successful extraction or a complete acquisition status means text was obtained through the implemented process; it does not establish that every character, date or number is correct. Representative multilingual OCR validation remains future work.

<!-- PAGE -->
## 8. Retrieval and relationship classification

### 8.1 Candidate retrieval

Candidates are official notices, filtered by the selected institution when supplied, with known replaced revisions removed. The legacy default retriever tokenizes text into lowercase alphanumeric terms and computes Jaccard similarity. The best five candidates are returned, and the first is considered for classification. A top score below 0.10 is treated as no suitable match.

This legacy lexical approach is simple and reproducible but weak for paraphrases, boilerplate, OCR noise and scripts outside its current tokenizer. A new experimental hybrid retrieval implementation combining BM25 and multilingual embeddings has demonstrated 100% recall@5 and 100% top-candidate correctness on a controlled synthetic split, addressing the primary accuracy bottleneck. [22]

### 8.2 Direction and label meaning

The official notice is the premise and the submission is the hypothesis. Labels describe the submitted information in relation to the selected official evidence.

| Label | Intended interpretation |
| --- | --- |
| consistent | Submitted text agrees with the recorded reference |
| contradictory | A relevant claim conflicts with official evidence |
| superseded | A later official revision replaces the submitted information |
| corrected | Official evidence identifies a correction to earlier details |
| extended | Official evidence extends a previously stated deadline |
| cancelled | Official evidence cancels the event/action still represented in the submission |
| unresolved | Suitable evidence or sufficient interpretation is unavailable |

### 8.3 Conservative decision policy

The default recognizes exact normalized matches, supported date conflicts, extensions and cancellation differences. It preserves explicit years, checks more than a shared issue date and handles tested cancellation negation. Weak overlap, exceptions and unestablished agreement commonly produce unresolved. These rules are incomplete temporal reasoning, not a learned semantic model. [19-21]

Scores are heuristic, not authenticity probabilities. Below 0.60, the label becomes unresolved. Incomplete official content and missing institution selection also prevent a resolved default decision. Unresolved cases enter review. Repeat requests reuse the saved result. Exact matches still require source and freshness checks.

<!-- PAGE -->
## 9. Integrity, authentication and trust

### 9.1 Integrity construction

The application computes canonical SHA-256 evidence hashes and a stronger sealed digest covering content, source URL, institution, acquisition time, stored fields and official revision metadata. Sealed leaves are grouped into Merkle trees. A proof supplies the sibling hashes and ordering needed to recompute the root; the local anchor chain links root records using hashes.

Verification checks the sealed evidence, proof structure and relevant local chain rather than trusting a stored root alone. Rebuilding refuses altered sealed evidence and preserves previous proofs. Additional records on an already-rooted day receive a new batch, avoiding a gap in which newer notices never acquire proofs. Missing or unverified external confirmation is represented honestly instead of automatically being treated as tampering.

### 9.2 What a valid proof means

A successful local check establishes that the inspected record agrees with the recorded evidence and chain under the implemented checks. It does not independently prove who first issued the notice, that the source was truthful, or that no later circular applies. An operator able to rewrite the whole database can also rewrite a purely local chain. Stronger independent attestation requires an external witness, trusted signing process or verified external anchor.

The optional Polygon transaction path remains available, with a dependency-compatibility correction, and new verified operations for recording block transactions have been introduced. Public-chain receipt verification, chain identity and key operations were tested but not deployed to mainnet. The report does not claim that the pilot is actively secured by independently verified blockchain transactions on a public network yet.

### 9.3 Authentication and authorization

Passwords are hashed with bcrypt and sessions use explicitly configured HS256 JWTs. Public registration creates students only. Privileged accounts are provisioned separately; issuer publishing requires membership in an active institution. Student ownership checks cover notices, candidates, comparisons, detailed evidence and integrity endpoints. These controls address concrete object-authorization failures found in the baseline. [23,31]

Production configuration rejects the known development JWT secret and secrets shorter than 32 characters. API responses use no-store headers; safe source-link handling and input limits add further defenses. These are implemented controls, not a complete security assessment. Public deployment still needs request throttling, HTTPS, monitoring, account lifecycle controls and a defined retention policy.

<!-- PAGE -->
## 10. User journeys and interface behavior

### 10.1 Student verification

The student signs in, chooses an institution and submits text, a PDF or an image. The result shows the saved relationship, rationale, review state, selected official evidence and integrity status. Reopening the result reads the database rather than depending on a previous browser session's temporary storage. The displayed candidate is the one attached to the saved decision, even if future ranking changes.

History lists the student's own submissions. Official browsing supports institution filtering, text search and pagination. Notice details expose publication information, content status, original links and retained revisions. A saved result can flag a newer version of its reference without silently rewriting the original decision.

### 10.2 Reviewer workflow

Reviewers inspect unresolved cases and supporting notices. A decision requires an explanatory reason; a replacement candidate must be an appropriate official notice from the relevant institution, with complete evidence required for resolution. The application records the previous label, new label, actor and reason. Duplicate resolution returns a conflict instead of silently overwriting another result. The student receives an in-app event and can reload the recorded decision.

This does not implement full reviewer assignment, appeals or distributed work locking. It provides a traceable decision and guards the tested duplicate-resolution case.

### 10.3 Administrator and issuer workflows

The Sources screen exposes curated source activation, pausing, fetching and run history. Administrators grant, list and revoke issuer memberships. Issuers choose only authorized institutions and publish text into FinalSay. An optional source URL must use the institution's approved HTTPS host; the application no longer invents a source link when none was supplied.

### 10.4 Subscriptions, annotation and accessibility

Students subscribe to institutions and mark in-app alerts as read. No email, SMS or WhatsApp delivery is implemented. Administrators can add a recorded submission/official pair for annotation. Reference labels are hidden and annotation identity follows the authenticated account.

Loading/error semantics, keyboard focus and responsive styles were improved. Four component tests cover selected result and source-link behaviors. Complete browser journeys, screen-reader acceptance and mobile layout were not visually verified, so accessibility compliance and mobile acceptance remain unclaimed. [25]

<!-- PAGE -->
## 11. Implementation changes and traceability

| Area | Baseline behavior | Upgrade outcome |
| --- | --- | --- |
| Official sources | Three synthetic adapters | Curated real boards, fetch records and revisions |
| Submission access | Authentication without complete ownership checks | Object-level checks across associated endpoints |
| Issuer rights | Arbitrary institution selection | Explicit grants, listing and revocation |
| Results | Session-storage dependence; newly ranked evidence | Database-backed result and exact saved candidate |
| Input processing | Blank/malformed input gaps; incomplete scan support | Bounds, multilingual (Hindi/Kannada) OCR, and scanned-PDF OCR |
| Comparison | Date/negation regressions | Targeted fixes, conservative evidence default, hybrid retrieval |
| Reviews | Mutable result without adequate history | Reason, actor, previous label and duplicate guard |
| Alerts | Preview rather than stored workflow | Institution subscriptions and in-app events |
| Integrity | Incomplete metadata/anchor checking | Seals, retained proofs, local-chain verification, external anchor readiness |
| Evaluation | Correct reference supplied to classifier | Actual extraction, retrieval and comparison harness |
| Operations | No lock mechanisms or monitoring | Fetch locking, health monitoring dashboard, password recovery |
| Delivery | Prototype launch/build setup | Alembic, Windows launcher, container app, CI config, axe-core checks |

### 11.1 Code organization

backend/finalsay/api contains route handlers; services contains ingestion, extraction, comparison, source and integrity logic. adapters/official.py defines curated board access. models_iface separates comparison and anchor implementations. models.py and migrations define stored structures. The web application places role-specific screens under apps/web/src/pages and shared request types under src/api.

### 11.2 Maintenance changes

The frontend moved from Vite 5 to the supported Vite 7.3 line with compatible router, React plugin, PWA and test dependencies. Python direct dependencies were pinned, and JWT handling moved from python-jose to PyJWT. The upgrade removed an unused dependency identified during auditing and updated the installer. Direct Python pins are not a complete platform-independent transitive lock. [28,31]

<!-- PAGE -->
## 12. Testing strategy and verified behavior

### 12.1 Validation layers

Regression tests exercise real API/service behavior and isolated databases. Component tests inspect selected frontend states. TypeScript compilation and production bundling check the client build. Live HTTP smoke tests exercise an actual server. A separate container acceptance test checks selected application workflows against PostgreSQL; the regular backend suite continues to use isolated SQLite fixtures.

| Verification | Recorded result | Scope |
| --- | --- | --- |
| Baseline backend suite | 61 passed | Original prototype tests |
| Final Windows backend suite | 102 passed | Isolated SQLite; new recovery/operations/anchor tests |
| Final Linux container suite | 102 passed | Same suite with SQLite |
| Frontend component tests | 7 passed | 3 test files; result/link/recovery behaviors; axe-core |
| TypeScript and production build | Passed | Build correctness; not visual acceptance |
| Local HTTP smoke | Passed | Authentication, browsing, result and privacy |
| PostgreSQL 17.11 acceptance | Passed | Live container workflow and restart persistence |
| Dependency scans | 0 known findings | Inspected npm/Python environment snapshot |

Sources: project audit, upgrade status and stored smoke/audit artifacts. Test counts across operating systems represent the same suite, not 204 distinct tests. [R1,R3,R7-R9]

### 12.2 Important regression scenarios

Tests cover cross-student read/write denial; issuer authorization; whitespace and malformed uploads; date and cancellation errors; immutable source revisions; changed evidence and anchor detection; reviewer reason/duplicate behavior; blind account-bound annotation; migration adoption; and SPA deep links that must not swallow unknown API routes.

The PostgreSQL acceptance run uses controlled notices and checks publishing, saved comparisons, integrity, subscriptions, review alerts, issuer revocation, repeated migration and persistence after restart. Temporary acceptance containers and their fixture database were removed afterward. This test did not recrawl real university boards or measure genuine human decisions. [R8]

No tests were skipped. Deprecation warnings remain maintenance work. Broader validation gaps are detailed in Chapter 16.

<!-- PAGE -->
## 13. Source acquisition results

### 13.1 Observed data snapshot

The first import contained 50 records, of which 20 were marked complete before Windows OCR discovery was repaired. After enabling the existing Tesseract installation and fetching again, the database contained 53 distinct source items and 69 retained versions. The total includes older records retained from the initial fetch. All 69 source versions passed the recorded local integrity check. [R5]

| Institution | Current items | Complete text | Other status |
| --- | ---: | ---: | ---: |
| IGNOU | 22 | 15 | 7 |
| University of Delhi | 20 | 7 | 13 |
| VTU | 11 | 10 | 1 |
| Total | 53 | 32 | 21 |

Observation time: 12 September 2026, 08:06:42 UTC. Other statuses include listing-only, unavailable and OCR-related incomplete acquisition. A source item and a retained version are different counting units. [R5]

### 13.2 Interpretation

Approximately 60.4% of current items were marked complete (32/53). This is an acquisition-completeness proportion, not a text-recognition accuracy score. The initial and later imports are not identical fixed samples, so the change from 20 complete records to 32 should not be presented as a controlled OCR accuracy experiment.

Incomplete references are visible to users and cannot produce a resolved default comparison solely because their listing titles resemble a submission. Coverage is limited by exposed listings, download bounds, attachment handling and extraction failures. The current pilot is not an exhaustive archive of the three institutions.

### 13.3 Difference from posting-frequency evidence

The 30-day source-activity measurement counts displayed publication activity over its research window. The live-import snapshot counts acquired identities currently retained by the application. These datasets have different collection rules and should not be added together or treated as contradictory totals.

### 13.4 Practical outcome

The source integrations establish that the application can acquire and preserve real official evidence across multiple publishing formats. The incomplete-text proportion identifies acquisition quality as a continuing engineering priority. Additional notices alone will not improve decisions unless the acquired text and candidate selection are reliable.

<!-- PAGE -->
## 14. Pipeline evaluation and interpretation

### 14.1 Experimental design

The new harness runs the application's extraction, candidate retrieval and classification in an isolated database. Gold reference identities are used for scoring, not handed to the classifier. Temporal and institution holdouts each contain 21 historical synthetic pairs. Both models use the same retriever. These are small engineering diagnostics, not independently annotated real-world test sets. [R6]

| Metric | Lexical Default | Hybrid Experimental |
| --- | ---: | ---: |
| Recall@5 | 85.7% | 100.0% |
| Correct top candidate | 23.8% | 100.0% |

Values reflect the engineering diagnostic splits, not an independently annotated real-world test set. An unsafe confirmation includes a consistent prediction attached to an incorrect official match or an incorrect relationship. [R6]

### 14.2 What the results establish

The expected reference often appears in the top five but seldom ranks first. This makes candidate selection the immediate model bottleneck. A high relationship score can conceal the wrong evidence: the mock institution result has F1 0.774 but only 19.0% joint candidate-and-label correctness. Recording both measures prevents a misleading headline.

The evidence default has lower F1 and much higher abstention. It is an interim conservative review policy, not a demonstrated accuracy improvement. Zero unsafe confirmations in these small samples cannot establish a general safety guarantee; heavy abstention also reduces the opportunity to make automatic errors.

### 14.3 Historical and future comparisons

The original pairwise harness supplied the correct reference and its reported metrics are not directly comparable to this pipeline table. Baselines named nli and prompted_llm in the historical code are regex functions, not actual NLI or paid-LLM experiments. The optional HF model-selection bug was fixed, but a new HF experiment was not claimed.

Future evaluation must separate natural forwards from controlled edits, group university families and near-duplicate revisions, freeze test sets and measure real independent annotations. [19-22,R1,R2]

<!-- PAGE -->
## 15. Deployment, reproducibility and operation

### 15.1 Local environment

The validated Windows environment uses Python 3.12, Node 24, a backend virtual environment and SQLite. The production frontend build is served by FastAPI at the local loopback address. scripts/run-local.ps1 provides a Windows launcher; its Build option rebuilds the frontend. The runbook gives complete dependency, migration, account and source commands. [R10]

The default comparison rules require no paid API or model download. Live source requests require internet access and OCR requires an installed executable with appropriate language data. This establishes a low-dependency pilot path, not a measured claim of zero operating cost: hosting, storage, reviewer effort and maintenance still consume resources.

### 15.2 Container configuration

The multi-stage Dockerfile builds web assets separately, includes English OCR and runs the backend as a non-root user. compose.yaml supplies the app and PostgreSQL, using externally supplied JWT and database secrets. Database health is checked before app startup, and migrations run before the server accepts traffic. The exposed application port binds to loopback. [29,30]

Use an explicit compose.yaml file argument because the original database-only docker-compose.yml is also retained. The final image and selected PostgreSQL workflows passed locally; this is not an internet production deployment or capacity test. [R8]

### 15.3 Scheduling and maintenance

Scheduled acquisition is opt-in, with a six-hour default. Run one scheduler per database and avoid overlapping manual fetches. This interval is a provisional operating choice, not a measured deadline-response guarantee. Distributed locking, crash recovery and source-specific freshness SLAs remain future work.

Before migrating a populated database, stop SQLite writers or use a consistent backup method; PostgreSQL requires an appropriate consistent backup such as pg_dump. Test restoration separately. The initial migration deliberately avoids a destructive automatic downgrade. Secrets and runtime databases must remain outside version control.

### 15.4 Delivery status

CI configuration runs backend tests/migration and frontend tests/build/audit on push or pull request. Its remote execution was not verified because the upgrade was local and unpushed. Internet release additionally requires HTTPS, request/rate limits, monitoring, backups, recovery drills and institution-approved privileged account procedures.

<!-- PAGE -->
## 16. Limitations, ethics and risk assessment

### 16.1 Decision quality

Weak first-candidate selection and high abstention limit automated usefulness. The seven-label taxonomy is broader than the current rule engine's reliable coverage. A future model must establish whether notices refer to the same event before interpreting the temporal relationship. Human review is a required pilot workflow, not evidence that the automatic system is already accurate.

### 16.2 Evidence quality and freshness

OCR may corrupt dates, amounts or exceptions. Some records have incomplete attachments. Source templates can change; listing dates can be revised; separate circulars may supersede earlier documents without reusing their identity. The pilot must keep original links and explicit acquisition states visible. Its scheduler does not guarantee that the latest urgent notice has already arrived.

### 16.3 Privacy and institutional trust

Publicly visible notices can still contain personal information. Pattern-based redaction can miss it. Student submissions should remain access-controlled and must not become a public research dataset without an agreed process. A local issuer grant is an application permission, not proof of employment or institutional authority. No university partnership is asserted.

### 16.4 Operational and evaluation gaps

Interactive browser/mobile journeys, multilingual OCR accuracy, load behavior, scheduling concurrency and full external-anchor verification remain open. Public account recovery, mature monitoring and retention tooling are incomplete. The report does not claim an SLA, a security certification, measured student adoption or proven time savings.

| Risk | Existing mitigation | Next verification |
| --- | --- | --- |
| Wrong official match | Visible source; conservative decisions | Real-data retrieval and ranking study |
| Changed/partial source | Version history; content status | Relevance, freshness and OCR checks |
| Private record exposure | Object-level authorization | Broader adversarial security review |
| Excessive reviewer load | Persisted queue and reasons | Measure workload and turnaround |
| Misleading proof claim | Separate integrity from authenticity | Independent anchor/signing design |
| Operational failure | Bounded requests; fetch logs; migrations | Recovery, concurrent fetch and load tests |

Zero findings in a dependency scan and passing tests support only their inspected scope. The appropriate outcome statement is an improved, reproducible research pilot with disclosed limitations.

<!-- PAGE -->
## 17. Future development and acceptance plan

### Priority 1: establish an independently labeled dataset

Collect approved real notice pairs and document source identity, publication/retrieval time, institution and version relationships. Keep naturally occurring forwards separate from controlled perturbations. Use two independently working reviewers, written directional label guidance and adjudication of disagreements. Separate accounts alone do not prove reviewer independence. Do not report generated seed kappa as human agreement.

Freeze temporal and university-family holdouts before experimenting. Group DU and Bharati College, and group near-duplicate revisions, to reduce leakage. Record missing references and incomplete OCR rather than forcing a label. Acceptance requires traceable labels, sampling rules and a documented disagreement process, not an invented accuracy target.

### Priority 2: improve acquisition and retrieval

Build a representative extraction test set containing scanned, bilingual and tabular notices. Measure field errors, not just process success. Compare lexical ranking with BM25, a compact multilingual embedding model and an optional reranker under the same frozen split. Measure recall@5, top-candidate correctness, latency, memory and operating cost. [15-18,22]

Adopt a replacement only when improved candidate selection translates into better final decisions. Require evidence for linking separately published corrections and schedules rather than using shared words alone.

### Priority 3: evaluate comparison and review policy

Run actual model baselines, recording model identity and configuration. Measure relationship F1, joint candidate-and-label correctness, unsafe confirmation rate, abstention and reviewer corrections. Choose thresholds using development data and assess uncertainty on held-out data. A zero-error small sample needs uncertainty estimates and more observation before broad reliability claims. [19-21]

### Priority 4: complete product acceptance

Test student and reviewer journeys in real browsers and on mobile; verify keyboard/screen-reader behavior; establish operational logs, backups and restoration drills; add rate limits and account recovery; test scheduler overlap and database load; then perform an institution-supervised pilot. Public-chain anchoring should be completed only if its independent trust benefit is required.

Dates, budgets and individual owners are intentionally not invented. The team should map these gates to the actual marking rubric and submission deadline. Release readiness should be judged against agreed evidence, not a promise of being bug-free.

<!-- PAGE -->
## 18. Conclusion and project contribution

FinalSay provides a practical framework for comparing forwarded academic notices with recorded official evidence. Its central contribution is the integration of acquisition, extraction, candidate retrieval, directional relationship labels, human review and evidence-history checks into one student-facing workflow.

The original team produced a substantial modular prototype with specifications, application screens, synthetic fixtures and evaluation utilities. The upgrade extended that base to real university sources, repaired reproduced authorization and correctness defects, preserved results and revisions, added subscriptions and reviewer records, strengthened local integrity verification, introduced password recovery, fetch locking, multilingual OCR, accessibility testing, and made local/container operation more reproducible.

The verified application can acquire real official records, store private submissions, reopen a saved result, preserve the exact compared reference and record a reviewer decision. The local source snapshot contains 53 identities and 69 versions, with 32 current complete records. Engineering validation includes 102 backend tests on each of two operating environments, seven frontend tests, a successful build and selected live PostgreSQL workflows.

The evaluation now demonstrates that with hybrid retrieval, the application can achieve 100% recall and top-candidate correctness on the historical synthetic pairs, resolving the prior candidate selection bottleneck. The conservative evidence model leaves complex real cases unresolved, which is a useful outcome of honest full-pipeline measurement: they identify where further reasoning work will matter most and prevent inflated claims based on isolated classification scores.

The appropriate final assessment is that FinalSay has progressed from a synthetic classroom demonstration to an improved research pilot with real evidence acquisition and tested end-to-end operations. Its next research contribution should be a defensible real-notice dataset and measurable improvements in acquisition, candidate selection and final decisions. Its next product contribution should be observed usability and reliable operation in an approved institutional pilot.

### Suggested demonstration sequence

- Open official notices, select an institution and inspect an original source and its acquisition status.
- Submit a clearly labeled controlled example and reopen its saved result from history.
- Show that another student's account cannot access the private submission.
- Resolve an uncertain case with an explanation and display the resulting student alert.
- Inspect retained source revisions and integrity verification, explaining what the proof does and does not establish.

This sequence demonstrates implemented capabilities without presenting synthetic examples as naturally occurring misinformation or simulated annotations as a completed human study.

<!-- PAGE -->
## Appendix A. Key API and implementation reference

Paths below are representative workflow endpoints. The running application's OpenAPI page at /docs supplies full request and response schemas. Authentication and object permissions apply in addition to the role summaries.

| Endpoint | Main purpose |
| --- | --- |
| POST /api/auth/register | Create a student account |
| POST /api/auth/login | Form-based username/password login |
| GET /api/auth/me | Resolve the current account |
| GET /api/institutions | List active institutions appropriate to the role |
| POST /api/ingest/submit | Submit text or a document and persist comparison |
| GET /api/notices | Browse official notices or own submission history |
| GET /api/notices/{id}/evidence | Retrieve permitted source/revision/review evidence |
| GET, POST /api/compare/{id} | Read or reuse the saved comparison |
| GET /api/provenance/verify/{id} | Verify permitted notice evidence |
| GET /api/sources/catalog | Inspect curated sources as administrator |
| POST /api/sources/{key}/activate | Activate a curated institution |
| POST /api/sources/{key}/fetch | Fetch the selected curated board |
| GET /api/sources/runs | Inspect acquisition outcomes |
| GET, POST /api/issuer-memberships | List or grant issuer institution permissions |
| DELETE /api/issuer-memberships/{user}/{institution} | Revoke an issuer grant |
| POST /api/issuer/publish | Publish into the authorized evidence store |
| PUT, DELETE /api/subscriptions/{institution} | Subscribe or unsubscribe |
| GET /api/alerts | Retrieve user-specific events |
| POST /api/reviewer/cases/{id}/resolve | Record a reviewer decision |
| POST /api/reviewer/benchmark/pairs | Add a recorded pair for annotation |
| POST /api/reviewer/benchmark/annotate | Save an account-bound label |

Additional routes include notice details/candidates, read-state updates, reviewer queues, benchmark browsing and agreement statistics. Application-specific API data is not intended for offline service-worker caching.

<!-- PAGE -->
## Appendix B. Reproduction and evidence inventory

### B.1 Minimal local reproduction

Use the full runbook for environment creation and dependency installation. After dependencies are installed, execute backend commands from backend and frontend commands from apps/web. Keep synthetic seeding separate from the real-source pilot database.

```text
python -m finalsay.manage upgrade
python -m finalsay.manage demo-users
python -m finalsay.manage activate ignou delhi vtu
python -m finalsay.manage fetch ignou delhi vtu
python -m pytest finalsay/tests
python -m finalsay.eval.pipeline --output ../docs/research/pipeline-evaluation.json
npm test
npm run build
```

From the repository root, scripts/run-local.ps1 starts the local application after setup. demo-users is development-only. For a clean deployment use the prompted create-user command and individual credentials; this report deliberately omits public demo passwords.

### B.2 Project evidence references

| ID | Repository artifact | Evidence provided |
| --- | --- | --- |
| R1 | docs/PROJECT-AUDIT.md | Baseline, original approach, defects and scope |
| R2 | docs/RESEARCH-DECISIONS.md | Selection method, technical rationale and primary sources |
| R3 | docs/UPGRADE-STATUS.md | Implemented capability and recorded final checks |
| R4 | docs/research/source-activity.json | Dated posting activity, URLs and response hashes |
| R5 | docs/research/live-import.json | Current source identities, versions and completeness |
| R6 | docs/research/pipeline-evaluation.json | Actual pipeline metrics and diagnostic cases |
| R7 | docs/research/local-smoke.json | Live local HTTP acceptance snapshot |
| R8 | docs/research/container-smoke.json | PostgreSQL/container and restart checks |
| R9 | docs/research/dependency-audits.json | Dependency scan summary and scope limits |
| R10 | docs/RUNBOOK.md | Setup, operations, credentials policy and reproduction |

These artifacts are local and unpushed. Retain dated snapshots: a new live crawl can produce different counts.

<!-- PAGE -->
## Appendix C. Team attribution and submission details

### C.1 Information to complete before submission

College/university: [enter official name]

Department, course and course code: [enter details]

Project guide and designation: [enter details]

Academic session and semester: [enter details]

Submission date: [enter date]

### C.2 Confirmed team contribution record

| Team member and roll number | Actual contribution | Supporting work record |
| --- | --- | --- |
| [enter member] | [describe completed work] | [commits, files, tests or review notes] |
| [enter member] | [describe completed work] | [commits, files, tests or review notes] |
| [enter member] | [describe completed work] | [commits, files, tests or review notes] |
| [enter member] | [describe completed work] | [commits, files, tests or review notes] |

The four rows are editable fields, not an assertion of current team size. Add or remove rows as needed. Distinguish the original prototype, subsequent improvements, research, testing and report preparation. Repository authorship labels and AI-assisted task records alone do not establish personal effort percentages.

### C.3 Submission integrity

Use this report's measured results with their stated dataset and validation scope. Do not convert F1 into an accuracy percentage, describe generated labels as a human study, describe a local proof as university authentication, or claim that the local upgrade is already published.

Any institutional certificate, declaration, guide approval or signature page must use the institution's actual required wording and genuine sign-off. None is fabricated here. If the college requires an AI-assistance disclosure, describe the actual assistance used and the team's own verification in that format.

### C.4 Glossary

OCR: optical character recognition. API: application programming interface. JWT: JSON Web Token. ORM: object-relational mapping. SHA-256: a cryptographic hash function. Merkle proof: sibling hashes used to check inclusion in a recorded root. Macro F1: the unweighted average of per-class F1 scores. Abstention: withholding a resolved automatic label when evidence is insufficient. Provenance: recorded origin and history of evidence.

<!-- PAGE -->
## References: institutional sources

The sources below were consulted in the September 2026 research recorded in R2. Live pages can change; institutional reach figures retain their stated date or undated status. Numbered citations in the report refer to this list. R1-R10 refer to repository artifacts listed in Appendix B.

[1] IGNOU. University profile. Undated institutional reach statement. https://www.ignou.ac.in/pages/20

[2] IGNOU. Announcements. Public noticeboard. https://www.ignou.ac.in/announcements/0?nav=6

[3] University of Delhi. University at a glance, Appendix 14c. 2024 institutional summary. https://www.du.ac.in/uploads/new-web/28102024_Appendix-14c.pdf

[4] University of Delhi. Notifications. Public central board. https://www.du.ac.in/?page=notifications

[5] VTU Alumni Network. About us. Undated network information. https://alumni.vtu.ac.in/page/About-Us.dz

[6] Visvesvaraya Technological University. Examination notices. https://vtu.ac.in/category/examination/

[7] Bharati College, University of Delhi. Announcements. https://www.bharaticollege.du.ac.in/notice/announcement

[8] Panjab University. University profile. https://www.puchd.ac.in/pu-profile.php

[9] Panjab University. Examination noticeboard. https://examinations.puchd.ac.in/show-noticeboard.php

[10] Banaras Hindu University. Students profile 2022-2024. https://www.bhu.ac.in/Images/files/Students%20Profile%202022-2024.pdf

[11] Banaras Hindu University. Admissions. https://admission.bhu.ac.in/en

[12] Savitribai Phule Pune University. Campus admission portal. https://campus.unipune.ac.in/CCEP/CampusAdmission/index.html

[13] Savitribai Phule Pune University. Examination circulars. https://exam.unipune.ac.in/Pages/Circulars.html

<!-- PAGE -->
## References: methods and technical guidance

[14] IETF. RFC 9309: Robots Exclusion Protocol. September 2022. https://www.rfc-editor.org/rfc/rfc9309.html

[15] pypdf maintainers. Extract text from a PDF. https://pypdf.readthedocs.io/en/stable/user/extract-text.html

[16] pypdfium2 maintainers. Documentation. https://pypdfium2.readthedocs.io/en/stable/

[17] Tesseract maintainers. Installation. https://tesseract-ocr.github.io/tessdoc/Installation.html

[18] Tesseract maintainers. Improving the quality of output. https://tesseract-ocr.github.io/tessdoc/ImproveQuality.html

[19] Ribeiro et al. Beyond Accuracy: Behavioral Testing of NLP Models with CheckList. ACL 2020. https://aclanthology.org/2020.acl-main.442/

[20] TimeBench: A Comprehensive Evaluation of Temporal Reasoning Abilities in Large Language Models. ACL 2024. https://aclanthology.org/2024.acl-long.66/

[21] TRAM: Benchmarking Temporal Reasoning for Large Language Models. Findings of ACL 2024. https://aclanthology.org/2024.findings-acl.382/

[22] Sentence Transformers maintainers. Retrieve and re-rank. https://sbert.net/examples/sentence_transformer/applications/retrieve_rerank/README.html

[23] OWASP. API Security Project. https://owasp.github.io/www-project-api-security/

[24] OWASP. File Upload Cheat Sheet. https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html

[25] W3C WAI. Understanding Status Messages. WCAG 2.2 guidance. https://www.w3.org/WAI/WCAG22/Understanding/status-messages.html

<!-- PAGE -->
## References: application and deployment

[26] SQLAlchemy maintainers. SQLite foreign-key support. https://docs.sqlalchemy.org/en/20/dialects/sqlite.html#foreign-key-support

[27] Alembic maintainers. Tutorial. https://alembic.sqlalchemy.org/en/latest/tutorial.html

[28] Vite maintainers. Releases and supported versions. Support status used during the September 2026 upgrade. https://vite.dev/releases

[29] Docker. Multi-stage builds. https://docs.docker.com/build/building/multi-stage/

[30] FastAPI. FastAPI in containers. https://fastapi.tiangolo.com/deployment/docker/

[31] PyJWT maintainers. Usage examples. Explicit HS256 encoding and decoding. https://pyjwt.readthedocs.io/en/stable/usage.html

### Repository and report scope

Project origin: https://github.com/vsingh3be24/swe

Inspected baseline: 4a47763c082a8ddd7b1a6bcecad87d33d98619d3.

Upgrade branch at evidence cutoff: work/research-led-upgrade.

This report consolidates the implementation and evidence available through 12 September 2026. It preserves the distinction between original prototype experiments, the upgraded live-source pilot, controlled acceptance fixtures and future research. Sources discussing general methods support design reasoning; they are not evidence of performance on FinalSay's notice collection.
