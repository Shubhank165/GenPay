# GenPay Agentic Backend (LangGraph + FastAPI)

Production-style prototype backend for autonomous financial workflows.

## What this implements

- FastAPI endpoint: `POST /agent/query`
- LangGraph orchestration:
  - intent -> context -> planner -> risk -> (confirm | execute) -> retry
- Local intent engine using finetuned DistilBERT + sentence-transformer + rules
- In-memory context memory (recent contacts, trusted recipients, recent transactions)
- Rule-based risk engine + human-in-the-loop confirmation
- Manual tool execution for send money and recharge
- Retry once on execution failure

## Folder layout

```text
app/
  main.py
  routes/
    agent.py
  core/
    config.py
    graph.py
    llm.py
    state.py
  nodes/
    intent.py
    context.py
    planner.py
    risk.py
    confirm.py
    execute.py
    retry.py
  tools/
    payments.py
    recharge.py
  memory/
    store.py
  models/
    schemas.py
```

## Setup

1. Create environment and install deps

```bash
cd backend
python3.11 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

2. Configure environment

```bash
cp .env.example .env
```

Set local model paths in `.env`:

- `DISTILBERT_MODEL_PATH` (finetuned intent classifier weights)
- `SENTENCE_TRANSFORMER_MODEL_PATH` (local embedding model for semantic routing)

3. Run API

```bash
uvicorn app.main:app --reload
```

## API usage

### Request

```http
POST /agent/query
Content-Type: application/json

{
  "user_id": "123",
  "message": "Pay Rahul 500"
}
```

### Case: confirmation required

```json
{
  "status": "confirmation_required",
  "message": "Send ₹500.0 to Rahul Sharma?",
  "risk_score": 70,
  "simulation": {
    "action": "send_money",
    "amount": 500.0,
    "recipient": "Rahul Sharma",
    "preview_message": "Send ₹500.0 to Rahul Sharma"
  }
}
```

### Confirm and execute

```http
POST /agent/query
Content-Type: application/json

{
  "user_id": "123",
  "message": "Pay Rahul 500",
  "user_confirmation": true
}
```

### Case: success

```json
{
  "status": "success",
  "message": "Action executed successfully",
  "transaction_id": "TXN-...",
  "risk_score": 70
}
```

### Case: failed

```json
{
  "status": "failed",
  "message": "Action could not be completed",
  "reason": "Missing required fields: amount"
}
```

## Notes

- The intent classifier runs fully local and does not call external LLM APIs.
- Booking intent is parsed but execution is intentionally marked as not implemented for extensibility.
