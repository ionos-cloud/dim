RENAME TABLE person TO user;
ALTER TABLE user
      DROP COLUMN info,
      DROP COLUMN fax,
      DROP COLUMN office,
      DROP COLUMN emailpager,
      DROP COLUMN cell,
      DROP COLUMN extension,
      DROP COLUMN position,
      DROP COLUMN home,
      DROP COLUMN password,
      DROP COLUMN pager,
      DROP COLUMN email,
      DROP COLUMN firstname,
      DROP COLUMN lastname,
      DROP COLUMN aliases,
      DROP FOREIGN KEY fk_entity_3,
      DROP INDEX fk_entity_3,
      DROP COLUMN entity,
      DROP FOREIGN KEY fk_room_3,
      DROP INDEX room,
      DROP COLUMN room,
      DROP FOREIGN KEY fk_location,
      DROP INDEX location,
      DROP COLUMN location,
      DROP KEY person1,
      DROP KEY person2, ADD UNIQUE KEY `username` (`username`),
      CHANGE user_type user_type_id bigint(20) DEFAULT NULL,
      DROP KEY user_type, ADD KEY user_type_id (user_type_id),
      DROP FOREIGN KEY fk_user_type, ADD CONSTRAINT `user_ibfk_1` FOREIGN KEY (user_type_id) REFERENCES `usertype` (`id`);

RENAME TABLE contactlist TO usergroup;
ALTER TABLE usergroup
      DROP COLUMN info,
      ADD COLUMN created timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
      ADD COLUMN created_by varchar(128) DEFAULT NULL,
      ADD COLUMN modified timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
      ADD COLUMN modified_by varchar(128) DEFAULT NULL,
      DROP KEY contactlist1,
      ADD UNIQUE KEY `name`(`name`);

RENAME TABLE contact TO usergroupuser;
ALTER TABLE usergroupuser
      DROP PRIMARY KEY,
      DROP COLUMN id,

      DROP COLUMN escalation_level,
      DROP COLUMN info,

      DROP FOREIGN KEY fk_notify_voice,
      DROP INDEX notify_voice,
      DROP COLUMN notify_voice,

      DROP FOREIGN KEY fk_notify_email,
      DROP INDEX notify_email,
      DROP COLUMN notify_email,

      DROP FOREIGN KEY fk_notify_pager,
      DROP INDEX notify_pager,
      DROP COLUMN notify_pager,

      DROP FOREIGN KEY fk_contacttype,
      DROP COLUMN contacttype,

      DROP FOREIGN KEY fk_contactlist,
      DROP FOREIGN KEY fk_person,
      CHANGE contactlist usergroup_id bigint(20) DEFAULT NULL,
      CHANGE person user_id bigint(20) DEFAULT NULL,
      DROP KEY person, ADD KEY user_id (user_id),
      DROP KEY `Contact1`, ADD KEY usergroup_id (usergroup_id),
      ADD CONSTRAINT `usergroupuser_ibfk_1` FOREIGN KEY (`usergroup_id`) REFERENCES `usergroup` (`id`),
      ADD CONSTRAINT `usergroupuser_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`);

ALTER TABLE groupright
      CHANGE accessright `accessright_id` bigint(20) DEFAULT NULL,
      CHANGE contactlist `usergroup_id` bigint(20) DEFAULT NULL,
      DROP FOREIGN KEY fk_accessright, ADD CONSTRAINT `groupright_ibfk_1` FOREIGN KEY (`accessright_id`) REFERENCES `accessright` (`id`),
      DROP FOREIGN KEY fk_contactlist_3, ADD CONSTRAINT `groupright_ibfk_2` FOREIGN KEY (`usergroup_id`) REFERENCES `usergroup` (`id`),
      DROP KEY `GroupRight2`, ADD KEY accessright_id(accessright_id),
      DROP KEY groupright1, ADD UNIQUE KEY usergroup_id(usergroup_id, accessright_id);

ALTER TABLE allocationhistory
      CHANGE ippool ippool_id bigint(20) NOT NULL,
      DROP FOREIGN KEY fk_ippool, ADD CONSTRAINT allocationhistory_ibfk_1 FOREIGN KEY (ippool_id) REFERENCES ippool(id),
      DROP KEY ippool, ADD KEY ippool_id (ippool_id);

ALTER TABLE accessright
      ADD UNIQUE KEY access(access, object_class, object_id),
      CHANGE object_id object_id BIGINT(20) NOT NULL;

ALTER TABLE ipblock DROP FOREIGN KEY fk_interface_3,
                    DROP INDEX Ipblock6,
                    DROP COLUMN interface;
ALTER TABLE ipblock DROP FOREIGN KEY fk_owner_2,
                    DROP INDEX owner,
                    DROP COLUMN owner;
ALTER TABLE ipblock DROP FOREIGN KEY fk_used_by_1,
                    DROP INDEX used_by,
                    DROP COLUMN used_by;
ALTER TABLE ipblock DROP COLUMN info;
ALTER TABLE ipblock DROP COLUMN description;
ALTER TABLE ipblock
      DROP KEY `Ipblock4`,
      DROP KEY `Ipblock5`,
      ADD COLUMN created_by varchar(128) DEFAULT NULL,
      CHANGE parent parent_id bigint(20) DEFAULT NULL,
      CHANGE ippool ippool_id bigint(20) DEFAULT NULL,
      CHANGE vlan vlan_id bigint(20) DEFAULT NULL,
      CHANGE status status_id bigint(20) DEFAULT NULL,
      CHANGE first_seen created timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
      CHANGE last_seen modified timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
      DROP FOREIGN KEY fk_parent, ADD CONSTRAINT `ipblock_ibfk_1` FOREIGN KEY (`parent_id`) REFERENCES `ipblock` (`id`),
      DROP FOREIGN KEY fk_status_2, ADD CONSTRAINT `ipblock_ibfk_2` FOREIGN KEY (`status_id`) REFERENCES `ipblockstatus` (`id`),
      DROP FOREIGN KEY fk_ippool_1, ADD CONSTRAINT `ipblock_ibfk_3` FOREIGN KEY (`ippool_id`) REFERENCES `ippool` (`id`),
      DROP FOREIGN KEY fk_vlan_1, ADD CONSTRAINT `ipblock_ibfk_4` FOREIGN KEY (`vlan_id`) REFERENCES `vlan` (`id`),
      DROP KEY `Ipblock1`, ADD UNIQUE KEY address(address, `prefix`),
      DROP KEY `ippool`, ADD KEY `ippool_id` (`ippool_id`),
      DROP KEY `Ipblock2`, ADD KEY `parent_id` (`parent_id`),
      DROP KEY `Ipblock3`, ADD KEY `status_id` (`status_id`),
      DROP KEY `Ipblock7`, ADD KEY `vlan_id` (`vlan_id`),
      DROP KEY `Ipblock8`, ADD KEY `ix_ipblock_version` (`version`);


ALTER TABLE ipblockattr CHANGE name name BIGINT(20) NOT NULL;
ALTER TABLE ipblockattr CHANGE ipblock ipblock BIGINT(20) NOT NULL;
ALTER TABLE ipblockattr
      DROP KEY ipblockattr1, ADD UNIQUE KEY `name` (`name`,`ipblock`),
      DROP KEY `IpblockAttr2`, ADD KEY `ipblock` (`ipblock`),
      DROP FOREIGN KEY fk_ipblock_1, ADD CONSTRAINT `ipblockattr_ibfk_1` FOREIGN KEY (`ipblock`) REFERENCES `ipblock` (`id`),
      DROP FOREIGN KEY fk_name_3, ADD CONSTRAINT `ipblockattr_ibfk_2` FOREIGN KEY (`name`) REFERENCES `ipblockattrname` (`id`);

ALTER TABLE ipblockattrname
      DROP COLUMN info,
      DROP KEY ipblockattrname1, ADD UNIQUE KEY `name` (`name`);

ALTER TABLE ipblockstatus
      DROP KEY ipblockstatus1, ADD UNIQUE KEY `name` (`name`);

ALTER TABLE ippool
      CHANGE vlan vlan_id bigint(20) DEFAULT NULL,
      DROP KEY `Ippool2`, ADD KEY `vlan_id` (`vlan_id`),
      DROP KEY `Ippool3`, ADD KEY `ix_ippool_version` (`version`),
      DROP KEY ippool1, ADD UNIQUE KEY `name` (`name`),
      DROP FOREIGN KEY fk_vlan_2, ADD CONSTRAINT `ippool_ibfk_1` FOREIGN KEY (`vlan_id`) REFERENCES `vlan` (`id`);

ALTER TABLE ippoolattr
      CHANGE ippool ippool_id BIGINT(20) NOT NULL,
      CHANGE name name BIGINT(20) NOT NULL,
      DROP FOREIGN KEY fk_ippool_2, ADD CONSTRAINT `ippoolattr_ibfk_1` FOREIGN KEY (`ippool_id`) REFERENCES `ippool` (`id`),
      DROP FOREIGN KEY fk_name_4, ADD CONSTRAINT `ippoolattr_ibfk_2` FOREIGN KEY (`name`) REFERENCES `ippoolattrname` (`id`),
      DROP KEY `IppoolAttr2`, ADD KEY `ippool_id` (`ippool_id`),
      DROP KEY ippoolattr1, ADD UNIQUE KEY `name` (`name`, `ippool_id`);

ALTER TABLE ippoolattrname
      DROP COLUMN info,
      DROP KEY ippoolattrname1, ADD UNIQUE KEY `name` (`name`);

ALTER TABLE schemainfo
      DROP KEY `schemainfo1`,
      ADD UNIQUE KEY `version`(`version`);

ALTER TABLE usertype
      DROP COLUMN info,
      DROP KEY usertype1, ADD UNIQUE KEY `name` (`name`);

ALTER TABLE vlan DROP COLUMN info;
ALTER TABLE vlan DROP COLUMN description;
ALTER TABLE vlan DROP COLUMN `name`;
ALTER TABLE vlan DROP FOREIGN KEY fk_vlangroup,
                 DROP INDEX Vlan2,
                 DROP COLUMN vlangroup;
ALTER TABLE vlan
      DROP KEY vlan1, ADD UNIQUE KEY `vid` (`vid`);

DROP TABLE splice;
DROP TABLE arpcacheentry;
DROP TABLE cablestrand_history;
DROP TABLE interface_history;
DROP TABLE fwtableentry;
DROP TABLE interfacevlan;
DROP TABLE cablestrand;
DROP TABLE interface;
DROP TABLE backbonecable_history;
DROP TABLE dhcpscopeuse;
DROP TABLE bgppeering;
DROP TABLE deviceattr;
DROP TABLE arpcache;
DROP TABLE closetpicture;
DROP TABLE dhcpattr;
DROP TABLE devicemodule;
DROP TABLE devicecontacts;
DROP TABLE stpinstance;
DROP TABLE backbonecable;
DROP TABLE fwtable;
DROP TABLE device_history;
DROP TABLE horizontalcable;
DROP TABLE circuit_history;
DROP TABLE rraddr;
DROP TABLE rrptr;
DROP TABLE sitesubnet;
DROP TABLE closet;
DROP TABLE dhcpscope;
DROP TABLE person_history;
DROP TABLE ipservice;
DROP TABLE subnetzone;
DROP TABLE device;
DROP TABLE room;
DROP TABLE product_history;
DROP TABLE sitelink_history;
DROP TABLE circuit;
DROP TABLE asset;
DROP TABLE floorpicture;
DROP TABLE sitepicture;
DROP TABLE entityrole;
DROP TABLE rrns;
DROP TABLE entity_history;
DROP TABLE rrds;
DROP TABLE site_history;
DROP TABLE rrloc;
DROP TABLE rrhinfo;
DROP TABLE rrsrv;
DROP TABLE product;
DROP TABLE rrmx;
DROP TABLE rrcname;
DROP TABLE entitysite;
DROP TABLE floor;
DROP TABLE rrnaptr;
DROP TABLE rrtxt;
DROP TABLE userright;
DROP TABLE sitelink;
DROP TABLE maintcontract;
DROP TABLE site;
DROP TABLE entity;
DROP TABLE rr;
DROP TABLE vlangroup_history;
DROP TABLE physaddrattr;
DROP TABLE physaddr;
DROP TABLE cabletype;
DROP TABLE datacache;
DROP TABLE dhcpattrname;
DROP TABLE fibertype;
DROP TABLE producttype;
DROP TABLE savedqueries;
DROP TABLE entitytype;
DROP TABLE hostaudit;
DROP TABLE circuitstatus;
DROP TABLE availability;
DROP TABLE oui;
DROP TABLE physaddrattrname;
DROP TABLE contacttype;
DROP TABLE monitorstatus;
DROP TABLE strandstatus;
DROP TABLE dhcpscopetype;
DROP TABLE circuittype;
DROP TABLE service;
DROP TABLE deviceattrname;
DROP TABLE vlangroup;
DROP TABLE zonealias;

CREATE TABLE `zoneview` (
  `created` timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
  `created_by` varchar(128) DEFAULT NULL,
  `modified` timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
  `modified_by` varchar(128) DEFAULT NULL,
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `zone_id` bigint(20) NOT NULL,
  `ttl` int(11) NOT NULL,
  `primary` varchar(255) NOT NULL,
  `mail` varchar(255) NOT NULL,
  `serial` bigint(20) NOT NULL,
  `refresh` int(11) NOT NULL,
  `retry` int(11) NOT NULL,
  `expire` int(11) NOT NULL,
  `minimum` bigint(20) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`,`zone_id`),
  KEY `zone_id` (`zone_id`),
  CONSTRAINT `zoneview_ibfk_1` FOREIGN KEY (`zone_id`) REFERENCES `zone` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `rr` (
  `created` timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
  `created_by` varchar(128) DEFAULT NULL,
  `modified` timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
  `modified_by` varchar(128) DEFAULT NULL,
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `type` varchar(10) NOT NULL,
  `ttl` int(11) DEFAULT NULL,
  `zoneview_id` bigint(20) NOT NULL,
  `name` varchar(254) NOT NULL,
  `comment` varchar(255) DEFAULT NULL,
  `value` mediumtext NOT NULL,
  `target` varchar(255) DEFAULT NULL,
  `ipblock_id` bigint(20) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `zoneview_id` (`zoneview_id`),
  KEY `ipblock_id` (`ipblock_id`),
  KEY `ix_rr_name` (`name`),
  KEY `ix_rr_type` (`type`),
  KEY `ix_rr_target` (`target`),
  CONSTRAINT `rr_ibfk_1` FOREIGN KEY (`zoneview_id`) REFERENCES `zoneview` (`id`),
  CONSTRAINT `rr_ibfk_2` FOREIGN KEY (`ipblock_id`) REFERENCES `ipblock` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `zonealias` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `zone_id` bigint(20) DEFAULT NULL,
  `created` timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
  `created_by` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`),
  KEY `zone_id` (`zone_id`),
  CONSTRAINT `zonealias_ibfk_1` FOREIGN KEY (`zone_id`) REFERENCES `zone` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `zoneattrname` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `zoneattr` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `zone` bigint(20) NOT NULL,
  `name` bigint(20) NOT NULL,
  `value` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`,`zone`),
  KEY `zone` (`zone`),
  CONSTRAINT `zoneattr_ibfk_1` FOREIGN KEY (`zone`) REFERENCES `zone` (`id`),
  CONSTRAINT `zoneattr_ibfk_2` FOREIGN KEY (`name`) REFERENCES `zoneattrname` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `zonegroup` (
  `created` timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
  `created_by` varchar(128) DEFAULT NULL,
  `modified` timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
  `modified_by` varchar(128) DEFAULT NULL,
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `comment` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `zonegroupzoneview` (
  `zonegroup_id` bigint(20) DEFAULT NULL,
  `zoneview_id` bigint(20) DEFAULT NULL,
  KEY `zonegroup_id` (`zonegroup_id`),
  KEY `zoneview_id` (`zoneview_id`),
  CONSTRAINT `zonegroupzoneview_ibfk_1` FOREIGN KEY (`zonegroup_id`) REFERENCES `zonegroup` (`id`),
  CONSTRAINT `zonegroupzoneview_ibfk_2` FOREIGN KEY (`zoneview_id`) REFERENCES `zoneview` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `output` (
  `created` timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
  `created_by` varchar(128) DEFAULT NULL,
  `modified` timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
  `modified_by` varchar(128) DEFAULT NULL,
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `plugin` varchar(20) NOT NULL,
  `comment` varchar(255) DEFAULT NULL,
  `db_uri` varchar(255) DEFAULT NULL,
  `last_run` timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
  `status` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `outputupdate` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `transaction` varchar(16) DEFAULT NULL,
  `action` varchar(15) NOT NULL,
  `output_id` bigint(20) NOT NULL,
  `zone_name` varchar(255) NOT NULL,
  `serial` bigint(20) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `ttl` int(11) DEFAULT NULL,
  `type` varchar(10) DEFAULT NULL,
  `content` mediumtext,
  PRIMARY KEY (`id`),
  KEY `output_id` (`output_id`),
  CONSTRAINT `outputupdate_ibfk_1` FOREIGN KEY (`output_id`) REFERENCES `output` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `outputzonegroup` (
  `output_id` bigint(20) DEFAULT NULL,
  `zonegroup_id` bigint(20) DEFAULT NULL,
  KEY `output_id` (`output_id`),
  KEY `zonegroup_id` (`zonegroup_id`),
  CONSTRAINT `outputzonegroup_ibfk_1` FOREIGN KEY (`output_id`) REFERENCES `output` (`id`),
  CONSTRAINT `outputzonegroup_ibfk_2` FOREIGN KEY (`zonegroup_id`) REFERENCES `zonegroup` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `history_groupright` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `timestamp` timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
  `user` varchar(128) NOT NULL,
  `action` varchar(32) NOT NULL,
  `group` varchar(255) DEFAULT NULL,
  `right` varchar(255) DEFAULT NULL,
  `object` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_history_groupright_timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `history_ipblock` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `timestamp` timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
  `user` varchar(128) NOT NULL,
  `action` varchar(32) NOT NULL,
  `version` int(11) DEFAULT NULL,
  `address` decimal(40,0) DEFAULT NULL,
  `prefix` int(11) DEFAULT NULL,
  `priority` int(11) DEFAULT NULL,
  `gateway` decimal(40,0) DEFAULT NULL,
  `status` varchar(64) DEFAULT NULL,
  `pool` varchar(128) DEFAULT NULL,
  `vlan` int(11) DEFAULT NULL,
  `attrname` varchar(256) DEFAULT NULL,
  `newvalue` varchar(256) DEFAULT NULL,
  `oldvalue` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_history_ipblock_timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `history_ippool` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `timestamp` timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
  `user` varchar(128) NOT NULL,
  `action` varchar(32) NOT NULL,
  `name` varchar(128) DEFAULT NULL,
  `version` int(11) DEFAULT NULL,
  `description` varchar(128) DEFAULT NULL,
  `vlan` int(11) DEFAULT NULL,
  `address` decimal(40,0) DEFAULT NULL,
  `prefix` int(11) DEFAULT NULL,
  `attrname` varchar(256) DEFAULT NULL,
  `newvalue` varchar(256) DEFAULT NULL,
  `oldvalue` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_history_ippool_timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `history_output` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `timestamp` timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
  `user` varchar(128) NOT NULL,
  `action` varchar(32) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `plugin` varchar(20) DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL,
  `db_uri` varchar(255) DEFAULT NULL,
  `last_run` timestamp NULL DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `zonegroup` varchar(255) DEFAULT NULL,
  `attrname` varchar(256) DEFAULT NULL,
  `newvalue` varchar(256) DEFAULT NULL,
  `oldvalue` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_history_output_timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `history_rr` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `timestamp` timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
  `user` varchar(128) NOT NULL,
  `action` varchar(32) NOT NULL,
  `type` varchar(10) DEFAULT NULL,
  `name` varchar(254) DEFAULT NULL,
  `ttl` int(11) DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL,
  `value` mediumtext,
  `target` varchar(255) DEFAULT NULL,
  `zone` varchar(255) DEFAULT NULL,
  `view` varchar(255) DEFAULT NULL,
  `attrname` varchar(256) DEFAULT NULL,
  `newvalue` varchar(256) DEFAULT NULL,
  `oldvalue` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_history_rr_timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `history_usergroup` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `timestamp` timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
  `user` varchar(128) NOT NULL,
  `action` varchar(32) NOT NULL,
  `name` varchar(64) DEFAULT NULL,
  `username` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_history_usergroup_timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `history_zone` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `timestamp` timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
  `user` varchar(128) NOT NULL,
  `action` varchar(32) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `profile` tinyint(1) DEFAULT NULL,
  `attrname` varchar(256) DEFAULT NULL,
  `newvalue` varchar(256) DEFAULT NULL,
  `oldvalue` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_history_zone_timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `history_zonealias` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `timestamp` timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
  `user` varchar(128) NOT NULL,
  `action` varchar(32) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `zone` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_history_zonealias_timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `history_zonegroup` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `timestamp` timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
  `user` varchar(128) NOT NULL,
  `action` varchar(32) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `comment` varchar(255) DEFAULT NULL,
  `zone` varchar(255) DEFAULT NULL,
  `view` varchar(255) DEFAULT NULL,
  `attrname` varchar(256) DEFAULT NULL,
  `newvalue` varchar(256) DEFAULT NULL,
  `oldvalue` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_history_zonegroup_timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

CREATE TABLE `history_zoneview` (
  `id` bigint(20) NOT NULL AUTO_INCREMENT,
  `timestamp` timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
  `user` varchar(128) NOT NULL,
  `action` varchar(32) NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `ttl` int(11) DEFAULT NULL,
  `primary` varchar(255) DEFAULT NULL,
  `mail` varchar(255) DEFAULT NULL,
  `serial` bigint(20) DEFAULT NULL,
  `refresh` int(11) DEFAULT NULL,
  `retry` int(11) DEFAULT NULL,
  `expire` int(11) DEFAULT NULL,
  `minimum` bigint(20) DEFAULT NULL,
  `zone` varchar(255) DEFAULT NULL,
  `attrname` varchar(256) DEFAULT NULL,
  `newvalue` varchar(256) DEFAULT NULL,
  `oldvalue` varchar(256) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ix_history_zoneview_timestamp` (`timestamp`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;


-- Split zone table into zone + zoneview

INSERT INTO zoneview(name, zone_id, ttl, `primary`, mail, serial, refresh, retry, expire, minimum)
       SELECT 'default', id, default_ttl, concat(mname, '.'), concat(rname, '.'), serial, refresh, retry, expire, minimum
       FROM zone;

ALTER TABLE zone
      DROP COLUMN active,
      DROP COLUMN info,
      DROP COLUMN include,
      DROP COLUMN export_file,
      DROP COLUMN default_ttl,
      DROP COLUMN mname,
      DROP COLUMN rname,
      DROP COLUMN serial,
      DROP COLUMN refresh,
      DROP COLUMN retry,
      DROP COLUMN expire,
      DROP COLUMN minimum,
      DROP FOREIGN KEY fk_contactlist_8,
      DROP INDEX contactlist,
      DROP COLUMN contactlist,

      CHANGE name name varchar(255) NOT NULL,
      DROP KEY zone1, ADD UNIQUE KEY name(name),
      ADD COLUMN profile BOOL NOT NULL, ADD CHECK (profile IN (0, 1)),
      ADD COLUMN created timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
      ADD COLUMN created_by varchar(128) DEFAULT NULL,
      ADD COLUMN modified timestamp NOT NULL DEFAULT '1970-01-02 00:00:01',
      ADD COLUMN modified_by varchar(128) DEFAULT NULL;

-- Create all_users group

INSERT INTO usergroup (name) VALUES ('all_users');
INSERT INTO usergroupuser (usergroup_id, user_id)
       SELECT usergroup.id, user.id
       FROM usergroup, user
       WHERE usergroup.name='all_users';

UPDATE schemainfo SET version=4;
COMMIT;
