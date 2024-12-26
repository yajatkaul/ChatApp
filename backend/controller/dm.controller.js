import User from "../models/user.model.js";

export const getUsersForNewMessage = async (req, res) => {
  try {
    const users = await User.find().select(
      "_id userName profilePic displayName"
    );

    res.status(200).json(users);
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};

export const sendMessage = async (req, res) => {
  try {
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};
