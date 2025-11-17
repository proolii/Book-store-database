CREATE TABLE IF NOT EXISTS wishlists (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS cart_item (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    quantity INT NOT NULL CHECK (quantity > 0)
);

CREATE TABLE IF NOT EXISTS delivery (
    id UUID PRIMARY KEY,
    address TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS promocode (
    id UUID PRIMARY KEY,
    code TEXT NOT NULL,
    discount_percent DECIMAL CHECK (discount_percent >= 0 AND discount_percent <= 100),
    start_date TIMESTAMP NOT NULL,
    end_date TIMESTAMP NOT NULL
);

CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    delivery_id UUID REFERENCES delivery(id),
    promocode_id UUID REFERENCES promocode(id),
    total_price DECIMAL NOT NULL,
    status TEXT CHECK (status IN ('PENDING', 'PAID', 'SHIPPED', 'SENT', 'DELIVERED')) NOT NULL
);

CREATE TABLE IF NOT EXISTS order_item (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    price DECIMAL NOT NULL
);

CREATE TABLE IF NOT EXISTS return_request (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    return_reason TEXT,
    status TEXT CHECK (status IN ('REQUESTED', 'SHIPPED', 'CONFIRMED', 'COMPLETED')) NOT NULL
);