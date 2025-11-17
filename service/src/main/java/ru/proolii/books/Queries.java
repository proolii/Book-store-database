package ru.proolii.books;

import java.sql.*;

public class Queries {
    public static String getRandomUserId(Connection c) throws SQLException {
        String sql = "SELECT id FROM users ORDER BY random() LIMIT 1";
        try (Statement stmt = c.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getString("id");
            }
        }
        throw new SQLException("No users found");
    }

    public void getUserEbooksList(Connection c, String userId) throws SQLException {
        String sql = """
            SELECT e.id AS ebook_id,
                   p.id AS product_id,
                   p.name AS title,
                   ef.format AS format,
                   e.file_url AS file_url
            FROM ebook_libraries el
            JOIN ebooks          e  ON e.id = el.ebook_id
            JOIN ebook_format    ef ON ef.id = e.format_id
            JOIN book_info       bi ON bi.id = e.book_id
            JOIN products        p  ON p.id = bi.product_id
            WHERE el.user_id = ?::uuid
            ORDER BY p.name
            """;
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setObject(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                System.out.println("== User ebooks ==");
                while (rs.next()) {
                    System.out.printf("ebook=%s product=%s title=%s format=%s url=%s%n",
                            rs.getString("ebook_id"),
                            rs.getString("product_id"),
                            rs.getString("title"),
                            rs.getString("format"),
                            rs.getString("file_url"));
                }
            }
        }
    }

    public void getTopGenres(Connection c) throws SQLException {
        String sql = """
        SELECT g.name AS genre, COUNT(*) AS sold_count, SUM(oi.price) AS revenue
        FROM order_item oi
        JOIN products p    ON p.id = oi.product_id
        JOIN book_info bi  ON bi.product_id = p.id
        JOIN genres g      ON g.id = bi.genre_id
        GROUP BY g.name
        ORDER BY sold_count DESC
        """;
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            try (ResultSet rs = ps.executeQuery()) {
                System.out.println("== Top genres ==");
                while (rs.next()) {
                    System.out.printf("genre=%s sold=%d revenue=%.2f%n",
                            rs.getString("genre"),
                            rs.getInt("sold_count"),
                            rs.getDouble("revenue"));
                }
            }
        }
    }

    public void getUserPreferences(Connection c, String userId) throws SQLException {
        String sql = """
            WITH liked AS (
               SELECT cgp.genre_id, NULL::uuid AS author_id, NULL::uuid AS publisher_id
                 FROM customer_genre_preferences cgp WHERE cgp.user_id = ?::uuid
               UNION ALL
               SELECT NULL, cap.author_id, NULL
                 FROM customer_author_preferences cap WHERE cap.user_id = ?::uuid
               UNION ALL
               SELECT NULL, NULL, cpp.publisher_id
                 FROM customer_publisher_preferences cpp WHERE cpp.user_id = ?::uuid
            )
            SELECT DISTINCT p.id, p.name, p.price
            FROM liked l
            JOIN book_info bi
              ON (l.genre_id     IS NULL OR bi.genre_id     = l.genre_id)
             AND (l.author_id    IS NULL OR bi.author_id    = l.author_id)
             AND (l.publisher_id IS NULL OR bi.publisher_id = l.publisher_id)
            JOIN products p ON p.id = bi.product_id
            ORDER BY p.price DESC
            """;
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setObject(1, userId);
            ps.setObject(2, userId);
            ps.setObject(3, userId);
            try (ResultSet rs = ps.executeQuery()) {
                System.out.println("== Recommendations ==");
                while (rs.next()) {
                    System.out.printf("product=%s name=%s price=%.2f%n",
                            rs.getString("id"),
                            rs.getString("name"),
                            rs.getDouble("price"));
                }
            }
        }
    }

    public void search(Connection c, String query) throws SQLException {
        String sql = """
        SELECT p.id,
               p.name,
               p.description,
               p.price,
               pc.name AS category,
               s.name  AS shop
        FROM products p
        JOIN product_categories pc ON pc.id = p.category_id
        JOIN shops s               ON s.id = p.shop_id
        WHERE p.name = ?
        ORDER BY p.price DESC, p.name
        """;
        try (PreparedStatement ps = c.prepareStatement(sql)) {
            ps.setString(1, query);

            try (ResultSet rs = ps.executeQuery()) {
                System.out.println("== Search results ==");
                while (rs.next()) {
                    System.out.printf("product=%s name=%s price=%.2f category=%s shop=%s%n",
                            rs.getString("id"),
                            rs.getString("name"),
                            rs.getDouble("price"),
                            rs.getString("category"),
                            rs.getString("shop"));
                }
            }
        }
    }
}