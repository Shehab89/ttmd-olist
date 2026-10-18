"""Export the Foundry agent definition (no secrets). pip install azure-ai-projects azure-identity"""
import json, os
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential

c = AIProjectClient(endpoint=os.environ["FOUNDRY_PROJECT_ENDPOINT"], credential=DefaultAzureCredential())
a = c.agents.get_agent(os.environ["AGENT_ID"])
d = a.as_dict()
d.pop("id", None)
json.dump(d, open("foundry/agent.json", "w"), indent=2)
print("saved foundry/agent.json - review for secrets before committing")
