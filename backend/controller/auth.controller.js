import User from "../models/user.model.js";
import bcrypt from "bcrypt";

//CREATING AN ACCOUNT FROM HERE
export const signup = async (req, res) => {
  try {
    const { displayName, password, confirmPassword } = req.body;
    console.log(req.body);
    //Salting and hashing the password
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    //Function to check if all the details are inputted correctly
    const result = await signupChecks({
      displayName,
      password,
      confirmPassword,
    });

    //If details are not correct then sends a error response
    if (result !== true) {
      return res.status(400).json({ error: result.error });
    }

    const newUser = new User({
      displayName,
      password: hashedPassword,
    });

    await newUser.save();

    req.session.userId = newUser._id;

    res.status(200).json({ result: `Success` });
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};

//Function to check the details if they are correct or not
async function signupChecks({ displayName, password, confirmPassword }) {
  const nameCheck = await User.findOne({ displayName });

  if (nameCheck) {
    return { error: "Name is already in use" };
  }

  if (!password || !displayName || !confirmPassword) {
    return { error: "Please fill all fields" };
  }

  if (displayName.length < 5) {
    return { error: "Names should be greater than 4 letters" };
  }

  if (password.length < 5) {
    return { error: "Names should be greater than 4 letters" };
  }

  if (password !== confirmPassword) {
    return { error: "Passwords do not match" };
  }

  return true;
}

//LOGING IN ACCOUNT
export const login = async (req, res) => {
  //Check if already logged in
  if (req.session.userId) {
    return res.status(200).json({ error: "You are already logged in." });
  }

  //Request payload
  const { displayName, password } = req.body;

  if (!displayName || !password) {
    return res.status(400).json({ error: "Please fill all the fields" });
  }

  //Search for the user and gets the details
  const user = await User.findOne({ displayName });

  //Decrypt and compare the password -- returns true or fals
  const isPasswordCorrect = await bcrypt.compare(
    password,
    user?.password || ""
  );

  //If incorrect return 400 error
  if (!isPasswordCorrect) {
    return res.status(400).json({ error: "Incorrect username or password" });
  }

  //Create a session
  req.session.userId = user._id;

  //If success return 200 okk
  res.status(200).json({ result: "Success" });
};

//Logout of account
export const logout = async (req, res) => {
  req.session.destroy((err) => {
    if (err) {
      return res.status(500).json({ error: "Failed to logout" });
    }
    res.clearCookie("AuthCookie");
    res.json({ result: "Logout successful" });
  });
};
