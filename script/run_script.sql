-- ============================
-- Drop objects if they exist
-- ============================
-- Cấp quyền quản lý user





-- Drop tables if they exist
BEGIN
  EXECUTE IMMEDIATE 'ALTER PLUGGABLE DATABASE QLNhanVien CLOSE IMMEDIATE';
  EXECUTE IMMEDIATE 'DROP PLUGGABLE DATABASE QLNhanVien INCLUDING DATAFILES';
EXCEPTION
  WHEN OTHERS THEN NULL; -- Ignore if PDB does not exist
END;
/

CREATE PLUGGABLE DATABASE QLNhanVien
  ADMIN USER admin IDENTIFIED BY 123456
  ROLES = (SYSDBA)
  FILE_NAME_CONVERT = ('/opt/oracle/oradata/FREE/pdbseed', '/opt/oracle/oradata/QLNhanVien/');  2    3    4  

-- ALTER PLUGGABLE DATABASE QLNhanVien OPEN;
-- CREATE USER ADMIN IDENTIFIED BY 123456;
-- GRANT CREATE USER TO ADMIN WITH ADMIN OPTION;
-- GRANT DROP USER TO ADMIN WITH ADMIN OPTION;
-- GRANT CREATE ROLE TO ADMIN WITH ADMIN OPTION;
-- GRANT GRANT ANY ROLE TO ADMIN;
-- GRANT CREATE PROCEDURE TO ADMIN;
-- GRANT EXECUTE ANY PROCEDURE TO ADMIN;
-- GRANT GRANT ANY PRIVILEGE TO ADMIN;



BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE DANGKY CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE MOMON CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE HOCPHAN CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE SINHVIEN CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE NHANVIEN CASCADE CONSTRAINTS';
    EXECUTE IMMEDIATE 'DROP TABLE DONVI CASCADE CONSTRAINTS';
EXCEPTION
    WHEN OTHERS THEN NULL; -- Ignore errors if tables do not exist
END;
/

-- Drop procedures if they exist
BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE PROC_CREATE_USER';
    EXECUTE IMMEDIATE 'DROP PROCEDURE PROC_CREATE_ROLE';
    EXECUTE IMMEDIATE 'DROP PROCEDURE PROC_GRANT_ROLE_TO_USER';
    EXECUTE IMMEDIATE 'DROP PROCEDURE PROC_GRANT_PRIVILEGE';
    EXECUTE IMMEDIATE 'DROP PROCEDURE PROC_REVOKE';
EXCEPTION
    WHEN OTHERS THEN NULL; -- Ignore errors if procedures do not exist
END;
/

-- Drop user if exists
BEGIN
    EXECUTE IMMEDIATE 'DROP USER admin CASCADE';
EXCEPTION
    WHEN OTHERS THEN NULL; -- Ignore errors if user does not exist
END;
/

-- ============================
-- Create new objects
-- ============================

-- CREATE PLUGGABLE DATABASE QLNhanVien

-- CREATE PLUGGABLE DATABASE QLNhanVien
--   ADMIN USER admin IDENTIFIED BY 123456
--   ROLES = (SYSDBA)
--   FILE_NAME_CONVERT = ('/opt/oracle/oradata/FREE/pdbseed', '/opt/oracle/oradata/QLNhanVien/');


-- Open the new PDB
-- ALTER PLUGGABLE DATABASE QLNhanVien OPEN;
-- Assign tablespace SYSTEM quota to user admin
-- ALTER SESSION SET CONTAINER = QLNhanVien;


-- Create tablespace USERS
CREATE TABLESPACE USERS
  DATAFILE '/opt/oracle/oradata/QLNHANVIEN/users.dbf'
  SIZE 100M AUTOEXTEND ON NEXT 10M MAXSIZE UNLIMITED;

-- CONNECT admin/123456@localhost:1521/QLNhanVien;

-- Create tables
CREATE TABLE DONVI (
    MADV VARCHAR2(10) PRIMARY KEY,
    TENDV VARCHAR2(100),
    LOAIDV VARCHAR2(20),
    TRGDV VARCHAR2(10) 
);

CREATE TABLE NHANVIEN (
    MANV VARCHAR2(20) PRIMARY KEY,
    HOTEN VARCHAR2(100),
    PHAI CHAR(1), -- 1: male, 0: female
    NGSINH DATE,
    LUONG NUMBER, 
    PHUCAP NUMBER,
    DT VARCHAR2(15),
    VAITRO VARCHAR2(50),
    MADV VARCHAR2(10), 
    FOREIGN KEY (MADV) REFERENCES DONVI(MADV)
);

CREATE TABLE SINHVIEN (
    MASV VARCHAR2(20) PRIMARY KEY,
    HOTEN VARCHAR2(100),
    PHAI CHAR(1),
    NGSINH DATE,
    DCHI VARCHAR2(256), 
    DT VARCHAR2(15),
    KHOA VARCHAR2(10),
    TINHTRANG VARCHAR2(100)
);

CREATE TABLE HOCPHAN (
    MAHP VARCHAR2(10) PRIMARY KEY,
    TENHP VARCHAR2(100),
    SOTC NUMBER,
    STLT NUMBER,
    STTH NUMBER,
    MADV VARCHAR2(10),
    FOREIGN KEY (MADV) REFERENCES DONVI(MADV)
);

CREATE TABLE MOMON (
    MAMM VARCHAR2(10) PRIMARY KEY,
    MAHP VARCHAR2(10),
    MAGV VARCHAR2(10),
    HK NUMBER,
    NAM NUMBER,
    FOREIGN KEY (MAHP) REFERENCES HOCPHAN(MAHP),
    FOREIGN KEY (MAGV) REFERENCES NHANVIEN(MANV)
);

CREATE TABLE DANGKY (
    MASV VARCHAR2(20),
    MAMM VARCHAR2(10),
    DIEMTH NUMBER,
    DIEMQT NUMBER,
    DIEMCK NUMBER,
    DIEMTK NUMBER,
    PRIMARY KEY (MASV, MAMM),
    FOREIGN KEY (MASV) REFERENCES SINHVIEN(MASV),
    FOREIGN KEY (MAMM) REFERENCES MOMON(MAMM)
);
-- DIEMTK: => DIEMQT*20% + DIEMTH*30% + DIEMCK*50%


-- CREATE TABLE DONVI (
--     MADV VARCHAR2(10) PRIMARY KEY,
--     TENDV VARCHAR2(100),
--     LOAIDV VARCHAR2(20),
--     TRGDV VARCHAR2(10) 
-- );
-- MADV: HOA => TENDV: Khoa hoá học => LOAIDV: KHOA
-- MADV PDT => TENDV: Phòng đào tạo => LOAIDV: PHONG
CREATE ROLE GV;
CREATE ROLE CBNV;
CREATE ROLE TEMPLATE;


INSERT INTO DONVI(MADV, TENDV, LOAIDV) VALUES ('PDT', 'Phòng đào tạo', 'PHONG');
INSERT INTO DONVI(MADV, TENDV, LOAIDV) VALUES ('PKT', 'Phòng kế toán', 'PHONG');
INSERT INTO DONVI(MADV, TENDV, LOAIDV) VALUES ('CTSV', 'Phòng công tác sinh viên', 'PHONG');
INSERT INTO DONVI(MADV, TENDV, LOAIDV) VALUES ('TOAN', 'Khoa Toán học', 'KHOA');
INSERT INTO DONVI(MADV, TENDV, LOAIDV) VALUES ('VATLY', 'Khoa Vật lý', 'KHOA');
INSERT INTO DONVI(MADV, TENDV, LOAIDV) VALUES ('CNTT', 'Khoa Công nghệ thông tin', 'KHOA');
INSERT INTO DONVI(MADV, TENDV, LOAIDV) VALUES ('HOA', 'Khoa Hoá học', 'KHOA');
INSERT INTO DONVI(MADV, TENDV, LOAIDV) VALUES ('KHKT', 'Khoa kỹ thuật', 'KHOA');  
INSERT INTO DONVI(MADV, TENDV, LOAIDV) VALUES ('SINH', 'Khoa Sinh học', 'KHOA');
-- SINHVIEN: csv
-- NHANVIEN

-- HOCPHAN
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('MTH00003', 'Vi tích phân 1B', 3, 45, 0, 'TOAN');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('MTH00081', 'Thực hành Vi tích phân 1B', 1, 0, 30, 'TOAN');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('MTH00004', 'Vi tích phân 2B', 3, 45, 0, 'TOAN');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('MTH00082', 'Thực hành Vi tích phân 2B', 1, 0, 30, 'TOAN');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('MTH00030', 'Đại số tuyến tính', 3, 45, 0, 'TOAN');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('MTH00083', 'Thực hành Đại số tuyến tính', 1, 0, 30, 'TOAN');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('MTH00040', 'Xác xuất thống kê', 3, 45, 0, 'TOAN');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('MTH00085', 'Thực hành Xác xuất thống kê', 1, 0, 30, 'TOAN');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('MTH00041', 'Toán rời rạc', 3, 45, 0, 'TOAN');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('MTH00086', 'Thực hành Toán rời rạc', 1, 0, 30, 'TOAN');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('MTH00050', 'Toán học tổ hợp', 4, 45, 30, 'TOAN');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('MTH00051', 'Toán ứng dụng và thống kê', 4, 45, 30, 'TOAN');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('MTH00052', 'Phương pháp tính', 4, 45, 30, 'TOAN');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('MTH00053', 'Lý thuyết số', 4, 45, 30, 'TOAN');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('MTH00054', 'Phép tính vị từ', 4, 45, 30, 'TOAN');


INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('PHY00001', 'Vật lý đại cương 1', 3, 30, 0, 'VATLY');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('PHY00002', 'Vật lý đại cương 2', 3, 30, 0, 'VATLY');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('PHY00081', 'Thực hành Vật lý đại cương 1', 2, 0, 60, 'VATLY');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('PHY00082', 'Thực hành Vật lý đại cương 2', 2, 0, 60, 'VATLY');

INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('BIO00001', 'Sinh đại cương 1', 3, 30, 0, 'SINH');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('BIO00002', 'Sinh đại cương 2', 3, 30, 0, 'SINH');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('BIO00081', 'Thực hành Sinh đại cương 1', 2, 0, 60, 'SINH');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('BIO00082', 'Thực hành Sinh đại cương 2', 2, 0, 60, 'SINH');

INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('CSC10001', 'Nhập môn lâp trình', 4, 45, 30, 'CNTT');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('CSC10002', 'Kỹ thuật lập trình', 4, 45, 30, 'CNTT');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('CSC10003', 'Phương pháp lập trình hướng đối tượng', 4, 45, 30, 'CNTT');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('CSC10004', 'Cấu trúc dữ liệu và giải thuật', 4, 45, 30, 'CNTT');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('CSC10006', 'Cơ sở dữ liệu', 4, 45, 30, 'CNTT');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('CSC10007', 'Hệ điều hành', 4, 45, 30, 'CNTT');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('CSC10008', 'Mạng máy tính', 4, 45, 30, 'CNTT');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('CSC10009', 'Hệ thống máy tính', 2, 30, 0, 'CNTT');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('CSC13002', 'Nhập môn công nghệ phần mềm', 4, 45, 30, 'CNTT');
INSERT INTO HOCPHAN(MAHP, TENHP, SOTC, STLT, STTH, MADV) VALUES ('CSC14003', 'Cơ sở trí tuệ nhân tạo', 4, 45, 30, 'CNTT');


-- sqlldr ADMIN/123456@localhost:1521/QLNHANVIEN control=sinhvien.ctl log=data_sinhvien.log bad=sinhvien.bad



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
    -- Xây dựng câu lệnh CREATE USER
    v_sql := 'CREATE USER ' || p_username || ' IDENTIFIED BY ' || p_password || 
             ' DEFAULT TABLESPACE ' || p_tablespace || ' PROFILE ' || p_profile;

    DBMS_OUTPUT.PUT_LINE('SQL: ' || v_sql);  -- Hiển thị câu lệnh SQL

    IF p_quota IS NOT NULL THEN
        v_sql := v_sql || ' QUOTA ' || p_quota || ' ON ' || p_tablespace;
    END IF;

    -- Thực thi lệnh CREATE USER
    EXECUTE IMMEDIATE v_sql;
    DBMS_OUTPUT.PUT_LINE('User ' || p_username || ' created successfully');



    -- -- Cấp role mặc định nếu có
    -- IF p_default_role IS NOT NULL THEN
    --     EXECUTE IMMEDIATE 'GRANT ' || p_default_role || ' TO ' || p_username;
    --     DBMS_OUTPUT.PUT_LINE('GRANT ' || p_default_role || ' TO ' || p_username);
    -- END IF;


    -- -- Cấp SYSDBA nếu cần
    -- IF p_grant_sysdba THEN
    --     EXECUTE IMMEDIATE 'GRANT SYSDBA TO ' || p_username;
    --     DBMS_OUTPUT.PUT_LINE('GRANT SYSDBA TO ' || p_username);
    -- END IF;

    -- Cấp quyền CREATE SESSION
    EXECUTE IMMEDIATE 'GRANT CREATE SESSION TO ' || p_username;
    DBMS_OUTPUT.PUT_LINE('GRANT CREATE SESSION TO ' || p_username);

    COMMIT;
    p_status := 'User created successfully';
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);  -- In thông báo lỗi

        p_status := 'Error: ' || SQLERRM;
END;
/




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

SET SERVEROUTPUT ON;
DECLARE
  v_status VARCHAR2(400);  
  v_username VARCHAR2(30) := 'demo_user_53';  -- Tên user vừa tạo

BEGIN
  SYSTEM.PROC_CREATE_USER(
    p_username     => v_username,
    p_password     => '123456',
    p_tablespace   => 'USERS',
    p_profile      => 'DEFAULT',
    p_quota        => 'UNLIMITED',
    p_default_role => '',
    p_grant_sysdba => FALSE,
    p_status       => v_status
  );
  DBMS_OUTPUT.PUT_LINE(v_status);
  -- Kiểm tra các role được cấp cho user
  FOR rec IN (SELECT * FROM DBA_ROLE_PRIVS WHERE GRANTEE = v_username) LOOP
    DBMS_OUTPUT.PUT_LINE('Role granted to user ' || v_username || ': ' || rec.GRANTED_ROLE);
  END LOOP;

  -- Kiểm tra quyền của user trên các bảng (nếu có)
  FOR rec IN (SELECT * FROM DBA_TAB_PRIVS WHERE GRANTEE = v_username) LOOP
    DBMS_OUTPUT.PUT_LINE('Table privilege granted to ' || v_username || ': ' || rec.TABLE_NAME || ' - ' || rec.PRIVILEGE);
  END LOOP;
  
  -- Kiểm tra quyền hệ thống của user (nếu có)
  FOR rec IN (SELECT * FROM DBA_SYS_PRIVS WHERE GRANTEE = v_username) LOOP
    DBMS_OUTPUT.PUT_LINE('System privilege granted to ' || v_username || ': ' || rec.PRIVILEGE);
  END LOOP;

  -- Kiểm tra quyền của user trong các role (lặp lại để chắc chắn các quyền role)
  FOR rec IN (SELECT * FROM DBA_ROLE_PRIVS WHERE GRANTEE = v_username) LOOP
    DBMS_OUTPUT.PUT_LINE('Role ' || rec.GRANTED_ROLE || ' granted to user ' || v_username);
  END LOOP;
END;
/
