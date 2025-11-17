-- getUserEbooksList(user_id)
CREATE INDEX IF NOT EXISTS idx_ebook_libraries_user_ebook ON ebook_libraries (user_id, ebook_id);

CREATE INDEX IF NOT EXISTS idx_ebooks_book_id ON ebooks (book_id);

CREATE INDEX IF NOT EXISTS idx_ebooks_format_id ON ebooks (format_id);

--getTopGenres()
CREATE INDEX IF NOT EXISTS idx_bi_genre_product ON book_info (genre_id, product_id);

CREATE INDEX IF NOT EXISTS idx_order_item_product_id_incl_price ON order_item (product_id) INCLUDE (price);

-- getUserPreferences(userId)
CREATE INDEX IF NOT EXISTS idx_cgp_user_genre ON customer_genre_preferences (user_id, genre_id);

CREATE INDEX IF NOT EXISTS idx_cap_user_author ON customer_author_preferences (user_id, author_id);

CREATE INDEX IF NOT EXISTS idx_cpp_user_publisher ON customer_publisher_preferences (user_id, publisher_id);

CREATE INDEX IF NOT EXISTS idx_book_info_genre_id ON book_info (genre_id);

CREATE INDEX IF NOT EXISTS idx_book_info_author_id ON book_info (author_id);

CREATE INDEX IF NOT EXISTS idx_book_info_publisher_id ON book_info (publisher_id);

-- search(query)
CREATE INDEX IF NOT EXISTS idx_products_name_price ON products (name, price DESC);

CREATE INDEX IF NOT EXISTS idx_products_category_id ON products (category_id);

CREATE INDEX IF NOT EXISTS idx_products_shop_id ON products (shop_id);
