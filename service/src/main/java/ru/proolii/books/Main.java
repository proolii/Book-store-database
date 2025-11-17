package ru.proolii.books;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class Main {
    static final String DB_HOST = getenv("DB_HOST", "postgres");
    static final String DB_PORT = getenv("DB_PORT", "5432");
    static final String DB_NAME = getenv("POSTGRES_DB", "books_data");
    static final String DB_USER = getenv("POSTGRES_USER", "admin");
    static final String DB_PASS = getenv("POSTGRES_PASSWORD", "adminpassword");

    static String jdbcUrl() {
        return "jdbc:postgresql://" + DB_HOST + ":" + DB_PORT + "/" + DB_NAME;
    }

    static String getenv(String k, String def) {
        String v = System.getenv(k);
        return v == null || v.isBlank() ? def : v;
    }

    static Connection connect() throws SQLException {
        Properties props = new Properties();
        props.setProperty("user", DB_USER);
        props.setProperty("password", DB_PASS);
        props.setProperty("sslmode", "disable");
        props.setProperty("ApplicationName", "books-service");
        return DriverManager.getConnection(jdbcUrl(), props);
    }

    public static void main(String[] args) throws Exception {
        System.out.printf("Connecting to %s as %s%n", jdbcUrl(), DB_USER);
        try (Connection connection = connect()) {
            Queries queries = new Queries();

            queries.getUserEbooksList(connection, Queries.getRandomUserId(connection));
            queries.getTopGenres(connection);
            queries.getUserPreferences(connection, Queries.getRandomUserId(connection));
            queries.search(connection, "book");
        }
    }
}
