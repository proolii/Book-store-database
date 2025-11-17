CREATE TABLE IF NOT EXISTS genres (
    id UUID PRIMARY KEY,
    name TEXT NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS book_authors (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS publishers (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

CREATE TABLE IF NOT EXISTS customer_genre_preferences (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    genre_id UUID NOT NULL REFERENCES genres(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, genre_id)
);

CREATE TABLE IF NOT EXISTS customer_author_preferences (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES book_authors(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, author_id)
);

CREATE TABLE IF NOT EXISTS customer_publisher_preferences (
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    publisher_id UUID NOT NULL REFERENCES publishers(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, publisher_id)
);
