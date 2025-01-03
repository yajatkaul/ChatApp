import mongoose from "mongoose";

//Schema
const userDMSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    userDMs: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Conversation",
        default: [],
      },
    ],
  },
  { timestamps: true }
);

const UserDm = mongoose.model("UserDm", userDMSchema);

export default UserDm;
