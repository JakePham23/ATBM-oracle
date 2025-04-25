import oracledb from "oracledb";
import dotenv from 'dotenv';
dotenv.config();

let pool;

export const initPool = async () => {
  if (!pool) {
  try{
    pool = await oracledb.createPool({
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      connectString: process.env.DB_CONNECTION_STRING,
      // privilege: oracledb.SYSDBA, // Thêm dòng này
      poolMin: 1,
      poolMax: 10,
      poolIncrement: 1
    });
    console.log("user pool created:", process.env.DB_USER, process.env.DB_PASSWORD, process.env.DB_CONNECTION_STRING);
  } catch(err){
    console.error("Error creating Oracle DB pool:", err);
  }
    
    // console.log("✅ Oracle DB pool created", user,"", password, "", connectString);
  }
};

export const getConnection = async (pdbName = 'QLNHANVIEN') => {
  if (!pool) await initPool();
  const connection = await pool.getConnection();
  await connection.execute(`ALTER SESSION SET CONTAINER=${pdbName}`);
  // Sửa thành CONTAINER thay vì CONTAINER
  // await connection.execute(`ALTER SESSION SET CONTAINER=${pdbName}`);
  // console.log(`✅ ALTER SESSION SET CONTAINER=${pdbName}`);
  return connection;
};
export const closePool = async () => {
  if (pool) {
    await pool.close(0);
    pool = null;
    console.log("✅ Oracle DB pool closed");
  }
};