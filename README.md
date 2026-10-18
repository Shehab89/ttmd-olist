# Talk To My Data (Olist): an Azure NL2SQL BI chat

![Azure Data Factory](https://img.shields.io/badge/Azure_Data_Factory-ETL%2FELT-0078D4?logo=microsoftazure&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-star_schema-4169E1?logo=postgresql&logoColor=white)
![Azure AI Foundry](https://img.shields.io/badge/Azure_AI_Foundry-GPT--5_mini-5C2D91?logo=microsoftazure&logoColor=white)
![React](https://img.shields.io/badge/React_19-TypeScript-61DAFB?logo=react&logoColor=black)

Business users ask questions in plain language. An AI agent writes read-only SQL against a PostgreSQL star schema and answers with numbers, tables or charts.

This is the capstone of the **SpikeUp AI data engineering traineeship**, built for the client *The Gadget Store* on the public [Olist Brazilian e-commerce dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (~100k orders, 2016–2018).

<p align="center">
  <img src="docs/screenshots/01-answer.png" width="32%" alt="Plain-language question answered with exact figures and scope">
  <img src="docs/screenshots/02-chart.png" width="32%" alt="Agent-generated bar chart of top 10 categories by revenue">
  <img src="docs/screenshots/03-security.png" width="32%" alt="Credential probe refused by the agent's gatekeeper">
</p>
<p align="center"><sub>Plain-language answer with stated scope · generated chart · credential probe refused</sub></p>

## Results

| Metric | Result | Target |
|---|---|---|
| Execution accuracy | **100%** | ≥ 90% |
| Latency | **7.6 s** P50 / 14.3 s P95 | – |
| Security prompts blocked | **27 / 27** | 100% |
| Cost per request | **~$0.008** | – |

## Architecture

```mermaid
flowchart LR
    subgraph A[Data layer]
        OLTP[(PostgreSQL<br/>olist_oltp)] -->|ADF pipeline<br/>pl_oltp_to_olap| OLAP[(PostgreSQL<br/>olist_olap<br/>star schema)]
    end
    subgraph B[Serving layer]
        UI[React chat UI<br/>Container Apps] --> AG[Azure AI Foundry agent<br/>GPT-5 mini]
        AG --> GW[AI Gateway<br/>APIM]
        GW --> MCP[Azure MCP Server<br/>read-only, managed identity]
    end
    MCP --> OLAP
```

**Star schema:** `fact_order_item` (order line grain) joined to `dim_date`, `dim_customer`, `dim_seller`, `dim_product`, `dim_category` and `dim_geography`, plus a `dq_report` table that logs data-quality checks on every run.

## Security model

- **Read-only by design.** The MCP server connects with a managed identity that only has read access on the OLAP database. It cannot change data, even if a prompt asks it to.
- **Gatekeeper prompt.** Off-topic questions, questions about credentials or infrastructure, and requests to change data get one fixed refusal sentence (see [`foundry/agent_instructions.md`](foundry/agent_instructions.md)).
- **Platform guardrails.** Jailbreak attempts such as "ignore previous instructions" are rejected at the platform layer, and the UI only shows a generic error.
- **No secrets in the repo.** Linked services hold placeholders, and real credentials live in Key Vault or managed identities.

## Repository layout

| Folder | Contents |
|---|---|
| [`adf/`](adf/) | Data Factory pipeline, datasets, linked services and factory definition (ADF Git format) |
| [`sql/`](sql/) | DDL for the OLTP source and the OLAP star schema |
| [`foundry/`](foundry/) | Agent instructions and a script to export the agent definition |
| [`app/`](app/) | React + TypeScript chat frontend (Vite, Tailwind, Playwright e2e tests) |
| [`docs/`](docs/) | Screenshots |
| [`export.sh`](export.sh) | Exports Azure config (ADF, Container Apps, APIM, schema) from Cloud Shell, with a built-in secret scan |

## Reproduce

1. **Database:** create `olist_oltp` and `olist_olap` on Azure Database for PostgreSQL, apply [`sql/01_oltp_schema.sql`](sql/01_oltp_schema.sql) and [`sql/02_olap_schema.sql`](sql/02_olap_schema.sql), then load the Olist CSVs into the OLTP database.
2. **ETL:** import [`adf/`](adf/) into a Data Factory through Git integration, set the server, user and credential on `ls_pg_oltp` / `ls_pg_olap`, then run `pl_oltp_to_olap`.
3. **Agent:** create an Azure AI Foundry agent with [`foundry/agent_instructions.md`](foundry/agent_instructions.md) and a read-only PostgreSQL MCP connection named `olist`.
4. **Frontend:** see [`app/README.md`](app/README.md).

To refresh this repo from a live environment, run `PGUSER=<you> ./export.sh` in Azure Cloud Shell and `python foundry/export_agent.py`. Review the secret-scan output before committing.

## Team

Shehab Al-Masri · Sena · Muna Alhammadi · Salahaddin · Abdullah
Mentors: Mark Rademaker, Quinten Tulp (Artefact)
