import Conversation from "../models/conversation.mode.js";
import Message from "../models/message.model.js";
import User from "../models/user.model.js";
import { io, userSocketMap } from "../socket/socket.js";

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

export const getConversations = async (req, res) => {
  try {
    const conversations = await Conversation.find({
      members: req.session.userId,
    })
      .populate({ path: "members", select: "_id displayName profilePic" })
      .select("_id members type");

    const filteredConversations = conversations.map((conversation) => {
      const conversationObj = conversation.toObject();
      const userIndex = conversationObj.members.findIndex(
        (member) => member._id.toString() === req.session.userId
      );

      if (userIndex !== -1) {
        conversationObj.members.splice(userIndex, 1);
      }

      return conversationObj;
    });

    res.status(200).json(filteredConversations);
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};

export const sendMessage = async (req, res) => {
  try {
    const { message } = req.body;
    const { conversationId } = req.query;

    const conversation = await Conversation.findById(conversationId);

    const newMessage = new Message({
      conversationId,
      userId: req.session.userId,
      message,
    });

    await newMessage.save();

    const populatedMessage = await newMessage.populate("userId");

    const memberIds = [
      ...new Set(conversation.members.map((memberId) => memberId.toString())),
    ];

    memberIds.forEach((memberId) => {
      const memberSocketId = userSocketMap[memberId.toString()];
      if (memberSocketId) {
        io.to(memberSocketId).emit("newMessage", populatedMessage);
      }
    });

    res.status(200).json({ result: "Success" });
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};

export const sendLocation = async (req, res) => {
  try {
    const { message } = req.body;
    const { conversationId } = req.query;

    const conversation = await Conversation.findById(conversationId);

    const newMessage = new Message({
      conversationId,
      userId: req.session.userId,
      message,
      type: "MAP",
    });

    await newMessage.save();

    const populatedMessage = await newMessage.populate("userId");

    const memberIds = [
      ...new Set(conversation.members.map((memberId) => memberId.toString())),
    ];

    memberIds.forEach((memberId) => {
      const memberSocketId = userSocketMap[memberId.toString()];
      if (memberSocketId) {
        io.to(memberSocketId).emit("newMessage", populatedMessage);
      }
    });

    res.status(200).json({ result: "Success" });
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};

export const sendAsset = async (req, res) => {
  try {
    const assets = req.files;
    const { conversationId } = req.query;

    const conversation = await Conversation.findById(conversationId);
    if (!conversation) {
      return res.status(404).json({ error: "Conversation not found" });
    }

    const promises = assets.map((asset) => {
      const mimeType = asset.mimetype;
      console.log(mimeType);
      let type;
      if (mimeType.startsWith("image/")) {
        type = "IMAGE";
      } else if (mimeType.startsWith("video/")) {
        type = "VIDEO";
      } else {
        throw new Error("Invalid file type");
      }

      const newMessage = new Message({
        conversationId,
        userId: req.session.userId,
        type,
        message: asset.path,
      });

      return newMessage
        .save()
        .then((savedMessage) => savedMessage.populate("userId"));
    });

    const populatedMessages = await Promise.all(promises);

    const memberIds = [
      ...new Set(conversation.members.map((memberId) => memberId.toString())),
    ];
    memberIds.forEach((memberId) => {
      const memberSocketId = userSocketMap[memberId.toString()];
      if (memberSocketId) {
        populatedMessages.forEach((message) => {
          io.to(memberSocketId).emit("newMessage", message);
        });
      }
    });

    res.status(200).json({ result: "Success" });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};

export const sendVM = async (req, res) => {
  try {
    const vm = req.file;
    const { conversationId } = req.query;

    const conversation = await Conversation.findById(conversationId);
    if (!conversation) {
      return res.status(404).json({ error: "Conversation not found" });
    }

    const newMessage = new Message({
      conversationId,
      userId: req.session.userId,
      type: "VOICE",
      message: vm.path,
    });

    await newMessage.save();
    const populatedMessage = newMessage.populate("userId");

    const memberIds = [
      ...new Set(conversation.members.map((memberId) => memberId.toString())),
    ];
    memberIds.forEach((memberId) => {
      const memberSocketId = userSocketMap[memberId.toString()];
      if (memberSocketId) {
        io.to(memberSocketId).emit("newMessage", populatedMessage);
      }
    });

    res.status(200).json({ result: "Success" });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};

export const getMessage = async (req, res) => {
  try {
    const { conversationId } = req.query;
    const messages = await Message.find({ conversationId }).populate("userId");

    res.status(200).json(messages);
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};

export const createDM = async (req, res) => {
  try {
    const { userId } = req.query;

    const conversation = await Conversation.findOne({
      type: "DM",
      members: [req.session.userId, userId],
    });

    if (!conversation) {
      const newConversation = await Conversation({
        type: "DM",
      });

      newConversation.members.push(userId);
      newConversation.members.push(req.session.userId);

      await newConversation.save();

      return res.status(200).json({ id: newConversation._id });
    }

    res.status(200).json({ id: conversation._id });
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};

export const deleteMessage = async (req, res) => {
  try {
    const { messageId, convoId } = req.query;

    const message = await Message.findById(messageId);

    if (message.userId.toString() !== req.session.userId) {
      return res.status(401).json({ error: "Unauthorized" });
    }

    await Message.findByIdAndDelete(messageId);

    const conversation = await Conversation.findById(convoId);

    const memberIds = [
      ...new Set(conversation.members.map((memberId) => memberId.toString())),
    ];

    memberIds.forEach((memberId) => {
      const memberSocketId = userSocketMap[memberId.toString()];
      if (memberSocketId) {
        io.to(memberSocketId).emit("deleteMessage", { messageId, convoId });
      }
    });

    res.status(200).json({ result: "Success" });
  } catch (err) {
    console.log(err);
    return res.status(500).json({ error: "Internal server error" });
  }
};
