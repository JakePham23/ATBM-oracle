import { getConnection } from '../dbs/oracle.js';
import oracledb from 'oracledb';

export const createUser = async (req, res) => {
  const {
    username,
    password,
    tablespace = 'USERS',
    profile = 'DEFAULT',
    quota = null,
    default_role = null,
    grant_sysdba = false
  } = req.body;

  const sql = `
  BEGIN
    PROC_CREATE_USER(
      p_username     => :username,
      p_password     => :password,
      p_tablespace   => :tablespace,
      p_profile      => :profile,
      p_quota        => :quota,
      p_default_role => :default_role,
      p_grant_sysdba => :grant_sysdba,
      p_status       => :out_status
    );
  END;
`;
  const binds = {
    username,
    password,
    tablespace,
    profile,
    quota,
    default_role,
    grant_sysdba,
    out_status: { dir: oracledb.BIND_OUT, type: oracledb.STRING, maxSize: 400 }
  };

  let conn;
  try {
    conn = await getConnection();
    const result = await conn.execute(sql, binds);
    const status = result.outBinds.out_status;

    if (status && typeof status === 'string' && status.startsWith('SUCCESS')) {
      console.log('User created successfully:', status);
      res.json({ success: true, message: status });
    } else {
      console.error('Error creating user:', status);
      res.status(500).json({ success: false, message: status || 'Unknown error' });
    }
  } catch (err) {
    console.error('Error executing SQL:', err.message);
    res.status(500).json({ success: false, error: err.message });
  } finally {
    if (conn) {
      try {
        await conn.close();
      } catch (err) {
        console.error('Error closing connection:', err.message);
      }
    }
  }
};


export const createRole = async (req, res) => {
  const { role_name } = req.body;
  const sql = `BEGIN PROC_CREATE_ROLE(:role_name); END;`;

  try {
    const conn = await getConnection();
    await conn.execute(sql, { role_name });
    res.json({ success: true, message: '✅ Role created successfully' });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
};

export const grantRole = async (req, res) => {
  const { role_name, username } = req.body;
  const sql = `BEGIN PROC_GRANT_ROLE_TO_USER(:role_name, :username); END;`;

  try {
    const conn = await getConnection();
    await conn.execute(sql, { role_name, username });
    res.json({ success: true, message: '✅ Role granted successfully' });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
};

export const grantPrivilege = async (req, res) => {
  const { privs, table, target } = req.body;
  const sql = `BEGIN PROC_GRANT_PRIVILEGE(:privs, :table, :target); END;`;

  try {
    const conn = await getConnection();
    await conn.execute(sql, { privs, table, target });
    res.json({ success: true, message: '✅ Privilege granted successfully' });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
};

export const revoke = async (req, res) => {
  const { type, what, table, target } = req.body;
  const sql = `BEGIN PROC_REVOKE(:type, :what, :table, :target); END;`;

  try {
    const conn = await getConnection();
    await conn.execute(sql, { type, what, table, target });
    res.json({ success: true, message: '✅ Revoked successfully' });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
};



