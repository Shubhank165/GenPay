"""
Agent API Router — Future NLP Integration Layer

This router is the entry point for the NLP agent. It receives natural language
queries, parses intent/entities, and calls the appropriate internal APIs.

Architecture:
  User → NLP Agent → Agent Router → Internal APIs → Agent composes response

Currently a placeholder that demonstrates the API contract.
"""
from fastapi import APIRouter, Depends
from ..core.security import get_current_user
from ..schemas import AgentQueryRequest, AgentQueryResponse

router = APIRouter(prefix="/agent", tags=["Agent (NLP Layer)"])


@router.post("/query", response_model=AgentQueryResponse)
async def agent_query(
    request: AgentQueryRequest,
    current_user: dict = Depends(get_current_user),
):
    """
    Process a natural language query from the agent layer.

    Example queries the agent might send:
    - "Plan a trip from Delhi to Goa in ₹10,000"
    - "Show my pending electricity bills"
    - "Find cheapest flight to Mumbai tomorrow"
    - "Recharge my phone with a 2GB/day plan under ₹300"

    The NLP layer (to be built) will:
    1. Parse intent (trip_planning, bill_query, flight_search, recharge)
    2. Extract entities (source, destination, budget, date, operator)
    3. Call appropriate internal APIs
    4. Aggregate and compose a natural language response

    Currently returns a structured placeholder response.
    """
    # Placeholder intent detection (future: actual NLP model)
    query_lower = request.query.lower()

    if any(w in query_lower for w in ["flight", "fly", "trip", "travel"]):
        intent = "travel_planning"
        entities = {"type": "flight", "query": request.query}
        summary = "I found travel options for your query. Use /travel/flights/search for actual results."
    elif any(w in query_lower for w in ["bill", "electricity", "gas", "water"]):
        intent = "bill_query"
        entities = {"type": "bill", "query": request.query}
        summary = "I can help with your bills. Use /services/bills to see pending bills."
    elif any(w in query_lower for w in ["recharge", "prepaid", "mobile"]):
        intent = "recharge"
        entities = {"type": "recharge", "query": request.query}
        summary = "Looking up recharge plans. Use /services/recharge/plans for options."
    elif any(w in query_lower for w in ["movie", "film", "show"]):
        intent = "movie_search"
        entities = {"type": "movie", "query": request.query}
        summary = "Searching movies. Use /travel/movies/search for showtimes."
    elif any(w in query_lower for w in ["send", "pay", "transfer"]):
        intent = "payment"
        entities = {"type": "upi_transfer", "query": request.query}
        summary = "I can help with payments. Use /transactions to create a transfer."
    else:
        intent = "general"
        entities = {"query": request.query}
        summary = "I'll help you with that. Please be more specific about what you need."

    return AgentQueryResponse(
        intent=intent,
        entities=entities,
        results=[],
        summary=summary,
        total_cost=None,
        suggestions=[
            "Try: 'Find flights from Delhi to Goa under ₹5000'",
            "Try: 'Show my pending bills'",
            "Try: 'Recharge plans for Jio under ₹300'",
        ],
    )


@router.get("/capabilities", response_model=dict)
async def get_capabilities():
    """
    Returns the list of capabilities the agent can use.
    This endpoint helps the NLP layer understand what APIs are available.
    """
    return {
        "capabilities": [
            {
                "intent": "flight_search",
                "endpoint": "POST /travel/flights/search",
                "parameters": ["origin", "destination", "date", "max_price", "max_stops", "cabin_class"],
                "description": "Search for flights between cities with optional price/stop filters",
            },
            {
                "intent": "bus_search",
                "endpoint": "POST /travel/buses/search",
                "parameters": ["origin", "destination", "date", "max_price", "bus_type"],
                "description": "Search for bus routes between cities",
            },
            {
                "intent": "hotel_search",
                "endpoint": "POST /travel/hotels/search",
                "parameters": ["city", "checkin", "checkout", "max_price", "min_rating"],
                "description": "Search for hotels in a city",
            },
            {
                "intent": "movie_search",
                "endpoint": "POST /travel/movies/search",
                "parameters": ["city", "title", "genre", "language", "date", "max_price"],
                "description": "Search for movies and showtimes",
            },
            {
                "intent": "recharge_plans",
                "endpoint": "GET /services/recharge/plans",
                "parameters": ["operator", "plan_type", "max_price"],
                "description": "Get mobile recharge plans",
            },
            {
                "intent": "bill_query",
                "endpoint": "GET /services/bills",
                "parameters": ["category", "unpaid_only"],
                "description": "Get user bills, filter by category or payment status",
            },
            {
                "intent": "transaction_history",
                "endpoint": "GET /transactions",
                "parameters": ["type", "status", "min_amount", "max_amount", "search"],
                "description": "Query transaction history with filters",
            },
            {
                "intent": "payment",
                "endpoint": "POST /transactions",
                "parameters": ["type", "amount", "recipient_name", "recipient_identifier"],
                "description": "Create a new payment/transaction",
            },
        ],
        "example_queries": [
            "Plan a trip from Delhi to Goa in ₹10,000",
            "Find the cheapest flight to Mumbai on April 15",
            "Show AC sleeper buses from Bangalore to Chennai under ₹800",
            "Book a hotel in Jaipur for 3 nights under ₹3000/night",
            "Find Hindi action movies playing in Delhi",
            "Show Jio recharge plans with 2GB/day",
            "What are my pending electricity bills?",
            "Send ₹500 to Priya Patel",
        ],
    }
