import mongoose from "mongoose";

//Schema
const userSchema = new mongoose.Schema(
  {
    profilePic: {
      type: String,
      default:
        "https://i.pinimg.com/736x/f6/bc/9a/f6bc9a75409c4db0acf3683bab1fab9c.jpg",
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
