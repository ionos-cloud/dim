package dim;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.jooq.DSLContext;
import org.jooq.SQLDialect;
import org.jooq.impl.DSL;
import org.junit.rules.ExternalResource;

import java.sql.Connection;
import java.sql.SQLException;

public class PdnsConnection extends ExternalResource {
    private static HikariDataSource dataSource = new HikariDataSource(new HikariConfig("/hikari.properties"));
    Connection conn;
    DSLContext sql;

    @Override
    protected void before() throws SQLException {
        conn = dataSource.getConnection();
        sql = DSL.using(conn, SQLDialect.MYSQL);
        sql.execute("DELETE FROM records");
        sql.execute("DELETE FROM domains");
        sql.execute("DELETE FROM domainmetadata");
    }

    @Override
    protected void after() {
        try {
            conn.commit();
            conn.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
