package dim;

import org.jooq.DSLContext;

class LockTimeout extends Exception {
    public LockTimeout(String msg) {
        super(msg);
    }
}

public class DatabaseNamedLock implements AutoCloseable {
    private final DSLContext sql;
    private final String name;

    DatabaseNamedLock(DSLContext sql, String name, double timeout) throws LockTimeout {
        this.sql = sql;
        this.name = name;
        if (sql.fetchOne("SELECT GET_LOCK(?, ?)", name, timeout).get(0, int.class) == 0)
            throw new LockTimeout("Lock timeout for " + name);
    }

    @Override
    public void close() {
        sql.execute("SELECT RELEASE_LOCK(?)", name);
    }
}
