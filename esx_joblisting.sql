USE `es_extended`;

ALTER TABLE jobs add whitelisted BOOLEAN NOT NULL DEFAULT FALSE;

ALTER TABLE `users`
	ADD `leo_rank` int(11) NULL DEFAULT '-1',
	ADD `ems_rank` int(11) NULL DEFAULT '-1',
	ADD `tow_rank` int(11) NULL DEFAULT '-1'
;