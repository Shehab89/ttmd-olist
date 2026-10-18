# SQL

| File | Database | Purpose |
|---|---|---|
| [`01_oltp_schema.sql`](01_oltp_schema.sql) | `olist_oltp` | Source tables that mirror the Olist CSVs (orders, items, payments, reviews, customers, sellers, products, geolocation) |
| [`02_olap_schema.sql`](02_olap_schema.sql) | `olist_olap` | Star schema: `fact_order_item`, six dimensions, and the `dq_report` data-quality log |

```bash
psql -d olist_oltp -v ON_ERROR_STOP=1 -f sql/01_oltp_schema.sql
psql -d olist_olap -v ON_ERROR_STOP=1 -f sql/02_olap_schema.sql
```

`02_olap_schema.sql` drops and recreates its tables. The OLAP tables are loaded by the ADF pipeline in [`../adf`](../adf).
