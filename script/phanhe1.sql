-- ============================
-- 📦 PROC: TẠO USER TỰ ĐỘNG
-- ============================
-- INPUT:
--   p_username: Tên user (VARCHAR2)
--   p_password: Mật khẩu (VARCHAR2)
--   p_tablespace: Tên tablespace (mặc định: USERS)
--   p_profile: Profile sử dụng (mặc định: DEFAULT)
--   p_quota: Dung lượng quota, ví dụ 'UNLIMITED' (có thể NULL)
--   p_default_role: Role mặc định muốn gán (có thể NULL)
--   p_grant_sysdba: Gán quyền SYSDBA hay không (BOOLEAN)

CONNECT admin/123456@localhost:1521/QLNHANVIEN;
CREATE OR REPLACE PROCEDURE PROC_CREATE_USER (
    p_username       IN VARCHAR2,
    p_password       IN VARCHAR2,
    p_tablespace     IN VARCHAR2 DEFAULT 'USERS',
    p_profile        IN VARCHAR2 DEFAULT 'DEFAULT',
    p_quota          IN VARCHAR2 DEFAULT NULL,
    p_default_role   IN VARCHAR2 DEFAULT NULL,
    p_grant_sysdba   IN BOOLEAN DEFAULT FALSE,
    p_status         OUT VARCHAR2
)
AS
    v_sql VARCHAR2(1000);
BEGIN
    -- Mở một transaction (mặc định là tự động)
    -- Xây dựng câu lệnh CREATE USER
    v_sql := 'CREATE USER ' || p_username || 
             ' IDENTIFIED BY "' || p_password || '"' ||
             ' DEFAULT TABLESPACE ' || p_tablespace ||
             ' PROFILE ' || p_profile;

    IF p_quota IS NOT NULL THEN
        v_sql := v_sql || ' QUOTA ' || p_quota || ' ON ' || p_tablespace;
    END IF;

    -- Thực thi lệnh CREATE USER
    EXECUTE IMMEDIATE v_sql;

    -- Cấp quyền CREATE SESSION cho người dùng
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ' || p_username;

    -- Nếu có role mặc định, cấp quyền cho người dùng
    IF p_default_role IS NOT NULL THEN
        EXECUTE IMMEDIATE 'GRANT ' || p_default_role || ' TO ' || p_username;
    END IF;

    -- Nếu cần cấp quyền SYSDBA
    IF p_grant_sysdba THEN
        EXECUTE IMMEDIATE 'GRANT SYSDBA TO ' || p_username;
    END IF;

    -- Nếu không có lỗi, commit transaction
    COMMIT;

    -- Trả về thông báo thành công
    p_status := 'SUCCESS: User ' || p_username || ' created.';
EXCEPTION
    WHEN OTHERS THEN
        -- Nếu có lỗi, rollback tất cả các thay đổi
        ROLLBACK;

        -- Trả về thông báo lỗi
        p_status := 'ERROR: ' || SQLERRM;
END;



-- ============================
-- 📦 PROC: TẠO ROLE
-- ============================
-- INPUT:
--   p_role_name: Tên role cần tạo (VARCHAR2)
CREATE OR REPLACE PROCEDURE PROC_CREATE_ROLE (
    p_role_name IN VARCHAR2
)
AS
BEGIN
    EXECUTE IMMEDIATE 'CREATE ROLE ' || p_role_name;
    DBMS_OUTPUT.PUT_LINE('✅ Role ' || p_role_name || ' created successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('❌ Error creating role ' || p_role_name || ': ' || SQLERRM);
END;
/

-- ============================
-- 📦 PROC: GÁN ROLE CHO USER
-- ============================
-- INPUT:
--   p_role_name: Tên role (VARCHAR2)
--   p_username: Tên user (VARCHAR2)
CREATE OR REPLACE PROCEDURE PROC_GRANT_ROLE_TO_USER (
    p_role_name IN VARCHAR2,
    p_username  IN VARCHAR2
)
AS
BEGIN
    EXECUTE IMMEDIATE 'GRANT ' || p_role_name || ' TO ' || p_username;
    DBMS_OUTPUT.PUT_LINE('✅ Granted role ' || p_role_name || ' to ' || p_username);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('❌ Error granting role: ' || SQLERRM);
END;
/

-- ============================
-- 📦 PROC: GÁN QUYỀN CHO USER/ROLE (MULTI-PRIV)
-- ============================
-- INPUT:
--   p_privs: Danh sách quyền cách nhau bằng dấu phẩy, ví dụ 'SELECT,INSERT,UPDATE'
--   p_table: Tên bảng (VARCHAR2)
--   p_target: Tên user hoặc role cần cấp quyền
CREATE OR REPLACE PROCEDURE PROC_GRANT_PRIVILEGE (
    p_privs     IN VARCHAR2,
    p_table     IN VARCHAR2,
    p_target    IN VARCHAR2
)
AS
    v_sql VARCHAR2(1000);
BEGIN
    v_sql := 'GRANT ' || p_privs || ' ON ' || p_table || ' TO ' || p_target;
    EXECUTE IMMEDIATE v_sql;
    DBMS_OUTPUT.PUT_LINE('✅ Granted ' || p_privs || ' on ' || p_table || ' to ' || p_target);
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('❌ Error granting privilege: ' || SQLERRM);
END;
/

-- ============================
-- 📦 PROC: THU HỒI QUYỀN HOẶC ROLE
-- ============================
-- INPUT:
--   p_type: 'ROLE' hoặc 'PRIV'
--   p_what: Tên role hoặc tên quyền (SELECT, INSERT, ...)
--   p_table: Nếu là quyền thì cần chỉ rõ bảng (có thể NULL nếu p_type = 'ROLE')
--   p_target: User hoặc role bị thu hồi quyền/role
CREATE OR REPLACE PROCEDURE PROC_REVOKE (
    p_type      IN VARCHAR2,  -- 'ROLE' or 'PRIV'
    p_what      IN VARCHAR2,  -- role name OR privilege
    p_table     IN VARCHAR2 DEFAULT NULL, -- only if privilege
    p_target    IN VARCHAR2
)
AS
    v_sql VARCHAR2(1000);
BEGIN
    IF p_type = 'ROLE' THEN
        v_sql := 'REVOKE ' || p_what || ' FROM ' || p_target;
    ELSE
        v_sql := 'REVOKE ' || p_what || ' ON ' || p_table || ' FROM ' || p_target;
    END IF;

    EXECUTE IMMEDIATE v_sql;
    DBMS_OUTPUT.PUT_LINE('✅ Revoked successfully.');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('❌ Error revoking: ' || SQLERRM);
END;
/
