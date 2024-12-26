import express from "express";
import { getUsersForNewMessage } from "../controller/dm.controller.js";

const router = express.Router();

router.get("/getUsersForMessage", getUsersForNewMessage);

export default router;
