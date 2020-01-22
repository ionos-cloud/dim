ALTER TABLE history_ipblock
      ADD KEY `ix_address_prefix_version` (`address`,`prefix`,`version`),
      ADD KEY `ix_history_ipblock_user` (`user`);

ALTER TABLE history_ippool
      ADD KEY `ix_name` (`name`),
      ADD KEY `ix_history_ippool_user` (`user`);

ALTER TABLE history_rr
      ADD KEY `ix_name` (`name`),
      ADD KEY `ix_history_rr_user` (`user`),
      ADD KEY `ix_history_rr_zone` (`zone`);

ALTER TABLE history_zone
      ADD KEY `ix_name` (`name`),
      ADD KEY `ix_history_zone_user` (`user`);

ALTER TABLE history_zonealias
      ADD KEY `ix_history_zonealias_user` (`user`),
      ADD KEY `ix_history_zonealias_zone` (`zone`);

ALTER TABLE history_zoneview
      ADD KEY `ix_history_zoneview_user` (`user`),
      ADD KEY `ix_history_zoneview_zone` (`zone`);

ALTER TABLE history_zonegroup
      ADD KEY `ix_name` (`name`),
      ADD KEY `ix_history_zonegroup_user` (`user`),
      ADD KEY `ix_history_zonegroup_zone` (`zone`);

ALTER TABLE history_usergroup
      ADD COLUMN attrname varchar(256) DEFAULT NULL,
      ADD COLUMN newvalue varchar(256) DEFAULT NULL,
      ADD COLUMN oldvalue varchar(256) DEFAULT NULL,
      ADD KEY `ix_name` (`name`),
      ADD KEY `ix_history_usergroup_user` (`user`);

ALTER TABLE history_groupright
      ADD KEY `ix_history_groupright_group` (`group`),
      ADD KEY `ix_history_groupright_user` (`user`);

ALTER TABLE history_output
      ADD KEY `ix_name` (`name`),
      ADD KEY `ix_history_output_user` (`user`);

UPDATE schemainfo SET version=5;
COMMIT;
