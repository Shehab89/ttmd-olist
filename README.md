# Talk To My Data (Olist) – Azure NL2SQL BI chat

SpikeUp AI traineeship capstone for The Gadget Store. Ask business questions in plain language; an AI agent queries a PostgreSQL star schema and returns answers or charts.

## Architecture
```
A. Data    PostgreSQL (OLTP) --Azure Data Factory (ETL + ELT)--> PostgreSQL (OLAP star schema: fact_order_item + 6 dims)
B. Serving Frontend (Container Apps) -> Azure AI Foundry agent (GPT-5 mini) -> AI Gateway (APIM)
           -> Azure MCP Server (Container Apps, read-only, managed identity) -> OLAP DB -> answer / chart
```

## Layout
| Folder | Contents |
|---|---|
| `adf/` | Data Factory pipelines, datasets, linked services, triggers (JSON) |
| `foundry/` | Agent instructions, exported agent definition, evaluation sets |
| `infra/` | ARM/Bicep export, Container Apps and APIM config |
| `sql/` | OLAP schema (DDL only) |
| `app/` | Frontend source |
| `docs/` | Final presentation, reports |

## Results
Execution accuracy 100% (target ≥90%) · latency 7.6 s P50 / 14.3 s P95 · 27/27 security prompts blocked · ~$0.008 per request.

## Reproduce
1. Open Azure Cloud Shell, clone this repo, then `PGUSER=<you> ./export.sh`.
2. `python foundry/export_agent.py` (needs `FOUNDRY_PROJECT_ENDPOINT`, `AGENT_ID`).
3. Review the secret-scan output; never commit keys, tokens or connection strings. Secrets live in Key Vault.

Dataset: [Olist Brazilian E-Commerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) (public).
Team: Shehab Al-Masri, Sena, Muna Alhammadi, Salahaddin, Abdullah. Mentors: Mark Rademaker, Quinten Tulp (Artefact).
