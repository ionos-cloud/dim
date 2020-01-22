DELETE FROM rrns;
DELETE FROM rr;

UPDATE schemainfo SET version=2;
COMMIT;
