import express from "express";
import {
  createDM,
  deleteMessage,
  getConversations,
  getMessage,
  getUsersForNewMessage,
  sendAsset,
  sendFiles,
  sendLocation,
  sendMessage,
  sendVM,
} from "../controller/dm.controller.js";
import upload from "../utils/multer.js";

const router = express.Router();

router.get("/getUsersForMessage", getUsersForNewMessage);

router.get("/getConversations", getConversations);

router.post("/sendMessage", sendMessage);
router.post("/sendLocation", sendLocation);
router.post("/sendAsset", upload.array("assets", 20), sendAsset);
router.post("/sendFiles", upload.array("files", 20), sendFiles);
router.post("/sendVM", upload.single("vm"), sendVM);

router.get("/deleteMessage", deleteMessage);

router.get("/getMessages", getMessage);

router.get("/createConversation", createDM);

export default router;
