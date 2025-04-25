import express from "express";
const app = express();
app.use(express.json());
import { initPool } from './dbs/oracle.js';
await initPool(); // chạy pool trước khi nhận request
import userRoutes from './routes/user.route.js';
import cors from 'cors';
app.use(cors());

app.use('/api/user', userRoutes);
 



export default app;