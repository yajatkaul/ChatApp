import express from "express";
import {
  createDM,
  getConversations,
  getMessage,
  getUsersForNewMessage,
  sendMessage,
} from "../controller/dm.controller.js";

const router = express.Router();

router.get("/getUsersForMessage", getUsersForNewMessage);

router.get("/getConversations", getConversations);

router.post("/sendMessage", sendMessage);

router.get("/getMessages", getMessage);

router.get("/createConversation", createDM);

export default router;
