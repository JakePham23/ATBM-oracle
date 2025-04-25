
-- CONNECT system/123456@FREEPDB1;
-- ALTER SESSION SET CONTAINER = QLDULIEU;
GRANT CREATE USER, ALTER USER, DROP USER TO ADMIN;
GRANT UNLIMITED TABLESPACE TO ADMIN;
CONNECT admin/123456@localhost:1521/QLNHANVIEN;

SELECT tablespace_name FROM dba_tablespaces;
CREATE TABLESPACE USERS
  DATAFILE '/opt/oracle/oradata/QLNHANVIEN/users.dbf'
  SIZE 100M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

SET SERVEROUTPUT ON;
DECLARE
  v_status VARCHAR2(400);  
BEGIN
  PROC_CREATE_USER(
    p_username     => 'DEMO_USER_13',
    p_password     => '123456',
    p_tablespace   => 'USERS',
    p_profile      => 'DEFAULT',
    p_quota        => 'UNLIMITED',
    p_default_role => '',
    p_grant_sysdba => FALSE,
    p_status       => v_status  
  );

  DBMS_OUTPUT.PUT_LINE(v_status);
END;
/




SELECT * FROM DBA_ERRORS WHERE NAME = 'PROC_CREATE_USER' AND TYPE = 'PROCEDURE';
ALTER PROCEDURE PROC_CREATE_USER COMPILE;
GRANT EXECUTE ON PROC_CREATE_USER TO admin;
SHOW ERRORS PROCEDURE PROC_CREATE_USER;




BEGIN
  PROC_CREATE_ROLE('GV');
END;

BEGIN
  PROC_CREATE_ROLE('NVCB');
END;
BEGIN
  PROC_CREATE_ROLE('TEMPLATE');
END;

-- BEGIN
--   PROC_GRANT_ROLE_TO_USER(
--     p_role_name => 'GV',
--     p_username  => 'gv001'
--   );
-- END;

-- BEGIN
--   PROC_GRANT_PRIVILEGE(
--     p_privs  => 'SELECT,INSERT,UPDATE',
--     p_table  => 'SINHVIEN',
--     p_target => 'GV'
--   );
-- END;

-- BEGIN
--   PROC_GRANT_PRIVILEGE(
--     p_privs  => 'SELECT',
--     p_table  => 'DANGKY',
--     p_target => 'nv001'
--   );
-- END;

-- BEGIN
--   PROC_REVOKE(
--     p_type   => 'PRIV',
--     p_what   => 'SELECT',
--     p_table  => 'DANGKY',
--     p_target => 'nv001'
--   );
-- END;

-- BEGIN
--   PROC_REVOKE(
--     p_type   => 'ROLE',
--     p_what   => 'GV',
--     p_target => 'gv001'
--   );
-- END;

-- CONNECT admin/123456@QLDULIEU;
SELECT username FROM dba_users where username like 'DEMO%';

SELECT * FROM user_role_privs;  -- Xem quyền của người dùng hiện tại
SELECT * FROM dba_sys_privs WHERE grantee = 'ADMIN';  -- Xem quyền hệ thống của người dùng


DROP USER demo_user_12 CASCADE;

SELECT * FROM DBA_SYS_PRIVS WHERE GRANTEE =  'DEMO_USER_34';
