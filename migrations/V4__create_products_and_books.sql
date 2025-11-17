CREATE TABLE IF NOT EXISTS product_categories (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS products (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    image_url TEXT,
    category_id UUID NOT NULL REFERENCES product_categories(id) ON DELETE CASCADE,
    shop_id UUID NOT NULL REFERENCES shops(id) ON DELETE CASCADE,
    price DECIMAL NOT NULL
);

CREATE TABLE IF NOT EXISTS inventory (
     id UUID PRIMARY KEY,
     product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
     store_branch_id UUID NOT NULL REFERENCES shop_branches(id) ON DELETE CASCADE,
     quantity INT NOT NULL CHECK (quantity >= 0)
);

CREATE TABLE IF NOT EXISTS book_info (
    id UUID PRIMARY KEY,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES book_authors(id) ON DELETE CASCADE,
    genre_id UUID NOT NULL REFERENCES genres(id) ON DELETE CASCADE,
    publisher_id UUID NOT NULL REFERENCES publishers(id) ON DELETE CASCADE,
    type TEXT CHECK (type IN ('PAPER', 'EBOOK')) NOT NULL
);

CREATE TABLE IF NOT EXISTS ebook_format (
    id UUID PRIMARY KEY,
    format TEXT CHECK (format IN ('FB2', 'EPUB', 'PDF')) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS ebooks (
    id UUID PRIMARY KEY,
    book_id UUID NOT NULL REFERENCES book_info(id) ON DELETE CASCADE,
    format_id UUID NOT NULL REFERENCES ebook_format(id) ON DELETE CASCADE,
    file_url TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS ebook_libraries (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    ebook_id UUID NOT NULL REFERENCES ebooks(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS reviews (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    raiting INT CHECK (raiting >= 1 AND raiting <= 5),
    text TEXT
);