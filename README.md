# I.Atlas - Intelligent Financial Extraction & Auditing Engine

> **Note:** This is a sanitized showcase repository demonstrating the architecture and engineering principles behind I.Atlas. Proprietary business logic, advanced regex patterns, and production prompts have been redacted.

I.Atlas is a comprehensive B2B SaaS platform designed to automate accounting workflows, audit tax invoices, and detect financial anomalies for tax advisors and financial managers. 

Unlike standard wrapper applications, I.Atlas features a robust, multi-process architecture handling asynchronous document processing, semantic search, and a strict hybrid extraction pipeline.

##  System Architecture

The platform operates on a microservices-oriented architecture to ensure scalability and separation of concerns.

```mermaid
graph TD
    %% Define Nodes
    Client[Streamlit Frontend]
    FastAPI[FastAPI Backend]
    Celery[Celery Workers]
    Redis[(Redis Message Broker)]
    PG[(PostgreSQL + pgvector)]
    AWS[AWS S3 Storage]
    LLM[LLM APIs: Groq / OpenAI]

    %% Define Flows
    Client -- Uploads Invoice PDF --> FastAPI
    FastAPI -- Saves Raw File --> AWS
    FastAPI -- Enqueues Task --> Redis
    Redis -- Distributes Job --> Celery
    Celery -- Fetches File --> AWS
    Celery -- Hybrid Extraction Pipeline --> LLM
    Celery -- Saves Parsed Data & Vectors --> PG
    Client -- Queries Status / Data --> FastAPI
    FastAPI -- Reads Validated Data --> PG

The Hybrid Extraction Pipeline
A core engineering decision in I.Atlas is the refusal to rely solely on Large Language Models for deterministic financial data. The extraction pipeline is multi-layered, prioritizing speed, cost-efficiency, and absolute deterministic accuracy before falling back to AI:

Direct Parsers & Structural OCR: Attempts to read standard structural formats (e.g., specific ERP outputs).

Advanced Regex Engine: Captures strict patterns for VAT numbers, standard tax brackets (21%, 10%, 4%), and absolute monetary values.

LLM Fallback (Groq / OpenAI): Only invoked for highly unstructured layouts, complex vendor identification, or semantic reasoning when deterministic methods yield low confidence.

Mathematical Arbitration: A strict Pandas-powered validation layer cross-references all extracted values (ensuring Base + Tax == Total). Anomalies flag the document for human-in-the-loop (HITL) review.

Tech Stack
Backend: Python, FastAPI, SQLAlchemy, Alembic.

Asynchronous Processing: Celery, Redis.

Database: PostgreSQL (with pgvector for semantic embeddings).

Frontend: Streamlit.

Infrastructure & DevOps: Docker, Docker Compose, AWS S3, GitHub Actions.

Testing: pytest (Isolated suites without external service dependencies).

Technical Demonstration (Pipeline Mock)
To see the hybrid pipeline logic in action without external API keys, run the isolated test suite utilizing mock data:

Bash
# Run the test suite
pytest tests/test_pipeline_demo.py -v