import express from "express";
import {
  changeUsername,
  getUser,
  updatePFP,
} from "../controller/user.controller.js";
import upload from "../utils/multer.js";
import multer from "multer";

const router = express.Router();

router.post("/updateUsername", changeUsername);

router.post("/updatePFP", (req, res, next) => {
  upload.single("image")(req, res, function (err) {
    if (err instanceof multer.MulterError) {
      // Handle Multer-specific errors
      if (err.code === "LIMIT_FILE_SIZE") {
        return res
          .status(400)
          .json({ error: "File size exceeds the 100MB limit." });
      }
      return res.status(400).json({ error: err.message });
    } else if (err) {
      console.log(err);
      return res.status(500).json({ error: "An unknown error occurred." });
    }
    // Proceed to your controller if no errors
    updatePFP(req, res, next);
  });
});

router.get("/getUser", getUser);
export default router;
