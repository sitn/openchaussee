﻿CREATE OR REPLACE FUNCTION chaussee_dev.calc_geom() RETURNS trigger AS $BODY$
BEGIN
  NEW.pvl_line_geom = ST_LineSubstring(
	(
	SELECT asg_geom FROM chaussee_dev.t_axissegments WHERE asg_iliid = NEW.pvl_asg_iliid 
	),
	(
	ST_LineLocatePoint( (SELECT asg_geom FROM chaussee_dev.t_axissegments WHERE asg_iliid = NEW.pvl_asg_iliid ), (SELECT sec_refpoint_geom FROM chaussee_dev.t_sectors WHERE sec_iliid = NEW.pvl_start_sec_iliid ) )
	+
	NEW.pvl_start_u/ST_Length( (SELECT asg_geom FROM chaussee_dev.t_axissegments WHERE asg_iliid = NEW.pvl_asg_iliid ) )
	),
	(
	ST_LineLocatePoint( (SELECT asg_geom FROM chaussee_dev.t_axissegments WHERE asg_iliid = NEW.pvl_asg_iliid ), (SELECT sec_refpoint_geom FROM chaussee_dev.t_sectors WHERE sec_iliid = NEW.pvl_end_sec_iliid ) )
	+
	NEW.pvl_end_u/ST_Length( (SELECT asg_geom FROM chaussee_dev.t_axissegments WHERE asg_iliid = NEW.pvl_asg_iliid ) )
	)
  );
  RETURN NEW;
END; $BODY$
LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS calc_geom_before_insert ON chaussee_dev.t_pavement_layers;

CREATE TRIGGER calc_geom_before_insert
  BEFORE INSERT
  ON chaussee_dev.t_pavement_layers
  FOR EACH ROW
  EXECUTE PROCEDURE chaussee_dev.calc_geom();

DROP TRIGGER IF EXISTS calc_geom_before_update ON chaussee_dev.t_pavement_layers;

CREATE TRIGGER calc_geom_before_update
  BEFORE UPDATE
  ON chaussee_dev.t_pavement_layers
  FOR EACH ROW
  EXECUTE PROCEDURE chaussee_dev.calc_geom();
  
