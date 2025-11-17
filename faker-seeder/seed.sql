CREATE EXTENSION IF NOT EXISTS plpython3u;
CREATE EXTENSION IF NOT EXISTS pgcrypto;
CREATE SCHEMA IF NOT EXISTS faker;
CREATE EXTENSION IF NOT EXISTS faker SCHEMA faker;

DO $$
    BEGIN
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'users') THEN
            EXECUTE format($insert$
        INSERT INTO users (id, email, password, full_name, role)
        SELECT
            gen_random_uuid(),
            lower(faker.unique_email()),
            faker.password(),
            faker.name(),
            CASE WHEN random() < 0.5 THEN 'SELLER' ELSE 'CLIENT' END
        FROM generate_series(1, __SEED_COUNT__)
        $insert$);
        END IF;

        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'contact_info') THEN
            EXECUTE format($insert$
        INSERT INTO contact_info (id, user_id, phone, address)
        SELECT
            gen_random_uuid(),
            (SELECT id FROM users ORDER BY random() LIMIT 1),
            faker.phone_number(),
            faker.address()
        FROM generate_series(1, __SEED_COUNT__)
        $insert$);
        END IF;

        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'payment_method') THEN
            EXECUTE format($insert$
        INSERT INTO payment_method (id, user_id, type, account_number)
        SELECT
            gen_random_uuid(),
            (SELECT id FROM users ORDER BY random() LIMIT 1),
            CASE WHEN random() < 0.5 THEN 'CARD' ELSE 'WALLET' END,
            faker.credit_card_number()
        FROM generate_series(1, __SEED_COUNT__)
        $insert$);
        END IF;
    END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION faker.book_genre() RETURNS text
AS $$
from faker import Faker
import random
faker = Faker()
genres = [
    'Fantasy', 'Science Fiction', 'Mystery', 'Thriller', 'Romance',
    'Western', 'Dystopian', 'Contemporary', 'Historical', 'Horror',
    'Memoir', 'Biography', 'Self-help', 'Health', 'Travel',
    'Guide', 'Children\'s', 'Religion', 'Science', 'History'
]
return random.choice(genres)
$$ LANGUAGE plpython3u;


DO $$
    BEGIN
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'genres') THEN
            EXECUTE format($insert$
        INSERT INTO genres (id, name)
        SELECT
            gen_random_uuid() AS id,
            faker.book_genre() AS name
        FROM generate_series(1, __SEED_COUNT__)
        ON CONFLICT(name) DO NOTHING
        $insert$);
        END IF;

        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'book_authors') THEN
            EXECUTE format($insert$
        INSERT INTO book_authors (id, name)
        SELECT
            gen_random_uuid() AS id,
            faker.name() AS name
        FROM generate_series(1, __SEED_COUNT__)
        $insert$);
        END IF;

        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'publishers') THEN
            EXECUTE format($insert$
        INSERT INTO publishers (id, name)
        SELECT
            gen_random_uuid() AS id,
            faker.company() AS name
        FROM generate_series(1, __SEED_COUNT__)
        $insert$);
        END IF;

        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'shops') THEN
            EXECUTE format($insert$
        INSERT INTO shops (id, seller_id, name)
        SELECT
            gen_random_uuid() AS id,
            (SELECT id FROM users WHERE role = 'SELLER' ORDER BY random() LIMIT 1) AS seller_id,
            faker.company() AS name
        FROM generate_series(1, __SEED_COUNT__)
        $insert$);
        END IF;

        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'shop_branches') THEN
            EXECUTE format($insert$
        INSERT INTO shop_branches (id, shop_id, address)
        SELECT
            gen_random_uuid() AS id,
            (SELECT id FROM shops ORDER BY random() LIMIT 1) AS shop_id,
            faker.address() AS address
        FROM generate_series(1, __SEED_COUNT__)
        $insert$);
        END IF;
    END
$$ LANGUAGE plpgsql;


DO $$
    DECLARE
        v_user_id UUID;
        v_genre_id UUID;
        v_author_id UUID;
        v_publisher_id UUID;
        v_shop_id UUID;
        i INT := 0;
    BEGIN
        WHILE i < __SEED_COUNT__ LOOP
                SELECT id INTO v_user_id FROM users ORDER BY random() LIMIT 1;
                SELECT id INTO v_genre_id FROM genres ORDER BY random() LIMIT 1;

                BEGIN
                    INSERT INTO customer_genre_preferences (user_id, genre_id)
                    VALUES (v_user_id, v_genre_id);
                    i := i + 1;
                EXCEPTION WHEN unique_violation THEN
                    CONTINUE;
                END;
            END LOOP;

        i := 0;
        WHILE i < __SEED_COUNT__ LOOP
                SELECT id INTO v_user_id FROM users ORDER BY random() LIMIT 1;
                SELECT id INTO v_author_id FROM book_authors ORDER BY random() LIMIT 1;

                BEGIN
                    INSERT INTO customer_author_preferences (user_id, author_id)
                    VALUES (v_user_id, v_author_id);
                    i := i + 1;
                EXCEPTION WHEN unique_violation THEN
                    CONTINUE;
                END;
            END LOOP;

        i := 0;
        WHILE i < __SEED_COUNT__ LOOP
                SELECT id INTO v_user_id FROM users ORDER BY random() LIMIT 1;
                SELECT id INTO v_publisher_id FROM publishers ORDER BY random() LIMIT 1;

                BEGIN
                    INSERT INTO customer_publisher_preferences (user_id, publisher_id)
                    VALUES (v_user_id, v_publisher_id);
                    i := i + 1;
                EXCEPTION WHEN unique_violation THEN
                    CONTINUE;
                END;
            END LOOP;

        i := 0;
        WHILE i < __SEED_COUNT__ LOOP
                SELECT id INTO v_user_id FROM users ORDER BY random() LIMIT 1;
                SELECT id INTO v_shop_id FROM shops ORDER BY random() LIMIT 1;

                BEGIN
                    INSERT INTO customer_shop_preferences (user_id, shop_id)
                    VALUES (v_user_id, v_shop_id);
                    i := i + 1;
                EXCEPTION WHEN unique_violation THEN
                    CONTINUE;
                END;
            END LOOP;
    END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION faker.product_category() RETURNS text
AS $$
from faker import Faker
import random
faker = Faker()
product_categories = ['Books', 'Chancellery', 'Creative products', 'Textbooks']
return random.choice(product_categories)
$$ LANGUAGE plpython3u;


DO $$
    BEGIN
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'product_categories') THEN
            EXECUTE format($insert$
        INSERT INTO product_categories (id, name)
        SELECT
            gen_random_uuid() AS id,
            faker.product_category() AS name
        FROM generate_series(1, __SEED_COUNT__)
        ON CONFLICT (name) DO NOTHING
        $insert$);
        END IF;

        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'products') THEN
            EXECUTE format($insert$
        INSERT INTO products (id, name, description, image_url, category_id, shop_id, price)
        SELECT
            gen_random_uuid() AS id,
            faker.word() AS name,
            faker.text() AS description,
            faker.uri() AS image_url,
            (SELECT id FROM product_categories ORDER BY random() LIMIT 1) AS category_id,
            (SELECT id FROM shops ORDER BY random() LIMIT 1) AS shop_id,
            round(random() * 100 + 1) AS price
        FROM generate_series(1, 2 * __SEED_COUNT__)
        $insert$);
        END IF;

        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'inventory') THEN
            EXECUTE format($insert$
        INSERT INTO inventory (id, product_id, store_branch_id, quantity)
        SELECT
            gen_random_uuid() AS id,
            (SELECT id FROM products ORDER BY random() LIMIT 1) AS product_id,
            (SELECT id FROM shop_branches ORDER BY random() LIMIT 1) AS store_branch_id,
            round(random() * 100 + 1) AS quantity
        FROM generate_series(1, __SEED_COUNT__)
        $insert$);
        END IF;
    END
$$ LANGUAGE plpgsql;


DO $$
    BEGIN
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'book_info') THEN
            EXECUTE format($insert$
        INSERT INTO book_info (id, product_id, author_id, genre_id, publisher_id, type)
        SELECT
            gen_random_uuid() AS id,
            (SELECT id FROM products ORDER BY random() LIMIT 1) AS product_id,
            (SELECT id FROM book_authors ORDER BY random() LIMIT 1) AS author_id,
            (SELECT id FROM genres ORDER BY random() LIMIT 1) AS genre_id,
            (SELECT id FROM publishers ORDER BY random() LIMIT 1) AS publisher_id,
            CASE WHEN random() < 0.5 THEN 'PAPER' ELSE 'EBOOK' END
        FROM generate_series(1, __SEED_COUNT__)
        $insert$);
        END IF;

        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'ebook_format') THEN
            EXECUTE format($insert$
        INSERT INTO ebook_format (id, format)
        SELECT
            gen_random_uuid() AS id,
            CASE WHEN random() < 0.5 THEN 'FB2' ELSE 'EPUB' END
        FROM generate_series(1, __SEED_COUNT__)
        ON CONFLICT(format) DO NOTHING
        $insert$);
        END IF;

        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'ebooks') THEN
            EXECUTE format($insert$
        INSERT INTO ebooks (id, book_id, format_id, file_url)
        SELECT
            gen_random_uuid() AS id,
            (SELECT id FROM book_info ORDER BY random() LIMIT 1) AS book_id,
            (SELECT id FROM ebook_format ORDER BY random() LIMIT 1) AS format_id,
            faker.uri() AS file_url
        FROM generate_series(1, __SEED_COUNT__)
        $insert$);
        END IF;

        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'ebook_libraries') THEN
            EXECUTE format($insert$
        INSERT INTO ebook_libraries (id, user_id, ebook_id)
        SELECT
            gen_random_uuid() AS id,
            (SELECT id FROM users ORDER BY random() LIMIT 1) AS user_id,
            (SELECT id FROM ebooks ORDER BY random() LIMIT 1) AS ebook_id
        FROM generate_series(1, __SEED_COUNT__)
        $insert$);
        END IF;

        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'reviews') THEN
            EXECUTE format($insert$
        INSERT INTO reviews (id, user_id, product_id, raiting, text)
        SELECT
            gen_random_uuid() AS id,
            (SELECT id FROM users ORDER BY random() LIMIT 1) AS user_id,
            (SELECT id FROM products ORDER BY random() LIMIT 1) AS product_id,
            floor(random() * 5 + 1)::int AS raiting,
            faker.text() AS text
        FROM generate_series(1, __SEED_COUNT__)
        $insert$);
        END IF;
    END
$$ LANGUAGE plpgsql;


DO $$
    BEGIN
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'wishlists') THEN
            EXECUTE format($insert$
        INSERT INTO wishlists (id, user_id, product_id)
        SELECT
            gen_random_uuid() AS id,
            (SELECT id FROM users ORDER BY random() LIMIT 1) AS user_id,
            (SELECT id FROM products ORDER BY random() LIMIT 1) AS product_id
        FROM generate_series(1, __SEED_COUNT__)
        $insert$);
        END IF;

        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'delivery') THEN
            EXECUTE format($insert$
        INSERT INTO delivery (id, address)
        SELECT
            gen_random_uuid() AS id,
            faker.address() AS address
        FROM generate_series(1, __SEED_COUNT__)
        $insert$);
        END IF;

        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'promocode') THEN
            EXECUTE format($insert$
        INSERT INTO promocode (id, code, discount_percent, start_date, end_date)
        SELECT
            gen_random_uuid() AS id,
            faker.word() AS code,
            floor(random() * 50)::int AS discount_percent,
            CURRENT_DATE + (random() * 30)::int AS start_date,
            CURRENT_DATE + (random() * 30)::int AS end_date
        FROM generate_series(1, __SEED_COUNT__)
        $insert$);
        END IF;
    END
$$ LANGUAGE plpgsql;

DO $$
    BEGIN
        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'cart_item') THEN
            EXECUTE format($insert$
        INSERT INTO cart_item (id, user_id, product_id, quantity)
        SELECT
            gen_random_uuid() AS id,
            (SELECT id FROM users ORDER BY random() LIMIT 1) AS user_id,
            (SELECT id FROM products ORDER BY random() LIMIT 1) AS product_id,
            round(random() * 100 + 1) AS quantity
        FROM generate_series(1, __SEED_COUNT__)
        $insert$);
        END IF;

        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'orders') THEN
            EXECUTE format($insert$
        INSERT INTO orders (id, user_id, delivery_id, promocode_id, total_price, status)
        SELECT
            gen_random_uuid() AS id,
            (SELECT id FROM users ORDER BY random() LIMIT 1) AS user_id,
            (SELECT id FROM delivery ORDER BY random() LIMIT 1) AS delivery_id,
            (SELECT id FROM promocode ORDER BY random() LIMIT 1) AS promocode_id,
            round(random() * 100 + 1) AS total_price,
            'PENDING' AS status
        FROM generate_series(1, __SEED_COUNT__)
        $insert$);
        END IF;

        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'order_item') THEN
            EXECUTE format($insert$
        INSERT INTO order_item (id, user_id, order_id, product_id, price)
        SELECT
            gen_random_uuid() AS id,
            (SELECT id FROM users ORDER BY random() LIMIT 1) AS user_id,
            (SELECT id FROM orders ORDER BY random() LIMIT 1) AS order_id,
            (SELECT id FROM products ORDER BY random() LIMIT 1) AS product_id,
            round(random() * 100 + 1) AS price
        FROM generate_series(1, __SEED_COUNT__)
        $insert$);
        END IF;

        IF EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'return_request') THEN
            EXECUTE format($insert$
        INSERT INTO return_request (id, user_id, order_id, product_id, return_reason, status)
        SELECT
            gen_random_uuid() AS id,
            (SELECT id FROM users ORDER BY random() LIMIT 1) AS user_id,
            (SELECT id FROM orders ORDER BY random() LIMIT 1) AS order_id,
            (SELECT id FROM products ORDER BY random() LIMIT 1) AS product_id,
            faker.word() AS return_reason,
            'REQUESTED' AS status
        FROM generate_series(1, __SEED_COUNT__)
        $insert$);
        END IF;
    END
$$ LANGUAGE plpgsql;
