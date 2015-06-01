package com.aristobot.repository;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

import com.aristobot.data.ChatMessage;
import com.aristobot.data.SystemMessage;
import com.aristobot.data.User;
import com.aristobot.data.wrappers.Conversation;
import com.aristobot.exceptions.DatabaseException;
import com.aristobot.managers.JDBCManager;
import com.aristobot.utils.Constants.MessageType;
import com.aristobot.utils.Utility;

public class MessageRepository 
{
	private JDBCManager dbManager;
	
	public MessageRepository(JDBCManager manager)
	{
		dbManager = manager;
	}
	
	public Boolean systemMessageExists(String messageKey)
	{		
   	 	String messageSelect = "SELECT messageKey FROM messages WHERE messageKey = ?";

		PreparedStatement pstmt = dbManager.getPreparedStatement(messageSelect);
		
		try {
	      pstmt.setString(1, messageKey);
	      ResultSet rs = pstmt.executeQuery();
	       
	      return rs.next();
        } 
		catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt);
		}
		
	}

	public SystemMessage getSystemMessage(String messageKey)
	{
		SystemMessage message = null;
		
   	 	String messageSelect = "SELECT messageKey, iconKey, subject, body, isPriority FROM messages WHERE messageKey = ?";

		PreparedStatement pstmt = dbManager.getPreparedStatement(messageSelect);
		
		try 
        {
	      pstmt.setString(1, messageKey);
	      ResultSet rs = pstmt.executeQuery();
	       
	      if (rs.next())
	      {
	    	 message = new SystemMessage();
	    		 
			 message.messageKey = rs.getString("messageKey");
			 message.icon = Utility.getIcon(rs.getString("iconKey"));
			 message.subject = rs.getString("subject");
			 message.body = rs.getString("body");
			 message.isPriority = rs.getBoolean("isPriority");
	      }
        } 
		catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt);
		}
		
		return message;
	}

	public List<SystemMessage> getSystemMessages()
	{
		List<SystemMessage> messages = new ArrayList<SystemMessage>();
		
   	 	String messageSelect = "SELECT messageKey, iconKey, subject, body, isPriority, type FROM messages ";

		PreparedStatement pstmt = dbManager.getPreparedStatement(messageSelect);
		
		try 
        {	      
	      ResultSet rs = pstmt.executeQuery();
	       
	      while (rs.next())
	      {
	    	 SystemMessage message = new SystemMessage();
	    		 
			 message.messageKey = rs.getString("messageKey");
			 message.icon = Utility.getIcon(rs.getString("iconKey"));
			 message.subject = rs.getString("subject");
			 message.body = rs.getString("body");
			 message.isPriority = rs.getBoolean("isPriority");
			 message.type = rs.getString("type");
			 
			 messages.add(message);
	      }
        } 
		catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt);
		}
		
		return messages;
	}
	

	public List<SystemMessage> getSystemMessages(MessageType type)
	{
		List<SystemMessage> messages = new ArrayList<SystemMessage>();
		
   	 	String messageSelect = "SELECT messageKey, iconKey, subject, body, isPriority FROM messages "+
   	 						   "WHERE type= ?";

		PreparedStatement pstmt = dbManager.getPreparedStatement(messageSelect);
		
		try 
        {
	      pstmt.setString(1, type.value());
	      
	      ResultSet rs = pstmt.executeQuery();
	       
	      while (rs.next())
	      {
	    	 SystemMessage message = new SystemMessage();
	    		 
			 message.messageKey = rs.getString("messageKey");
			 message.icon = Utility.getIcon(rs.getString("iconKey"));
			 message.subject = rs.getString("subject");
			 message.body = rs.getString("body");
			 message.isPriority = rs.getBoolean("isPriority");
			 
			 messages.add(message);
	      }
        } 
		catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt);
		}
		
		return messages;
	}
	
	public List<SystemMessage> getSystemMessages(String username, int applicationId)
	{
		List<SystemMessage> messages = new ArrayList<SystemMessage>();
		
   	 	String messageSelect = "SELECT messages.messageKey, messages.iconKey, messages.subject, body, type, messages.isPriority, messages_users.isRead FROM messages_users "+
   	 						   "INNER JOIN messages ON messages_users.messageKey = messages.messageKey " +
   	 						   "WHERE messages_users.username = ? AND (messages_users.applicationId IS NULL OR messages_users.applicationId = ?) "+
   	 						   "ORDER BY messages_users.isRead ASC, messages_users.dateSent DESC";

		PreparedStatement pstmt = dbManager.getPreparedStatement(messageSelect);
		
		try 
        {
	      pstmt.setString(1, username);
	      pstmt.setInt(2, applicationId);
	      
	      ResultSet rs = pstmt.executeQuery();
	       
	      while (rs.next())
	      {
	    	 SystemMessage message = new SystemMessage();
	    		 
			 message.messageKey = rs.getString("messageKey");
			 message.icon = Utility.getIcon(rs.getString("iconKey"));
			 message.subject = rs.getString("subject");
			 message.body = rs.getString("body");
			 message.isPriority = rs.getBoolean("isPriority");
			 message.isRead = rs.getBoolean("isRead");
			 message.type = rs.getString("type");
			 
			 messages.add(message);
	      }
        } 
		catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt);
		}
		
		return messages;
	}
	
	
	public String addSystemMessage(String messageKey, String iconKey, String subject, String body, MessageType type)
	{		
   	 	String messageAdd = "INSERT INTO messages (messageKey, iconKey, subject, body, type) VALUES (?,?,?,?,?)";

		PreparedStatement pstmt = dbManager.getPreparedStatement(messageAdd);
		
		try 
        {
			 
			  pstmt.setString(1, messageKey);
		      pstmt.setString(2, iconKey);
		      pstmt.setString(3, subject);
		      pstmt.setString(4, body);
		      pstmt.setString(5, type.value());
		      
		      pstmt.executeUpdate();
		      
		      return messageKey;
        } 
		catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt);
		}
	}
	
	public String addSystemMessage(String iconKey, String subject, String body, MessageType type){
		return addSystemMessage(Utility.generateRandomToken(), iconKey, subject, body, type);
	}
	
	public void updateSystemMessage(String messageKey, String iconKey, String subject, String body, MessageType type)
	{		
   	 	String messageUpdate = "UPDATE messages SET iconKey = ?,subject = ?, body = ?, type = ? WHERE messageKey = ?";

		PreparedStatement pstmt = dbManager.getPreparedStatement(messageUpdate);
		
		try 
        {			  
		      pstmt.setString(1, iconKey);
		      pstmt.setString(2, subject);
		      pstmt.setString(3, body);
		      pstmt.setString(4, type.value());
		      pstmt.setString(5, messageKey);
		      
		      pstmt.executeUpdate();
		      
        } 
		catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt);
		}
	}
	
	public void deleteSystemMessage(String messageKey)
	{		
   	 	String messageDelete = "DELETE FROM messages WHERE messageKey = ?";

		PreparedStatement pstmt = dbManager.getPreparedStatement(messageDelete);
		
		try 
        {			  
		      pstmt.setString(1, messageKey);
		      
		      pstmt.executeUpdate();
		      
        } 
		catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt);
		}
	}
	
	
	
	public void addMessageToUser(String messageKey, String username)
	{		
   	 	String messageAdd = "INSERT IGNORE INTO messages_users (messageKey, username) VALUES (?,?)";

		PreparedStatement pstmt = dbManager.getPreparedStatement(messageAdd);
		
		try 
        {
	      pstmt.setString(1, messageKey);
	      pstmt.setString(2, username);
	      
	      pstmt.executeUpdate();
        } 
		catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt);
		}
	}
	
	public void addMessageToUser(String messageKey, String username, int applicationId)
	{		
   	 	String messageAdd = "INSERT IGNORE INTO messages_users (messageKey, username, applicationId) VALUES (?,?, ?)";

		PreparedStatement pstmt = dbManager.getPreparedStatement(messageAdd);
		
		try 
        {
	      pstmt.setString(1, messageKey);
	      pstmt.setString(2, username);
	      pstmt.setInt(3, applicationId);
	      
	      pstmt.executeUpdate();
        } 
		catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt);
		}
	}
	
	public void removeMessageFromUser(String messageKey, String username)
	{		
   	 	String messageDelete = "DELETE FROM messages_users WHERE messageKey = ? AND username = ?";

		PreparedStatement pstmt = dbManager.getPreparedStatement(messageDelete);
		
		try 
        {			  
		      pstmt.setString(1, messageKey);
		      pstmt.setString(2, username);
		      
		      pstmt.executeUpdate();
		      
        } 
		catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt);
		}
	}
	
	public void markMessageRead(String messageKey, String username)
	{
		String messageUpdate = "UPDATE messages_users SET isRead = 1 WHERE messageKey = ? AND username = ?";

		PreparedStatement pstmt = dbManager.getPreparedStatement(messageUpdate);
		
		try 
        {
	      pstmt.setString(1, messageKey);
	      pstmt.setString(2, username);
	      pstmt.executeUpdate();
        } 
		catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt);
		}
	}
	
	
	public Conversation getConversation(String primaryUsername, String conversationKey, int applicationId)
	{
		Conversation convo;
		
		String conversationSelect = "SELECT lastPosted, lastRead " +
		"FROM conversations INNER JOIN conversations_users ON conversations_users.conversationKey = conversations.conversationKey " +
		"WHERE conversations.conversationKey = ? AND LOWER(username) = LOWER(?)";

		PreparedStatement pstmt = dbManager.getPreparedStatement(conversationSelect);
		
		try 
		{
			pstmt.setString(1, conversationKey);
			pstmt.setString(2, primaryUsername);
			ResultSet rs = pstmt.executeQuery();
			
			if (rs.next())
			{
				convo = new Conversation(); 
				convo.conversationKey = conversationKey;
			
				convo.chatMessages = getChatMessages(conversationKey, applicationId);
				convo.hasUnreadMessages = hasUnreadMessages(rs);
			}
			else{
				convo = null;
			}
				
			return convo;
		
		} 
		catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt);
		}
	}
	
	
	
	public Conversation getConversation(List<String> usernames, int applicationId)
	{		
		String primaryUsername = usernames.get(0);
		String conversationKey = Utility.generateSeededToken(usernames);
		
		return getConversation(primaryUsername, conversationKey, applicationId);
	}
	

	public List<User> getConversationUsers(String conversationKey)
	{		
		String userSelect = "SELECT users.username, users.iconKey FROM users INNER JOIN conversations_users ON users.username = conversations_users.username " +
							"WHERE conversations_users.conversationKey = ?";

		PreparedStatement pstmt = dbManager.getPreparedStatement(userSelect);
		
		try 
		{
			pstmt.setString(1, conversationKey);
			ResultSet rs= pstmt.executeQuery();
			
			List<User> users = new ArrayList<User>();
			
			while (rs.next()){
				users.add(User.generate(rs, true));
			}
			
			return users;
		}
			
		catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt);
		}
						
	}
	
	public Boolean hasUnreadMessages(String primaryUsername, String conversationKey, int applicationId)
	{

		Boolean hasUnread = false;
		
		String conversationSelect = "SELECT lastPosted, lastRead " +
		"FROM conversations INNER JOIN conversations_users ON conversations_users.conversationKey = conversations.conversationKey " +
		"WHERE conversations.conversationKey = ? AND username = ?";

		PreparedStatement pstmt = dbManager.getPreparedStatement(conversationSelect);
		
		try 
		{
			pstmt.setString(1, conversationKey);
			pstmt.setString(2, primaryUsername);
			ResultSet rs = pstmt.executeQuery();
			
			hasUnread = rs.next() && hasUnreadMessages(rs);
		
		} 
		catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt);
		}
		
		return hasUnread;
	}
	
	protected Boolean hasUnreadMessages(ResultSet rs) throws SQLException
	{
		Timestamp lastPosted = rs.getTimestamp("lastPosted");
		Timestamp lastRead = rs.getTimestamp("lastRead");
	
		return lastPosted != null && (lastRead == null || lastPosted.getTime() > lastRead.getTime());
	}
	
	protected List<ChatMessage> getChatMessages(String conversationKey, int applicationId)
	{
		List<ChatMessage> chatList = new ArrayList<ChatMessage>();
		
		String chatSelect = "SELECT chatId, username, message, dateSent, NOW() as currentDate FROM chats " +
							"WHERE conversationKey = ? AND (applicationId IS NULL OR applicationId = ?) "+
							"ORDER BY dateSent DESC LIMIT 15 ";
		
		PreparedStatement pstmt = dbManager.getPreparedStatement(chatSelect);
		
		try 
        {
			pstmt.setString(1, conversationKey);
			pstmt.setInt(2, applicationId);
			ResultSet rs = pstmt.executeQuery();
			
			while (rs.next())
			{
				long currentDate = rs.getTimestamp("currentDate").getTime();
				
				ChatMessage chat = new ChatMessage();
				chat.id = rs.getInt("chatId");
				chat.username = rs.getString("username");
				chat.message = rs.getString("message");
				chat.dateSent = Utility.generateRoboDate(rs.getTimestamp("dateSent").getTime(), currentDate);
				
				chatList.add(chat);
			}
			
			Collections.reverse(chatList);
        } 
		catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt);
		}
		
		return chatList;
	}
	
	
	
	public Boolean validateConversationKey(String conversationKey)
	{
		String conversationSelect = "SELECT conversationKey FROM conversations WHERE conversationKey = ?";
		PreparedStatement pstmt = dbManager.getPreparedStatement(conversationSelect);
		
		try 
        {
			pstmt.setString(1, conversationKey);
			ResultSet rs = pstmt.executeQuery();
			
			return rs.next();
        }
		catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt);
		}
	}
	
	public void sendChatMessage(String senderUsername, String conversationKey, String message, int applicationId)
	{		
		insertMessage(conversationKey, senderUsername, message, applicationId);
		updateLastPosted(conversationKey);
		updateLastRead(senderUsername, conversationKey);
	}
	
	public String addConversation(List<String> usernames)
	{
		String conversationKey = Utility.generateSeededToken(usernames);
		
		if (validateConversationKey(conversationKey)) return conversationKey;
		
		String conversationAdd = "INSERT INTO conversations(conversationKey) VALUES(?)";

		PreparedStatement pstmt = dbManager.getPreparedStatement(conversationAdd);
		
		String conversationUserAdd = "INSERT INTO conversations_users(conversationKey, username) VALUES(?,?)";
		
		PreparedStatement pstmt2 = dbManager.getPreparedStatement(conversationUserAdd);
		
		try 
        {
		  pstmt.setString(1, conversationKey);
	      pstmt.executeUpdate();
	      
	      pstmt2.setString(1, conversationKey);
	      
	      for (String username:usernames){
	    	  pstmt2.setString(2, username);
	    	  pstmt2.executeUpdate();
	      }
	      
        } 
		catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt);
			dbManager.closeStatement(pstmt2);
		}
		
		return conversationKey;
	}
	
	protected void updateLastPosted(String conversationKey)
	{
		String conversationUpdated = "UPDATE conversations SET lastPosted = NOW() WHERE conversationKey = ?";

		PreparedStatement pstmt = dbManager.getPreparedStatement(conversationUpdated);
		
		try {
	      pstmt.setString(1, conversationKey);
	      pstmt.executeUpdate();
        } 
		catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt);
		}
	}
	
	protected void insertMessage(String conversationKey, String username, String message, int applicationId)
	{
		String chatAdd = "Insert INTO chats (conversationKey, username, applicationId, message) VALUES (?,?,?,?)";

		PreparedStatement pstmt = dbManager.getPreparedStatement(chatAdd);
		
		try 
        {
		  pstmt.setString(1, conversationKey);
	      pstmt.setString(2, username);
	      pstmt.setInt(3, applicationId);
	      pstmt.setString(4, message);
	      
	      pstmt.executeUpdate();
        } 
		catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt);
		}
	}
	
	public void updateLastRead(String username, String conversationKey)
	{
		String conversationUpdated = "UPDATE conversations_users SET lastRead = NOW() WHERE conversationKey = ? AND username = ?";

		PreparedStatement pstmt = dbManager.getPreparedStatement(conversationUpdated);
		
		try {
		  pstmt.setString(1, conversationKey);
		  pstmt.setString(2, username);
	      pstmt.executeUpdate();
        } 
		catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt);
		}
	}
	

}
