import User from "../models/user.model.js";

export const changeUsername = async (req, res) => {
  try {
    const userId = req.session.userId;

    await User.findByIdAndUpdate(userId, { displayName: req.body.displayName });
    res.status(200).json({ result: "Success" });
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};

export const getUser = async (req, res) => {
  try {
    const user = await User.findById(req.session.userId);
    res.status(200).json(user);
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};

export const updatePFP = async (req, res) => {
  try {
    const filePath = req.file ? `uploads/${req.file.filename}` : null;
    await User.findByIdAndUpdate(req.session.userId, {
      profilePic: filePath,
    });
    res.status(200).json({ result: "Success" });
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};
