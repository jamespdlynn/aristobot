package com.aristobot.services;

import java.util.List;

import javax.ws.rs.Consumes;
import javax.ws.rs.DefaultValue;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.Response;

import com.aristobot.data.AuthenticationData;
import com.aristobot.data.OutgoingChatMessage;
import com.aristobot.data.PushNotification;
import com.aristobot.data.SystemMessage;
import com.aristobot.data.User;
import com.aristobot.data.wrappers.Conversation;
import com.aristobot.data.wrappers.MessagesWrapper;
import com.aristobot.exceptions.OpponentException;
import com.aristobot.exceptions.UserException;
import com.aristobot.managers.AuthenticationManager;
import com.aristobot.managers.JDBCManager;
import com.aristobot.managers.JMSQueueManager;
import com.aristobot.managers.LogManager;
import com.aristobot.repository.MessageRepository;
import com.aristobot.repository.UserRepository;
import com.aristobot.utils.Constants.MessageType;
import com.aristobot.utils.Constants.QueueJDNI;
import com.aristobot.utils.Utility;

@Path("/messages")
public class MessageService
{

	private JDBCManager dbManager;
	private AuthenticationManager authManager;

	public MessageService(@DefaultValue("true") @QueryParam("includeMessages") Boolean includeAllData)
	{
		try{
			dbManager = new JDBCManager();
			authManager = new AuthenticationManager(dbManager);
		}
		catch (RuntimeException e){
    		throw LogManager.handleException(e);
 		}
	    finally{ 
	    	dbManager.close();
	    }
	}
	 
	 @GET
    @Path("/systemMessages")
	@Produces("application/xml")
    public MessagesWrapper getSystemMessages(@Context HttpHeaders headers)
    {
    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		
			MessageRepository messageRepo = new MessageRepository(dbManager);
			
			AuthenticationData authData = authManager.getAuthData();
			List<SystemMessage> messages = messageRepo.getSystemMessages(authData.username, authData.applicationId);
			
			return Utility.createMessagesWrapper(messages, authData);
    	}
    	catch (RuntimeException e){
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
    }
	
	@POST
	@Path("/markMessageRead")
	@Consumes("text/xml")
	public Response markMessageRead(@Context HttpHeaders headers, String messageKey)
	{
		try{
			dbManager.connect();
			
			authManager.setHeaders(headers.getRequestHeaders());
			authManager.requireFullAuthentication();
			
	    	MessageRepository repo = new MessageRepository(dbManager);
	    	
	    	if (!repo.systemMessageExists(messageKey)){
	    		dbManager.rollback();
	    		throw new UserException(UserException.INVALID_MESSAGE);
	    	}
	    	
	    	repo.markMessageRead(messageKey, authManager.getUsername());
		}
		catch (RuntimeException e){
			throw LogManager.handleException(e);
		}
	    finally{
	    	dbManager.close();
	    }
	    
	    return Response.status(200).build();
	}
    
    @GET
    @Path("/conversation/{key}")
	@Produces("application/xml")
    public Conversation getConversation(@Context HttpHeaders headers, @PathParam("key") String conversationKey, @DefaultValue("false") @QueryParam("onlyIfUnread") Boolean onlyIfUnread )
    {
    	Conversation convo;
    	
    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		
			MessageRepository messageRepo = new MessageRepository(dbManager);	
			
			String primaryUsername = authManager.getUsername();
			int applicationId = authManager.getApplicationId();
			
			 //Don't return conversation if onlyIfUnread flag is checked and there are no unread messages
			if (onlyIfUnread && !messageRepo.hasUnreadMessages(primaryUsername, conversationKey, applicationId)){
				convo = null;
			}
			else{
				convo = messageRepo.getConversation(primaryUsername, conversationKey, applicationId);
			}
    	}
    	catch (RuntimeException e){
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
	    
	   
	    return convo;
	    
    }
    
    @POST
    @Path("/sendChatMessage")
    @Consumes("application/xml")
    public Response sendChatMessage(@Context HttpHeaders headers, OutgoingChatMessage chat, @QueryParam("sendAsSystemMessage") boolean sendAsSystemMessage)
    {
    	try
    	{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		
    		MessageRepository messageRepo = new MessageRepository(dbManager);
    		UserRepository userRepo = new UserRepository(dbManager);
    		
    		String username = authManager.getUsername();
    		String conversationKey;
    		
    		if (chat.conversationKey != null)
    		{
    			
    			if (!messageRepo.validateConversationKey(chat.conversationKey)){
    				throw new OpponentException(OpponentException.INVALID_CONVERSAIION_KEY);
    			}
    			
    			conversationKey = chat.conversationKey; 
    			
    			
    		}
    		else
    		{	
    			for (int i =0; i < chat.recipients.size(); i++){        			
        			if (!userRepo.userExists(chat.recipients.get(i))){
        				throw new UserException(UserException.INVALID_USER_NAME+" ("+chat.recipients.get(i)+")");
        			}
        		}
    			
    			chat.recipients.add(0, username);
    			conversationKey = messageRepo.addConversation(chat.recipients);
    			
    		}
    		
    		messageRepo.sendChatMessage(username, conversationKey, chat.message, authManager.getApplicationId());
    		
    		if (sendAsSystemMessage){
    			JMSQueueManager queueManager = new JMSQueueManager();
    			
    			
    			String iconKey = userRepo.getUser(username).icon.iconKey;
    			String subject = "Chat message received from "+username;
    			
    			if (!messageRepo.systemMessageExists(conversationKey)){
    				messageRepo.addSystemMessage(conversationKey, iconKey, subject, chat.message, MessageType.CHAT);
    			}
    			else{
    				messageRepo.updateSystemMessage(conversationKey, iconKey, subject, chat.message, MessageType.CHAT);
    				messageRepo.removeMessageFromUser(conversationKey, username);
    			}
    			
    			
    			List<User> users = messageRepo.getConversationUsers(conversationKey);
    			
    			for (User user : users){
    				if (!user.username.equalsIgnoreCase(username)){
    					messageRepo.addMessageToUser(conversationKey, user.username);
    					queueManager.queueItem(QueueJDNI.PUSH_NOTIFICATION, new PushNotification(user.username, subject, PushNotification.MESSAGE_PARAMS, authManager.getApplicationId()));
    				}
    			}
    			
    			queueManager.sendQueuedItems();	
    		}
    		
    		dbManager.commit();
    		
    		
    	}
    	catch (RuntimeException e){
    		dbManager.rollback();
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
	    
	    return Response.status(200).build();
    }
    
    @POST
    @Path("/markConversationRead")
    @Consumes("text/xml")
    public Response markConversationRead(@Context HttpHeaders headers, String conversationKey)
    {
    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		
    		MessageRepository messageRepo = new MessageRepository(dbManager);
    		
    		if (!messageRepo.validateConversationKey(conversationKey)){
				throw new OpponentException(OpponentException.INVALID_CONVERSAIION_KEY);
			}
    		
    		messageRepo.updateLastRead(authManager.getUsername(), conversationKey);
    		
    		messageRepo.removeMessageFromUser(conversationKey, authManager.getUsername());
    		
    		dbManager.commit();
    	}
    	catch (RuntimeException e){
    		dbManager.rollback();
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
	    
	    return Response.status(200).build();
    }
}
