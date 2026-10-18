#!/usr/bin/env bash
# Run in Azure Cloud Shell (bash) from the repo root. Exports config only, no data.
set -euo pipefail
RG=${RG:-rg-tgs-project}
PGHOST=${PGHOST:-tgsdb.postgres.database.azure.com}
PGDB=${PGDB:-olist_olap}
PGUSER=${PGUSER:?set PGUSER (your Entra/PG user)}

echo "== Resource group (ARM + Bicep)"
az group export -n "$RG" --skip-all-params > infra/main.json || true
az bicep decompile --file infra/main.json 2>/dev/null || true

echo "== Container Apps"
for a in $(az containerapp list -g "$RG" --query "[].name" -o tsv); do
  az containerapp show -n "$a" -g "$RG" -o yaml > "infra/containerapp-$a.yaml"
done

echo "== APIM / AI Gateway"
az apim list -g "$RG" -o json > infra/apim.json || true

echo "== Data Factory"
az extension add --name datafactory --only-show-errors || true
for F in $(az datafactory list -g "$RG" --query "[].name" -o tsv); do
  for t in pipeline dataset linked-service trigger; do
    mkdir -p "adf/$t"
    az datafactory "$t" list -g "$RG" --factory-name "$F" -o json > "adf/$t/$F.json" || true
  done
done

echo "== Postgres schema only"
export PGPASSWORD=$(az account get-access-token --resource-type oss-rdbms --query accessToken -o tsv)
pg_dump "host=$PGHOST dbname=$PGDB user=$PGUSER sslmode=require" \
  --schema-only --no-owner --no-privileges > sql/olap_schema.sql

echo "== Secret scan (review every hit, replace with <from-key-vault>)"
grep -rniE "password|secret|accountkey|sig=|apikey|connectionstring|BEGIN .*PRIVATE" \
  --exclude-dir=.git --exclude=export.sh . || echo "no hits"
