import mongoose from "mongoose";

//Schema
const userSchema = new mongoose.Schema(
  {
    profilePic: {
      type: String,
    },
    displayName: {
      type: String,
      required: true,
    },
    userName: {
      type: String,
      required: true,
      unique: true,
    },
    password: {
      type: String,
      required: true,
      minlength: 5,
    },
    role: {
      type: String,
      default: "Member",
      enum: ["Member", "Employee", "Admin"],
    },
  },
  { timestamps: true }
);

const User = mongoose.model("User", userSchema);

export default User;
