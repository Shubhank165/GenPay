from __future__ import annotations

from datetime import datetime, timedelta, timezone

from sqlalchemy import select

from .database import async_session
from ..models import (
    BankAccount,
    Bill,
    BillCategory,
    BusRoute,
    BusType,
    CabinClass,
    Flight,
    GoldPrice,
    Hotel,
    Movie,
    MovieLanguage,
    MovieShowtime,
    Offer,
    RechargePlan,
    Transaction,
    TransactionStatus,
    TransactionType,
    User,
)


def _utc_now() -> datetime:
    return datetime.now(timezone.utc)


async def seed_reference_data() -> None:
    """Seed richer static and demo data for realistic local/dev environments."""
    async with async_session() as session:
        now = _utc_now()

        existing_plan_keys = {
            (op, plan_type, float(price))
            for op, plan_type, price in (await session.execute(select(RechargePlan.operator, RechargePlan.plan_type, RechargePlan.price))).all()
        }
        recharge_candidates = [
            ("Jio", "data", 199, 18, "1.5GB", "Daily data + unlimited calls"),
            ("Jio", "data", 299, 28, "2GB", "Daily data + unlimited calls"),
            ("Jio", "unlimited", 399, 28, "2.5GB", "Truly unlimited 5G"),
            ("Jio", "talktime", 149, 0, None, "Talktime top-up"),
            ("Airtel", "data", 249, 24, "1GB", "Daily data + unlimited calls"),
            ("Airtel", "data", 359, 28, "2GB", "Daily data + OTT benefits"),
            ("Airtel", "unlimited", 489, 28, "3GB", "Premium unlimited"),
            ("Airtel", "talktime", 179, 0, None, "Talktime top-up"),
            ("Vi", "data", 239, 24, "1GB", "Daily data"),
            ("Vi", "data", 319, 30, "2GB", "Weekend data rollover"),
            ("Vi", "unlimited", 549, 30, "3GB", "Unlimited with OTT"),
            ("BSNL", "data", 187, 28, "2GB", "Value data pack"),
            ("BSNL", "data", 397, 150, "2GB", "Long validity data"),
        ]
        for operator, plan_type, price, validity, data_per_day, desc in recharge_candidates:
            key = (operator, plan_type, float(price))
            if key in existing_plan_keys:
                continue
            session.add(
                RechargePlan(
                    operator=operator,
                    plan_type=plan_type,
                    price=price,
                    validity_days=validity,
                    data_per_day=data_per_day,
                    description=desc,
                )
            )

        existing_offer_codes = {
            code for code in (await session.execute(select(Offer.coupon_code))).scalars().all() if code
        }
        offer_candidates = [
            ("10% off on flights", "Use code FLY10", "percentage", 10, "FLY10", "travel", 30),
            ("Flat 50 on bills", "On electricity bill payments", "flat", 50, "BILL50", "bills", 20),
            ("20% off bus bookings", "Weekend travel offer", "percentage", 20, "BUS20", "travel", 15),
            ("Flat 30 on recharge", "On packs above 299", "flat", 30, "RCH30", "recharge", 25),
            ("15% cashback on UPI", "For new merchants", "percentage", 15, "UPI15", "upi", 18),
            ("Movie tickets combo", "Flat 80 on partner cinemas", "flat", 80, "MOV80", "entertainment", 12),
            ("Hotel savings", "Up to 18% off stays", "percentage", 18, "STAY18", "travel", 28),
            ("Credit card bill saver", "Flat 100 on bill payments", "flat", 100, "CC100", "bills", 22),
        ]
        for title, desc, discount_type, discount_value, coupon, category, valid_days in offer_candidates:
            if coupon in existing_offer_codes:
                continue
            session.add(
                Offer(
                    title=title,
                    description=desc,
                    discount_type=discount_type,
                    discount_value=discount_value,
                    coupon_code=coupon,
                    category=category,
                    valid_from=now,
                    valid_till=now + timedelta(days=valid_days),
                    min_amount=0.0,
                    is_active=True,
                )
            )

        existing_flight_codes = set((await session.execute(select(Flight.flight_code))).scalars().all())
        flight_candidates = [
            ("IndiGo", "6E201", "Delhi", "DEL", "Mumbai", "BOM", 2, 4, 20, 140, 0, CabinClass.ECONOMY, 4850, 8),
            ("Air India", "AI887", "Delhi", "DEL", "Mumbai", "BOM", 4, 7, 0, 180, 1, CabinClass.ECONOMY, 4300, 14),
            ("Vistara", "UK945", "Delhi", "DEL", "Goa", "GOI", 3, 5, 35, 155, 0, CabinClass.ECONOMY, 6100, 11),
            ("SpiceJet", "SG452", "Delhi", "DEL", "Goa", "GOI", 6, 9, 5, 185, 1, CabinClass.ECONOMY, 5200, 26),
            ("IndiGo", "6E334", "Mumbai", "BOM", "Bengaluru", "BLR", 2, 3, 45, 105, 0, CabinClass.ECONOMY, 3900, 18),
            ("Air India", "AI603", "Mumbai", "BOM", "Bengaluru", "BLR", 5, 7, 0, 120, 1, CabinClass.ECONOMY, 3600, 21),
            ("Vistara", "UK811", "Bengaluru", "BLR", "Hyderabad", "HYD", 1, 2, 20, 60, 0, CabinClass.ECONOMY, 2500, 29),
            ("Akasa", "QP112", "Hyderabad", "HYD", "Chennai", "MAA", 3, 4, 20, 60, 0, CabinClass.ECONOMY, 2700, 24),
            ("IndiGo", "6E552", "Pune", "PNQ", "Delhi", "DEL", 7, 9, 20, 140, 0, CabinClass.ECONOMY, 4700, 12),
            ("Air India", "AI442", "Kolkata", "CCU", "Delhi", "DEL", 2, 4, 35, 155, 0, CabinClass.ECONOMY, 5600, 16),
        ]
        for airline, code, ocity, ocode, dcity, dcode, dep_h, arr_h, arr_m, dur, stops, cabin, price, seats in flight_candidates:
            if code in existing_flight_codes:
                continue
            session.add(
                Flight(
                    airline=airline,
                    flight_code=code,
                    origin_city=ocity,
                    origin_code=ocode,
                    destination_city=dcity,
                    destination_code=dcode,
                    departure_time=now + timedelta(days=1, hours=dep_h),
                    arrival_time=now + timedelta(days=1, hours=arr_h, minutes=arr_m),
                    duration_minutes=dur,
                    stops=stops,
                    cabin_class=cabin,
                    price=price,
                    available_seats=seats,
                    is_active=True,
                )
            )

        existing_bus_keys = {
            (operator, origin_city, destination_city, float(price))
            for operator, origin_city, destination_city, price in (
                await session.execute(select(BusRoute.operator, BusRoute.origin_city, BusRoute.destination_city, BusRoute.price))
            ).all()
        }
        bus_candidates = [
            ("RSRTC", BusType.AC_SLEEPER, "Delhi", "Jaipur", 1, 7, 0, 360, 799, 11, 4.2, '["wifi","charging"]'),
            ("RedBus Prime", BusType.AC_SEATER, "Delhi", "Chandigarh", 2, 6, 10, 250, 699, 16, 4.5, '["wifi","water"]'),
            ("Orange Travels", BusType.VOLVO, "Hyderabad", "Bengaluru", 4, 12, 0, 480, 1299, 9, 4.4, '["blanket","charging"]'),
            ("VRL", BusType.AC_SLEEPER, "Pune", "Goa", 5, 13, 30, 510, 1499, 7, 4.3, '["wifi","snacks"]'),
            ("KSRTC", BusType.SEMI_SLEEPER, "Bengaluru", "Chennai", 3, 9, 0, 360, 899, 20, 4.1, '["charging"]'),
        ]
        for operator, bus_type, origin_city, destination_city, dep_h, arr_h, arr_m, duration, price, seats, rating, amenities in bus_candidates:
            key = (operator, origin_city, destination_city, float(price))
            if key in existing_bus_keys:
                continue
            session.add(
                BusRoute(
                    operator=operator,
                    bus_type=bus_type,
                    origin_city=origin_city,
                    destination_city=destination_city,
                    departure_time=now + timedelta(days=1, hours=dep_h),
                    arrival_time=now + timedelta(days=1, hours=arr_h, minutes=arr_m),
                    duration_minutes=duration,
                    price=price,
                    available_seats=seats,
                    rating=rating,
                    amenities=amenities,
                )
            )

        existing_hotel_keys = {
            (name, city) for name, city in (await session.execute(select(Hotel.name, Hotel.city))).all()
        }
        hotel_candidates = [
            ("Blue Bay Resort", "Goa", "Candolim Beach Road", 4, 4.4, 4200, '["pool","wifi","breakfast"]', '["deluxe","suite"]'),
            ("Palm Grove Inn", "Goa", "Baga Road", 3, 4.1, 3100, '["wifi","parking"]', '["standard","deluxe"]'),
            ("Skyline Grand", "Mumbai", "Andheri East", 5, 4.6, 7800, '["pool","gym","wifi"]', '["executive","suite"]'),
            ("Tech Park Stay", "Bengaluru", "Whitefield", 4, 4.3, 5400, '["wifi","breakfast","workspace"]', '["standard","studio"]'),
            ("Heritage Palace", "Jaipur", "MI Road", 5, 4.7, 8300, '["spa","pool","restaurant"]', '["heritage","suite"]'),
            ("City Comfort", "Delhi", "Karol Bagh", 3, 4.0, 3600, '["wifi","parking"]', '["classic","premium"]'),
        ]
        for name, city, addr, stars, rating, price, amenities, room_types in hotel_candidates:
            if (name, city) in existing_hotel_keys:
                continue
            session.add(
                Hotel(
                    name=name,
                    city=city,
                    address=addr,
                    star_rating=stars,
                    user_rating=rating,
                    price_per_night=price,
                    amenities=amenities,
                    room_types=room_types,
                )
            )

        existing_movie_keys = {
            (title, language) for title, language in (await session.execute(select(Movie.title, Movie.language))).all()
        }
        movie_candidates = [
            ("Action Hero", "Action", MovieLanguage.HINDI, 145, 4.1, "UA", "High energy action thriller"),
            ("Code Storm", "Thriller", MovieLanguage.ENGLISH, 132, 4.3, "UA", "Cyber thriller around AI fraud"),
            ("Love in Monsoon", "Romance", MovieLanguage.HINDI, 128, 3.9, "U", "Light-hearted rainy season romance"),
            ("Rocket Ride", "Sci-Fi", MovieLanguage.TAMIL, 141, 4.4, "UA", "Space startup adventure"),
            ("Metro Files", "Drama", MovieLanguage.TELUGU, 150, 4.0, "UA", "City life anthology"),
            ("The Last Over", "Sports", MovieLanguage.ENGLISH, 136, 4.2, "U", "Cricket underdog story"),
        ]
        for title, genre, language, duration, rating, cert, desc in movie_candidates:
            if (title, language) in existing_movie_keys:
                continue
            session.add(
                Movie(
                    title=title,
                    genre=genre,
                    language=language,
                    duration_minutes=duration,
                    rating=rating,
                    certificate=cert,
                    release_date=now - timedelta(days=10),
                    description=desc,
                    is_active=True,
                )
            )

        existing_gold_timestamps = set((await session.execute(select(GoldPrice.recorded_at))).scalars().all())
        for day in range(30):
            ts = (now - timedelta(days=day)).replace(hour=9, minute=0, second=0, microsecond=0)
            if ts in existing_gold_timestamps:
                continue
            session.add(
                GoldPrice(
                    price_per_gram=7025 + ((day % 7) * 12) - (day * 1.5),
                    purity="24K",
                    recorded_at=ts,
                )
            )

        await session.flush()

        movies = (await session.execute(select(Movie))).scalars().all()
        existing_showtime_keys = {
            (city, theater_name, show_time)
            for city, theater_name, show_time in (
                await session.execute(select(MovieShowtime.city, MovieShowtime.theater_name, MovieShowtime.show_time))
            ).all()
        }
        for mv in movies:
            for city, theater, hour, price in [
                ("Delhi", "PVR Select City", 12, 280),
                ("Delhi", "INOX Saket", 18, 320),
                ("Mumbai", "Cinepolis Andheri", 15, 350),
                ("Bengaluru", "PVR Orion", 21, 300),
            ]:
                show_time = now.replace(hour=hour, minute=0, second=0, microsecond=0) + timedelta(days=1)
                key = (city, theater, show_time)
                if key in existing_showtime_keys:
                    continue
                session.add(
                    MovieShowtime(
                        movie_id=mv.id,
                        theater_name=theater,
                        city=city,
                        screen="Screen 1",
                        show_time=show_time,
                        price=price,
                        available_seats=180,
                        is_active=True,
                    )
                )

        user_count = len((await session.execute(select(User.id))).scalars().all())
        if user_count == 0:
            demo_users = [
                ("+919876543210", "Aarav Sharma", "aarav@genpay.app", "aarav@upi", 8450.25),
                ("+919112223334", "Priya Nair", "priya@genpay.app", "priya@upi", 5200.80),
                ("+919998887776", "Rohan Mehta", "rohan@genpay.app", "rohan@upi", 11600.40),
                ("+919090807060", "Neha Kapoor", "neha@genpay.app", "neha@upi", 3740.90),
                ("+918888777666", "Vikram Das", "vikram@genpay.app", "vikram@upi", 9300.00),
            ]
            created_users: list[User] = []
            for phone, name, email, upi, wallet in demo_users:
                user = User(
                    phone=phone,
                    name=name,
                    email=email,
                    password_hash="seeded_password_hash",
                    upi_id=upi,
                    wallet_balance=wallet,
                    is_active=True,
                )
                session.add(user)
                created_users.append(user)

            await session.flush()

            for idx, user in enumerate(created_users):
                session.add(
                    BankAccount(
                        user_id=user.id,
                        bank_name="State Bank of India" if idx % 2 == 0 else "HDFC Bank",
                        account_number=f"30925678{431 + idx}",
                        ifsc_code="SBIN0001234" if idx % 2 == 0 else "HDFC0001234",
                        upi_id=f"{user.phone}@bank",
                        balance=30000 + (idx * 4500),
                        is_default=True,
                        is_active=True,
                    )
                )
                session.add(
                    Bill(
                        user_id=user.id,
                        category=BillCategory.ELECTRICITY,
                        provider_name="State Power Board",
                        consumer_number=f"ELEC{1000 + idx}",
                        amount=1250 + (idx * 80),
                        due_date=now + timedelta(days=5 + idx),
                        is_paid=False,
                    )
                )
                session.add(
                    Bill(
                        user_id=user.id,
                        category=BillCategory.BROADBAND,
                        provider_name="FiberNet",
                        consumer_number=f"BB{2000 + idx}",
                        amount=899 + (idx * 40),
                        due_date=now + timedelta(days=8 + idx),
                        is_paid=False,
                    )
                )
                session.add(
                    Transaction(
                        user_id=user.id,
                        type=TransactionType.UPI_TRANSFER,
                        status=TransactionStatus.SUCCESS,
                        amount=450 + (idx * 30),
                        currency="INR",
                        recipient_name="Local Merchant",
                        recipient_identifier="merchant@upi",
                        description="UPI payment at local store",
                        reference_id=f"SEEDUPI{idx}",
                        created_at=now - timedelta(days=idx + 1),
                        updated_at=now - timedelta(days=idx + 1),
                    )
                )
                session.add(
                    Transaction(
                        user_id=user.id,
                        type=TransactionType.RECHARGE,
                        status=TransactionStatus.SUCCESS,
                        amount=299,
                        currency="INR",
                        recipient_name="Mobile Recharge",
                        recipient_identifier=user.phone,
                        description="Monthly mobile recharge",
                        reference_id=f"SEEDRCH{idx}",
                        created_at=now - timedelta(days=idx + 3),
                        updated_at=now - timedelta(days=idx + 3),
                    )
                )
                session.add(
                    Transaction(
                        user_id=user.id,
                        type=TransactionType.BILL_PAYMENT,
                        status=TransactionStatus.SUCCESS,
                        amount=1100 + (idx * 50),
                        currency="INR",
                        recipient_name="State Power Board",
                        recipient_identifier=f"ELEC{1000 + idx}",
                        description="Electricity bill payment",
                        reference_id=f"SEEDBILL{idx}",
                        created_at=now - timedelta(days=idx + 6),
                        updated_at=now - timedelta(days=idx + 6),
                    )
                )

        await session.commit()
