from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_
from typing import Optional
from datetime import datetime
from ..auth.middleware import get_current_user
from ..core.database import get_db
from ..models import Flight, BusRoute, Hotel, Movie, MovieShowtime
from ..services.local_fallback import (
    search_flights as local_search_flights,
    get_flight as local_get_flight,
    search_buses as local_search_buses,
    search_hotels as local_search_hotels,
    search_movies as local_search_movies,
)
from ..schemas import (
    FlightSearchRequest, FlightSearchResponse, FlightResponse,
    BusSearchRequest, BusResponse,
    HotelSearchRequest, HotelResponse,
    MovieSearchRequest, MovieResponse, ShowtimeResponse,
)

router = APIRouter(prefix="/travel", tags=["Travel & Entertainment"])


# ─── FLIGHTS ───

@router.post("/flights/search", response_model=FlightSearchResponse)
async def search_flights(req: FlightSearchRequest, db: AsyncSession = Depends(get_db)):
    """Search flights — agent sends origin, destination, date, budget constraints."""
    try:
        query = select(Flight).where(
            Flight.is_active == True,
            Flight.origin_code.ilike(f"%{req.origin}%") | Flight.origin_city.ilike(f"%{req.origin}%"),
            Flight.destination_code.ilike(f"%{req.destination}%") | Flight.destination_city.ilike(f"%{req.destination}%"),
        )
        if req.max_price:
            query = query.where(Flight.price <= req.max_price)
        if req.max_stops is not None:
            query = query.where(Flight.stops <= req.max_stops)

        query = query.order_by(Flight.price.asc())
        result = await db.execute(query)
        flights = result.scalars().all()
        cheapest = min((f.price for f in flights), default=None)
        fastest = min((f.duration_minutes for f in flights), default=None)
        return FlightSearchResponse(
            flights=[FlightResponse.model_validate(f) for f in flights],
            total=len(flights),
            cheapest=cheapest,
            fastest_minutes=fastest,
        )
    except Exception:
        flights = local_search_flights(req.origin, req.destination, req.max_price, req.max_stops)
        cheapest = min((f["price"] for f in flights), default=None)
        fastest = min((f["duration_minutes"] for f in flights), default=None)
        return FlightSearchResponse(
            flights=[FlightResponse.model_validate(f) for f in flights],
            total=len(flights),
            cheapest=cheapest,
            fastest_minutes=fastest,
        )


@router.get("/flights/{flight_id}", response_model=FlightResponse)
async def get_flight(flight_id: str, db: AsyncSession = Depends(get_db)):
    """Get flight details by ID."""
    from fastapi import HTTPException

    try:
        result = await db.execute(select(Flight).where(Flight.id == flight_id))
        flight = result.scalar_one_or_none()
        if not flight:
            raise HTTPException(status_code=404, detail="Flight not found")
        return flight
    except HTTPException:
        raise
    except Exception:
        flight = local_get_flight(flight_id)
        if not flight:
            raise HTTPException(status_code=404, detail="Flight not found")
        return FlightResponse.model_validate(flight)


# ─── BUSES ───

@router.post("/buses/search", response_model=list[BusResponse])
async def search_buses(req: BusSearchRequest, db: AsyncSession = Depends(get_db)):
    """Search bus routes — agent-queryable by route, price, type."""
    try:
        query = select(BusRoute).where(
            BusRoute.is_active == True,
            BusRoute.origin_city.ilike(f"%{req.origin}%"),
            BusRoute.destination_city.ilike(f"%{req.destination}%"),
        )
        if req.max_price:
            query = query.where(BusRoute.price <= req.max_price)
        if req.bus_type:
            query = query.where(BusRoute.bus_type == req.bus_type)

        query = query.order_by(BusRoute.price.asc())
        result = await db.execute(query)
        buses = result.scalars().all()
        return [BusResponse.model_validate(b) for b in buses]
    except Exception:
        buses = local_search_buses(req.origin, req.destination, req.max_price, req.bus_type)
        return [BusResponse.model_validate(b) for b in buses]


# ─── HOTELS ───

@router.post("/hotels/search", response_model=list[HotelResponse])
async def search_hotels(req: HotelSearchRequest, db: AsyncSession = Depends(get_db)):
    """Search hotels — agent-queryable by city, price, rating."""
    try:
        query = select(Hotel).where(Hotel.is_active == True, Hotel.city.ilike(f"%{req.city}%"))
        if req.max_price:
            query = query.where(Hotel.price_per_night <= req.max_price)
        if req.min_rating:
            query = query.where(Hotel.user_rating >= req.min_rating)

        query = query.order_by(Hotel.price_per_night.asc())
        result = await db.execute(query)
        hotels = result.scalars().all()
        return [HotelResponse.model_validate(h) for h in hotels]
    except Exception:
        hotels = local_search_hotels(req.city, req.max_price, req.min_rating)
        return [HotelResponse.model_validate(h) for h in hotels]


# ─── MOVIES ───

@router.post("/movies/search", response_model=list[MovieResponse])
async def search_movies(req: MovieSearchRequest, db: AsyncSession = Depends(get_db)):
    """Search movies — agent-queryable by city, title, genre, language."""
    try:
        query = select(Movie).where(Movie.is_active == True)
        if req.title:
            query = query.where(Movie.title.ilike(f"%{req.title}%"))
        if req.genre:
            query = query.where(Movie.genre.ilike(f"%{req.genre}%"))
        if req.language:
            query = query.where(Movie.language == req.language)

        result = await db.execute(query)
        movies = result.scalars().all()
        return [MovieResponse.model_validate(m) for m in movies]
    except Exception:
        movies = local_search_movies(req.title, req.genre, req.language)
        return [MovieResponse.model_validate(m) for m in movies]
