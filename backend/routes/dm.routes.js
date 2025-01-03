import express from "express";
import {
  createDM,
  getConversations,
  getMessage,
  getUsersForNewMessage,
  sendAsset,
  sendMessage,
  sendVM,
} from "../controller/dm.controller.js";
import upload from "../utils/multer.js";

const router = express.Router();

router.get("/getUsersForMessage", getUsersForNewMessage);

router.get("/getConversations", getConversations);

router.post("/sendMessage", sendMessage);
router.post("/sendAsset", upload.array("assets", 20), sendAsset);
router.post("/sendVM", upload.single("vm"), sendVM);

router.get("/getMessages", getMessage);

router.get("/createConversation", createDM);

export default router;
