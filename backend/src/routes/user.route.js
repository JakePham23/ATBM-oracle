import express from 'express';
import {
  createUser,
  createRole,
  grantRole,
  grantPrivilege,
  revoke
} from '../controllers/user.controller.js';

const router = express.Router();

router.post('/create-user', createUser);
router.post('/create-role', createRole);
router.post('/grant-role', grantRole);
router.post('/grant-privilege', grantPrivilege);
router.post('/revoke', revoke);

export default router;
