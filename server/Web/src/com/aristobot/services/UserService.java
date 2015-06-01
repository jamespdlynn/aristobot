package com.aristobot.services;

import java.util.ArrayList;
import java.util.List;

import javax.ws.rs.Consumes;
import javax.ws.rs.DefaultValue;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.QueryParam;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.Response;

import com.aristobot.data.ApplicationUser;
import com.aristobot.data.AuthenticationData;
import com.aristobot.data.SystemMessage;
import com.aristobot.data.User;
import com.aristobot.data.UserCredentials;
import com.aristobot.data.wrappers.MessagesWrapper;
import com.aristobot.data.wrappers.UsersWrapper;
import com.aristobot.exceptions.UserException;
import com.aristobot.managers.AuthenticationManager;
import com.aristobot.managers.JDBCManager;
import com.aristobot.managers.JMSQueueManager;
import com.aristobot.managers.LogManager;
import com.aristobot.managers.MailManager;
import com.aristobot.repository.AuthenticationRepositiory;
import com.aristobot.repository.IconRepository;
import com.aristobot.repository.MessageRepository;
import com.aristobot.repository.UserRepository;
import com.aristobot.utils.Utility;

/**
 * Service Class used for making service calls related to adding or retrieving User data
 * 
 * @author James
 *
 */
@Path("/user")
public class UserService
{
	private JDBCManager dbManager;
	private AuthenticationManager authManager;

	public UserService()
	{
		try{
			dbManager = new JDBCManager();
			authManager = new AuthenticationManager(dbManager);
		}
		catch (RuntimeException e){
			dbManager.close();
			throw LogManager.handleException(e);
		}
	}
    /**
     * 
     * @return Application User data for the user making this request call
     */
    @GET
	@Produces("application/xml")
    public ApplicationUser getCurrentUser(@Context HttpHeaders headers, @DefaultValue("true") @QueryParam("includeIcons") Boolean includeIcons, @DefaultValue("true") @QueryParam("includeMessages") Boolean includeMessages)
    {
    	
    	
    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		
    		UserRepository repo = new UserRepository(dbManager);
    		
    		ApplicationUser user = repo.getAuthenticatedUser(authManager.getUsername(), authManager.getApplicationId());

    		if (includeMessages)
    		{
    			MessageRepository messageRepo = new MessageRepository(dbManager);    			
    			AuthenticationData authData = authManager.getAuthData();
    			List<SystemMessage> messages = messageRepo.getSystemMessages(authData.username, authData.applicationId);
    			
    			MessagesWrapper wrapper = Utility.createMessagesWrapper(messages, authData);
    			
    			user.messages = wrapper.messages;
    			user.hasUnreadMessages = wrapper.hasUnreadMessages;
    			user.hasUnreadPriorityMessages = wrapper.hasUnreadPriorityMessages;
    		}
    		
    		if (includeIcons)
    		{
    			IconRepository iconRepo = new IconRepository(dbManager);
    			user.icons = iconRepo.getUserIcons(authManager.getUsername());
    		}
	    	
    		return user;
    	}
    	catch (RuntimeException e){
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
    }
    

    /**
     * Updates a user data for the current user.
     * @param creds UserCredentials object containing necessary User Data
     * @return
     */
    @POST
    @Path("/update")
    @Consumes("application/xml")
	@Produces("application/xml")
	public Response updateUser(@Context HttpHeaders headers, UserCredentials creds)
	{
    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		authManager.requireFullWriteAccess(); 
    		
    		String username = authManager.getUsername();
        	
        	UserRepository userRepo = new UserRepository(dbManager);
        	
    		//Validate the given credentials are in correct format
    		if (Utility.hasLengthOfAtleast(creds.iconKey,1))
    		{
    			
    			IconRepository iconRepo = new IconRepository(dbManager);
    			
    	   	    //Validate the icon key exists in the database
    			if (!iconRepo.iconExists(creds.iconKey)){
    				throw new UserException(UserException.INVALID_ICON_ID);
    			}
    			
    			userRepo.updateUserIcon(username, creds.iconKey);
    	    }
    		
    	    if (Utility.hasLengthOfAtleast(creds.emailAddress, 1))
    	    {
    	    	    	   	   //Validate the email  is in valid format
    			if (!Utility.isValidEmailAddress(creds.emailAddress)) {
    		        throw new UserException(UserException.INVALID_EMAIL_ADDRESS);
    			} 
    			
    			userRepo.updateUserEmailAddress(authManager.getUsername(), creds.emailAddress);
    		}
    	    
    	    if (Utility.hasLengthOfAtleast(creds.password, 1))
    	    {
    	    	
    	   		
    	   		if (!Utility.isValidPassword(creds.password)){
    	   			throw new UserException(UserException.INVALID_PASSWORD);
    	   		}
    	   		
    	   		AuthenticationRepositiory authRepo = new AuthenticationRepositiory(dbManager);
    	   		
    	   		authRepo.updatePassword(username, creds.password);
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
    
    @GET
    @Path("/leaderboard")
	@Produces("application/xml")
    public UsersWrapper getLeaderboard(@Context HttpHeaders headers)
    {
    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		
    		UserRepository repo = new UserRepository(dbManager);
    		
    		UsersWrapper wrapper = new UsersWrapper();
    		wrapper.users = repo.getUsersByRank(authManager.getApplicationId());
    		
    		return wrapper;

    	}
    	catch (RuntimeException e){
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
	    
	    
    } 
    

    @GET
    @Path("/find")
    @Consumes("text/xml")
	@Produces("application/xml")
    public User findUser(@Context HttpHeaders headers, @QueryParam("email") String email, @QueryParam("username")  String username){
    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		
    		UserRepository repo = new UserRepository(dbManager);
    		
    		User user = null;
    		if (email != null){
    			user = repo.getUserByEmail(email);
    			
    			if (user == null){
        			throw new UserException(UserException.INVALID_EMAIL_ADDRESS);
        		}
    		}
    		else if (username != null){
    			user = repo.getUser(username);
    			
    			if (user == null){
    				throw new UserException(UserException.INVALID_USER_NAME);
    			}
    			
    		}
    		else{
    			throw new UserException(UserException.NO_KEYWORD_SUPPLIED);
    		}
    	
    		return user;
    	
    	}
    	catch (RuntimeException e){
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
    }
    
    
    @GET
    @Path("/search")
    @Consumes("text/xml")
	@Produces("application/xml")
    public UsersWrapper searchForUsers(@Context HttpHeaders headers, @QueryParam("keyword") String keyword, @QueryParam("email") String email )
    {
    	try{
    		dbManager.connect();
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		
    		UsersWrapper wrapper = new UsersWrapper();
    		UserRepository repo = new UserRepository(dbManager);
    		
    		if (keyword != null){
        		wrapper.keyword = keyword;
        		wrapper.users = repo.searchForUsers("^"+keyword, authManager.getApplicationId(), authManager.getUsername());
    		}
    		else if (email != null){ 
    			wrapper.keyword = email;
    			wrapper.users = new ArrayList<ApplicationUser>();
    			ApplicationUser user = repo.searchForUser(authManager.getApplicationId(), email);
    			if (user != null){
    				wrapper.users.add(user);
    			}
    		}
    		else{
    			throw new UserException(UserException.NO_KEYWORD_SUPPLIED);
    		}
    		
    		return wrapper;
    		
    	}
    	catch (RuntimeException e){
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
	    
	    
    } 
    
    @POST
    @Path("/invite")
    @Consumes("text/xml")
	@Produces("application/xml")
    public Response inviteToPlay(@Context HttpHeaders headers, String emailAddressList)
    {
    	try{
    		dbManager.connect();
    		
    		String [] emailAddresses = emailAddressList.split(",");
    		
    		if (emailAddresses.length == 0){
    			throw new UserException(UserException.NO_KEYWORD_SUPPLIED);
    		}
    		
    		authManager.setHeaders(headers.getRequestHeaders());
    		authManager.requireFullAuthentication();
    		
    		UserRepository repo = new UserRepository(dbManager);
    		User currentUser = repo.getUserExtended(authManager.getUsername());
    		AuthenticationData authData = authManager.getAuthData();
    		
    		JMSQueueManager queueManager = new JMSQueueManager();
    		MailManager mailManager = new MailManager(dbManager, queueManager);
    		
    		for (String emailAddress : emailAddresses){
    			
    			if (!Utility.isValidEmailAddress(emailAddress)) {
        			throw new UserException(UserException.INVALID_EMAIL_ADDRESS);
        		}
    			        		
        		mailManager.queueInvitationEmail(currentUser, emailAddress, authData.applicationId, authData.applicationName);
    		}
    		
    		queueManager.sendQueuedItems();
    		
    		return Response.status(200).build();
    	}
    	catch (RuntimeException e){
    		throw LogManager.handleException(e);
 		}
	    finally{
	    	dbManager.close();
	    }
	    
	    
    } 
    
    


}
