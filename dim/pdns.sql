CREATE TABLE domains (
  id                    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name                  VARCHAR(255) NOT NULL,
  master                VARCHAR(255) DEFAULT NULL,
  last_check            INT UNSIGNED DEFAULT NULL,
  type                  ENUM('MASTER','SLAVE','NATIVE') NOT NULL,
  notified_serial       INT UNSIGNED DEFAULT NULL,
  account               VARCHAR(40) DEFAULT NULL,
  PRIMARY KEY (id)
) Engine=InnoDB;

CREATE UNIQUE INDEX name_index ON domains(name);


CREATE TABLE records (
  id                    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  domain_id             BIGINT UNSIGNED NOT NULL,
  name                  VARCHAR(255) NOT NULL,
  type                  VARCHAR(10) DEFAULT NULL,
  content               VARCHAR(64000) DEFAULT NULL,
  ttl                   MEDIUMINT UNSIGNED DEFAULT NULL,
  prio                  SMALLINT UNSIGNED DEFAULT NULL,
  disabled              TINYINT(1) NOT NULL DEFAULT 0,
  ordername             VARCHAR(255) BINARY DEFAULT NULL,
  auth                  TINYINT(1) NOT NULL DEFAULT 1,
  rev_name              VARCHAR(255) DEFAULT NULL,
  PRIMARY KEY (id),
  CONSTRAINT `records_ibfk_1` FOREIGN KEY (`domain_id`) REFERENCES `domains` (`id`) ON DELETE CASCADE
) Engine=InnoDB CHARACTER SET ascii;

CREATE INDEX nametype_index ON records(name,type);
CREATE INDEX domain_id ON records(domain_id);
CREATE INDEX recordorder ON records (domain_id, ordername);
CREATE INDEX rev_name_domid ON records (domain_id, rev_name);
ALTER TABLE records ADD CONSTRAINT `records_domain_id_ibfk` FOREIGN KEY (`domain_id`) REFERENCES `domains` (`id`) ON DELETE CASCADE;

CREATE TABLE supermasters (
  ip                    VARCHAR(64) NOT NULL,
  nameserver            VARCHAR(255) NOT NULL,
  account               VARCHAR(40) NOT NULL,
  PRIMARY KEY (ip, nameserver)
) Engine=InnoDB;


CREATE TABLE comments (
  id                    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  domain_id             BIGINT UNSIGNED NOT NULL,
  name                  VARCHAR(255) NOT NULL,
  type                  VARCHAR(10) NOT NULL,
  modified_at           INT UNSIGNED NOT NULL,
  account               VARCHAR(40) NOT NULL,
  comment               TEXT NOT NULL,
  PRIMARY KEY (id)
) Engine=InnoDB;

CREATE INDEX comments_name_type_idx ON comments (name, type);
CREATE INDEX comments_order_idx ON comments (domain_id, modified_at);
ALTER TABLE comments ADD CONSTRAINT `comments_domain_id_ibfk` FOREIGN KEY (`domain_id`) REFERENCES `domains` (`id`) ON DELETE CASCADE;

CREATE TABLE domainmetadata (
  id                    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  domain_id             BIGINT UNSIGNED NOT NULL,
  kind                  VARCHAR(32) NOT NULL,
  content               TEXT,
  PRIMARY KEY (id)
) Engine=InnoDB;

CREATE INDEX domainmetadata_idx ON domainmetadata (domain_id, kind);
ALTER TABLE domainmetadata ADD CONSTRAINT `domainmetadata_domain_id_ibfk` FOREIGN KEY (`domain_id`) REFERENCES `domains` (`id`) ON DELETE CASCADE;

CREATE TABLE cryptokeys (
  id                    BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  domain_id             BIGINT UNSIGNED NOT NULL,
  flags                 INT NOT NULL,
  active                BOOL,
  published             BOOL DEFAULT 1,
  content               TEXT,
  PRIMARY KEY(id)
) Engine=InnoDB;

CREATE INDEX domainidindex ON cryptokeys(domain_id);
ALTER TABLE cryptokeys ADD CONSTRAINT `cryptokeys_domain_id_ibfk` FOREIGN KEY (`domain_id`) REFERENCES `domains` (`id`) ON DELETE CASCADE;

CREATE TABLE tsigkeys (
  id                    INT NOT NULL AUTO_INCREMENT,
  name                  VARCHAR(255),
  algorithm             VARCHAR(50),
  secret                VARCHAR(255),
  PRIMARY KEY (id)
) Engine=InnoDB;

CREATE UNIQUE INDEX namealgoindex ON tsigkeys(name, algorithm);
