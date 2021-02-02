package dim;

import org.xbill.DNS.Name;
import org.xbill.DNS.Record;

import java.util.List;

import static dim.ExcludeType.NONE;

class Row {
    Integer id;
    // the NULL record type is used for empty non-terminals
    Record record;
    // ordername is null for:
    // - RRSIG
    // - any delegated records except NS
    // - non-apex NS if NSEC3 Opt-out=1
    String ordername;
    // 1 for RRSIG, all records that are not delegated
    boolean auth;

    Row(Record r) {
        record = r;
        auth = true;
    }

    Row(Record r, String ordername, boolean auth) {
        this.record = r;
        this.ordername = ordername;
        this.auth = auth;
    }

    Row(Record r, String ordername, boolean auth, Integer id) {
        this.record = r;
        this.ordername = ordername;
        this.auth = auth;
        this.id = id;
    }
}

enum ExcludeType {NONE, EMPTY_NON_TERMINAL, GENERATED}

public interface Storage {
    /**
     * INSERT INTO domains (name, type) VALUES (?, 'NATIVE')
     */
    boolean createDomain(Name domain);

    void deleteDomain(Name domain);

    void updateSerial(Name domain, long serial);

    void updateSOA(Name domain, long ttl, String rdata);

    /**
     * SELECT * FROM records where domain_id = ? AND name = ? (AND type = ?)
     * If type == 0, get all rrs with that name
     */
    List<Row> getRRSet(Name domain, Name name, int type);

    default List<Row> getRRSet(Name domain, Name name) {
        return getRRSet(domain, name, 0);
    }

    /**
     * SELECT COUNT(*) FROM records where domain_id = ? AND name = ? (AND type = ?)
     */
    boolean rrsetExists(Name domain, Name name, int type);

    default boolean rrsetExists(Name domain, Name name) {
        return rrsetExists(domain, name, 0);
    }

    /**
     * (This should drop NSECx inserts since pdns doesn't need them)
     * INSERT INTO records VALUES ?
     */
    void addRow(Name domain, Row row);

    /**
     * Insert rows in bulk. Assume that there are no rows present for domain.
     */
    void addRows(Name domain, List<Row> rows);

    /**
     * DELETE FROM records WHERE id = ?
     */
    int deleteRowById(Name domain, Integer id);

    /**
     * DELETE FROM records WHERE domain = ? AND name = ? AND type = ? AND content = ?
     */
    int deleteRecord(Name domain, Record record);

    /**
     * DELETE FROM records WHERE domain = ? AND name = ? AND type = ?
     */
    int deleteRRSet(Name domain, Name name, int type);

    /**
     * select name from records where domain_id=? and ordername > ? order by ordername asc limit 1
     * if no results
     * select name from records where domain_id=? and ordername is not null order by ordername asc limit 1
     */
    Name getNextName(Name domain, String ordername);

    /**
     * select name from records where domain_id = ? and ordername < ? order by 1 desc limit 1
     * if no results
     * select name from records where domain_id = ? and ordername is not null order by 1 desc limit 1
     */
    Name getPrevName(Name domain, String ordername);

    /**
     * Empty implementation for SQL
     */
    void addOrReplaceNSEC(Name domain, Record nsec);

    /**
     * SELECT * FROM records WHERE domain = ? AND name = ? OR name like '%.?'
     */
    List<Row> getSubzoneRecords(Name domain, Name name, ExcludeType exclude);

    default List<Row> getSubzoneRecords(Name domain, Name name) {
        return getSubzoneRecords(domain, name, NONE);
    }

    /**
     * UPDATE records SET auth = 0, ordername = NULL WHERE domain = ? AND (name = ? OR name like '%.?') AND type != 'NS'
     */
    void removeAuthAndOrdernameForSubzone(Name domain, Name name);

    /**
     * UPDATE records SET auth = ?, ordername = ? WHERE domain = ? AND name = ? AND type NOT IN ('RRSIG', 'NSEC',
     * 'NSEC3')
     */
    void updateAuthAndOrdernameForName(Name domain, Name name, String ordername, boolean auth);

    /**
     * SELECT COUNT(*) FROM records WHERE domain = ? AND name like '%.?' AND ordername IS NOT NULL
     */
    int subzoneHasOrdernames(Name domain, Name name);

    void setNSECParameters(Name domain, NSECParameters np);

    void setSignParameters(Name domain, String parameters);
    String getSignParameters(Name domain);

    NSECParameters getNSECParameters(Name domain);

    void deleteRecords(Name domain);

    boolean isSigned(Name domain);

    void setSignStatus(Name domain, boolean status);

    void deleteDNSSECRecords(Name domain);
}

