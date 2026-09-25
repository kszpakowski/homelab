BEGIN;

CREATE TABLE IF NOT EXISTS trips (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  title varchar(255) NOT NULL,
  slug varchar(255) NOT NULL UNIQUE,
  summary text,
  status varchar(32) NOT NULL DEFAULT 'draft'
    CHECK (status IN ('draft', 'planned', 'active', 'completed', 'archived')),
  start_date date,
  end_date date,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date)
);

CREATE TABLE IF NOT EXISTS places (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name varchar(255) NOT NULL,
  address text,
  latitude numeric(9, 6),
  longitude numeric(9, 6),
  website text,
  notes text,
  cover_image uuid REFERENCES directus_files(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (latitude IS NULL OR latitude BETWEEN -90 AND 90),
  CHECK (longitude IS NULL OR longitude BETWEEN -180 AND 180)
);

CREATE TABLE IF NOT EXISTS days (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  trip_id bigint NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
  day_number integer NOT NULL CHECK (day_number > 0),
  date date,
  title varchar(255),
  notes text,
  UNIQUE (trip_id, day_number)
);

CREATE TABLE IF NOT EXISTS stops (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  day_id bigint NOT NULL REFERENCES days(id) ON DELETE CASCADE,
  place_id bigint NOT NULL REFERENCES places(id) ON DELETE RESTRICT,
  position integer NOT NULL CHECK (position > 0),
  arrival_at timestamptz,
  departure_at timestamptz,
  duration_minutes integer CHECK (duration_minutes IS NULL OR duration_minutes >= 0),
  notes text,
  UNIQUE (day_id, position),
  CHECK (departure_at IS NULL OR arrival_at IS NULL OR departure_at >= arrival_at)
);

CREATE INDEX IF NOT EXISTS days_trip_id_idx ON days (trip_id);
CREATE INDEX IF NOT EXISTS stops_day_id_idx ON stops (day_id);
CREATE INDEX IF NOT EXISTS stops_place_id_idx ON stops (place_id);

COMMIT;

