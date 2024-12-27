import { configDotenv } from "dotenv";
import authRoute from "./routes/auth.routes.js";
import userRoute from "./routes/user.routes.js";
import dmRoute from "./routes/dm.routes.js";
import connectToMongoDB from "./db/connectToMongodb.js";
import MongoStore from "connect-mongo";
import session from "express-session";
import cookieParser from "cookie-parser";
import express from "express";
import path, { dirname } from "path";
import { fileURLToPath } from "url";
import { app } from "./socket/socket.js";

configDotenv();

app.use(express.json());
app.use(cookieParser());

app.use(
  session({
    name: "AuthCookie",
    secret: process.env.COOKIE_SECRET,
    resave: false,
    saveUninitialized: false,
    store: MongoStore.create({
      mongoUrl: process.env.DB_URI,
      collectionName: "sessions",
    }),
    cookie: {
      httpOnly: true,
      secure: process.env.NODE_ENV === "PRODUCTION" ? true : false, // Set to true if using HTTPS
    },
  })
);

app.use("/api/auth", authRoute);
app.use("/api/user", userRoute);
app.use("/api/dm", dmRoute);

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
app.use("/api/uploads", express.static(path.join(__dirname, "./uploads")));

app.listen(process.env.PORT || 4000, "0.0.0.0", () => {
  connectToMongoDB();
  console.log(`Server running on http://localhost:${process.env.PORT}`);
});
