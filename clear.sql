BEGIN
   FOR cur_rec IN (SELECT object_name, object_type 
                   FROM user_objects 
                   WHERE object_type IN ('TABLE','TYPE','FUNCTION'))
   LOOP
      BEGIN
         IF cur_rec.object_type = 'TABLE' THEN
            EXECUTE IMMEDIATE 'DROP TABLE "' || cur_rec.object_name || '" CASCADE CONSTRAINTS';
         ELSIF cur_rec.object_type = 'TYPE' THEN
            EXECUTE IMMEDIATE 'DROP TYPE "' || cur_rec.object_name || '" FORCE';
         ELSIF cur_rec.object_type = 'FUNCTION' THEN
            EXECUTE IMMEDIATE 'DROP FUNCTION "' || cur_rec.object_name || '"';
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Failed to drop ' || cur_rec.object_type || ' ' || 
                               cur_rec.object_name || '. Error: ' || SQLERRM);
      END;
   END LOOP;
END;
/