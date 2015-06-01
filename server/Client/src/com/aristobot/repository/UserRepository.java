package com.aristobot.repository;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import com.aristobot.data.ApplicationUser;
import com.aristobot.data.Opponent;
import com.aristobot.data.Player;
import com.aristobot.data.User;
import com.aristobot.data.UserCredentials;
import com.aristobot.exceptions.DatabaseException;
import com.aristobot.managers.JDBCManager;
import com.aristobot.utils.Constants;
import com.aristobot.utils.Utility;
import com.aristobot.utils.Constants.PlayerStatus;

/**
 * Helper class used to retrieve and write data objects associated with Users to the database
 * @author James
 *
 */
public class UserRepository 
{
	/**
	 * 
	 * @param username
	 * @return user object if one exists associated with username, null otherwise
	 */
	
	private JDBCManager dbManager;
	MessageRepository messageRepo;
	
	public UserRepository(JDBCManager manager)
	{
		dbManager = manager;
		 messageRepo = new MessageRepository(manager);
	}
	
	public List<User> getAllUsers()
	{
		List<User> users = new ArrayList<User>();
		String userSelect = "SELECT username, iconKey FROM users";
    	PreparedStatement pstmt = dbManager.getPreparedStatement(userSelect);

		try 
		{
            ResultSet rs = pstmt.executeQuery();
            
            
            while (rs.next()) {
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
	
	
	public User getUser(String username)
	{
		User user;
    	
		String userSelect = "SELECT username, iconKey FROM users WHERE LOWER(username) =LOWER(?)";
    	PreparedStatement pstmt = dbManager.getPreparedStatement(userSelect);

		try 
        {
            pstmt.setString(1, username);

            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
            	return User.generate(rs, true);
            } 
            else {
               user = null;
            }
        } 
		catch (SQLException e) {
  			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
  		}
  		finally {
  			dbManager.closeStatement(pstmt);
  		}
  		
  		return user;
	}
	
	/**
    * 
    * @param emailAddress
    * @return User object is email address given is associated to a valid user, null otherwise
    */
   public User getUserByEmail(String emailAddress) 
   {		   
	   String userSelect = "SELECT username, iconKey FROM users WHERE LOWER(emailAddress) = LOWER(?)";
   		PreparedStatement pstmt = dbManager.getPreparedStatement(userSelect);
   	
	   try 
       {
            pstmt.setString(1, emailAddress);

            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next())  {
            	return User.generate(rs, true);
            } 
            
            return null;
        } 
	    catch (SQLException e) {
 			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
 		}
 		finally {
 			dbManager.closeStatement(pstmt);
 		}
 		
    }
   
   public User getUserExtended(String username)
	{	    	
		String userSelect = "SELECT username, iconKey, emailAddress, level, unlockPercent, isDebug, registrationDate, NOW() as currentDate FROM users WHERE LOWER(username) =LOWER(?)";
    	PreparedStatement pstmt = dbManager.getPreparedStatement(userSelect);

		try 
        {
            pstmt.setString(1, username);

            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
               return User.generate(rs, false);
            } 
            
            return null;
        } 
		catch (SQLException e) {
  			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
  		}
  		finally {
  			dbManager.closeStatement(pstmt);
  		}
	}
   
   
    /**
     * 
     * @param username
     * @return true is username exists in database, false otherwise
     */
    public Boolean userExists(String username)
    {
	 Boolean userExists;
	 
	 String selectUser = "SELECT username FROM users WHERE LOWER(username) = LOWER(?)";
	 	
     PreparedStatement pstmt = dbManager.getPreparedStatement(selectUser);

	 try {
         pstmt.setString(1, username);
         ResultSet rs = pstmt.executeQuery();
         userExists = rs.next();
     }
	 catch (SQLException e) {
		throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
	 }
	 finally {
		dbManager.closeStatement(pstmt);
	 }
	
	return userExists;
    }
	   
	  	
	
	public List<ApplicationUser> getAllAppicationsUsers(int applicationID, int minDaysRegistered)
	{
		
    	
		String userSelect = "SELECT users.username, iconKey, wins, losses, ties, rating, rank FROM users " +
							"INNER JOIN applications_users ON users.username = applications_users.username " +
							"WHERE applications_users.applicationId = ? AND TIMESTAMPDIFF(DAY, applications_users.createdDate, NOW()) >= ?";
		
		PreparedStatement pstmt = dbManager.getPreparedStatement(userSelect);

		try 
        {
            pstmt.setInt(1, applicationID);
            pstmt.setInt(2, minDaysRegistered);

            ResultSet rs = pstmt.executeQuery();
            
            List<ApplicationUser> users = new ArrayList<ApplicationUser>();
            
            while (rs.next()) {
                users.add( ApplicationUser.generate(rs, true));
            } 
            
        	return users;
        } 
		catch (SQLException e) {
  			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, userSelect, e);
  		}
  		finally {
  			dbManager.closeStatement(pstmt);
  		}
  		
  	
	}
	
	public List<ApplicationUser> getAllAppicationsUsers(int applicationID){
		return getAllAppicationsUsers(applicationID, 0);
	}
	
	
	/**
	 * 
	 * @param username
	 * @param applicationId
	 * @return Application User object if one exists associated with both username and applicaiton id, null otherwise
	 */
	public ApplicationUser getApplicationUser(String username, int applicationId) {
    			
		String userSelect = "SELECT users.username, iconKey, wins, losses, ties, rating, rank FROM users " +
							"INNER JOIN applications_users ON users.username = applications_users.username " +
							"WHERE LOWER(users.username) =LOWER(?) AND applications_users.applicationId = ?";

		PreparedStatement pstmt = dbManager.getPreparedStatement(userSelect);
		
    	try 
        {
            pstmt.setString(1, username);
            pstmt.setInt(2, applicationId);

            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                return  ApplicationUser.generate(rs, true);
            }
            return null;
        } 
    	catch (SQLException e) {
  			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
  		}
  		finally {
  			dbManager.closeStatement(pstmt);
  		}
  		
    }
	
   public int getUserRating(String username, int applicationId) 
   {
	   int rating = -1;
	   
	   String ratingSelect = "SELECT rating FROM applications_users WHERE username = ? AND applicationId = ?";
   		PreparedStatement pstmt = dbManager.getPreparedStatement(ratingSelect);
   	
	   try 
       {
            pstmt.setString(1, username);
            pstmt.setInt(2, applicationId);

            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
               rating = rs.getInt("rating");
            } 
        } 
	    catch (SQLException e) {
 			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
 		}
 		finally {
 			dbManager.closeStatement(pstmt);
 		}
 		
 		return rating;
    }
   
   public void updateUserRating(String username, int applicationId, int rating) 
   {	   
	   String ratingUpdate = "UPDATE applications_users SET rating = ? WHERE username = ? AND applicationId = ?";
   		PreparedStatement pstmt = dbManager.getPreparedStatement(ratingUpdate);
   	
	   try 
       {
		    pstmt.setInt(1, rating);
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

  
  
    /**
     * @param username
     * @param applicationId
     * @return Application User if user associated with the given application exists, null otherwise
     * @throws DatabaseException
     */
    public ApplicationUser getAuthenticatedUser(String username, int applicationId) throws DatabaseException 
    {
    	
    	//Long query, basically we have to only return the user which is attached to the application id given
		//and whose access token has not expired
    	String userSelect = "SELECT users.username, emailAddress, iconKey, wins, losses, ties, level, unlockPercent, rank, rating, isDebug, registrationDate, NOW() as currentDate FROM users " +
    			"INNER JOIN applications_users ON users.username = applications_users.username " +
    			"WHERE users.username = ? && applications_users.applicationId = ?";
    	
    	PreparedStatement pstmt = dbManager.getPreparedStatement(userSelect);
    	
    	try 
        {
            pstmt.setString(1, username);
            pstmt.setInt(2, applicationId);

            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
            	return ApplicationUser.generate(rs, false);
            } 
            
            return null;
        
        } 
    	catch (SQLException e) {
 			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
 		}
 		finally {
 			dbManager.closeStatement(pstmt);
 		}
 		
    }
    
    
    public Boolean applicationUserExists(String username, int applicationId)
    {
    	 
    	 String selectUser = "SELECT username FROM applications_users WHERE LOWER(username) = LOWER(?) AND applicationId = ?";
    	 	
	     PreparedStatement pstmt = dbManager.getPreparedStatement(selectUser);

    	 try {
             pstmt.setString(1, username);
             pstmt.setInt(2, applicationId);
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
    
    public ApplicationUser searchForUser(int applicationId, String emailAddress){
   	 
	   	 String applicationUserSelect = "SELECT applications_users.username, iconKey, wins, losses, ties, rating, rank FROM users " +
								"INNER JOIN applications_users ON users.username = applications_users.username " +
								"WHERE applicationid = ? AND LOWER(emailAddress) = LOWER(?) AND isDebug = 0 " +
								"LIMIT 1";
	   	 
	
	   	 PreparedStatement pstmt = dbManager.getPreparedStatement(applicationUserSelect);
	   	 
	   	
	   	 try {    		  
	   		
	   		 pstmt.setInt(1, applicationId);
	   		 pstmt.setString(2, emailAddress);
		         
	   		 ResultSet rs = pstmt.executeQuery();
	   		 if (rs.next()){
	   			 return ApplicationUser.generate(rs, true);
	   		 }else{
	   			 User user = getUserByEmail(emailAddress);
	   			 if (user != null){
	   				 return ApplicationUser.generate(user);
	   			 }
	   		 }
	   		 
	   		 return null;
	   		 
	   	 }
	   	 catch (SQLException e) {
	  		throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
	  	 }
  		 finally {
  			dbManager.closeStatement(pstmt);
  		 }
    }
    
    public List<ApplicationUser> searchForUsers(String regExp, int applicationId, String username){
    	
    	 List<ApplicationUser> users = new ArrayList<>();    	
    	 int limit = Constants.MAX_SEARCH_RESULTS;
    	 
    	 String applicationUserSelect = "SELECT applications_users.username, iconKey, wins, losses, ties, rating, rank FROM users " +
							"INNER JOIN applications_users ON users.username = applications_users.username " +
							"WHERE applicationid = ? AND applications_users.username REGEXP ? AND users.isDebug = 0 " +
							"AND LOWER(applications_users.username) != LOWER(?) " +
							"ORDER BY users.username ASC LIMIT ?";
    	 

    	 PreparedStatement pstmt = dbManager.getPreparedStatement(applicationUserSelect);
    	 
    	
    	 try {    		  
    		
    		 pstmt.setInt(1, applicationId);
    		 pstmt.setString(2, regExp);
    		 pstmt.setString(3, username);
	         pstmt.setInt(4, limit);
	         
    		 ResultSet rs = pstmt.executeQuery();
    		 while (rs.next()){
    			 ApplicationUser user = ApplicationUser.generate(rs, true);
    			 users.add(user);
    		 }
    	 }
    	 catch (SQLException e) {
   			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
   		 }
   		 finally {
   			dbManager.closeStatement(pstmt);
   		 }
    		 
		 if (users.size() < limit){
			 
			 limit -= users.size();
	    	 String listQueryParam = Utility.buildListQueryParam(users.size()+1);
			 
			 String userSelect = "SELECT users.username, iconKey FROM users " +
					 "WHERE users.username REGEXP ? AND users.username NOT IN "+listQueryParam + " "+
					 "ORDER BY users.username ASC LIMIT ?";
			 
			 PreparedStatement pstmt2 = dbManager.getPreparedStatement(userSelect);
			 
			 try{
				 pstmt2.setString(1, regExp);
				 pstmt2.setString(2, username);
				 for (int i=0; i < users.size(); i++){
	    			 pstmt2.setString(i+3, users.get(i).username);
	    		 }
		         pstmt2.setInt(users.size()+3, limit);
		         
		         ResultSet rs2 = pstmt2.executeQuery();
		         while (rs2.next()){
		        	 ApplicationUser user = ApplicationUser.generate(User.generate(rs2, true));
	    			 users.add(user);
	    		 }
			 }
			 catch (SQLException e) {
					throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
			 }
			 finally {
				dbManager.closeStatement(pstmt2);
			 }
		 }
		 
		 return users;
     }

  
   
    

    /**
     * Adds a user to the user table in the database
     * @param creds object containing user information
     * @throws DatabaseException
     */
    public void addUser(UserCredentials creds) throws DatabaseException 
    {
    	//Insert User into User Table
        String usersInsert = "INSERT INTO users (username, password, emailAddress, iconKey)" +
                " VALUES(?,PASSWORD(?),?,?)";

        PreparedStatement pstmt = dbManager.getPreparedStatement(usersInsert);
    	
    	try {
	    	
            pstmt.setString(1, creds.username); 
            pstmt.setString(2, creds.password);
            pstmt.setString(3, creds.emailAddress);
            pstmt.setString(4, creds.iconKey);

            pstmt.executeUpdate();
                        
        } 
    	catch (SQLException e) {
  			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
  		}
  		finally {
  			dbManager.closeStatement(pstmt);
  		}

    }
    
   
    public void updateUserEmailAddress(String username, String emailAddress) throws DatabaseException 
    {
    	String userUpdate = "Update users SET emailAddress = ? " +
		"WHERE username = ?";

    	PreparedStatement pstmt = dbManager.getPreparedStatement(userUpdate);

    	try 
    	{
            pstmt.setString(1, emailAddress);
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
    
    /**
     * Updates the icon currently associated with a given user
     * 
     * @param username
     * @param applicationId
     * @param iconKey
     * @throws DatabaseException
     */
    public void updateUserIcon(String username, String iconKey) throws DatabaseException 
    {
    	String userUpdate = "Update users SET iconKey = ? " +
		"WHERE username = ?";

    	PreparedStatement pstmt = dbManager.getPreparedStatement(userUpdate);

    	try 
    	{
            pstmt.setString(1, iconKey);
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
    
  
    
    /**
     * Deletes a given access token from the database
     * @param accessToken
     */
    public void deleteUser(String username) 
    {
    	String userDelete = "DELETE FROM Users WHERE username = ?";
    	PreparedStatement pstmt = dbManager.getPreparedStatement(userDelete);
    	
    	try{
    		pstmt.setString(1, username);
		    pstmt.executeUpdate();
				
		} 
    	catch (SQLException e) {
    		throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
    	}
    	finally {
    		dbManager.closeStatement(pstmt);
    	}
    }
    
   
    
    public static final int DEFAULT_RATING_DIFFERENCE = 25;
    
	 /**
	  * Finds a valid random opponent for a user. 
	  * @param username
	  * @param applicationId
	  * @return User object containing random opponent data if one is available, null othewise
	  */
    public User matchRandomUser(String username, int applicationId){
    	int userRating = getUserRating(username, applicationId);
    	
    	Set<String> invalidUsernames = getOpponentUsernames(username);
    	invalidUsernames.add(username);
    	
    	return matchRandomUser(username, applicationId, userRating, DEFAULT_RATING_DIFFERENCE, invalidUsernames);
    }
  
    
  
    private User matchRandomUser(String username, int applicationId, int userRating, int ratingDifference, Set<String> invalidUsernames)
    {	     	    	
    	String listQueryParam = Utility.buildListQueryParam(invalidUsernames.size());
    	
    	//Query ensures that random opponent is a member of the same client application as the user is using and that 
    	//they are not already stored as a saved opponent of the user
    	String selectOpponents = 
    				"SELECT DISTINCT users.username, users.iconKey FROM users " +
					"INNER JOIN applications_users ON users.username = applications_users.username " +
					"INNER JOIN (" +
									"SELECT username, applicationId, createdDate as lastPlayedDate "  +
									"FROM authenticatedusers WHERE username = username ORDER BY createdDate DESC" +
								") as currentusers ON applications_users.username = currentusers.username " +
					"WHERE currentusers.applicationId = ? AND users.isDebug = 0 " +
					"AND applications_users.rating BETWEEN ? AND ? AND users.username NOT IN "+listQueryParam + " "+
					"ORDER BY currentusers.lastPlayedDate DESC LIMIT 5";
    	
    	PreparedStatement pstmt = dbManager.getPreparedStatement(selectOpponents);
    	
    	try
    	{
    		
    		pstmt.setInt(1, applicationId);
    		pstmt.setInt(2, userRating-(ratingDifference));
    		pstmt.setInt(3, userRating+(ratingDifference));
    		
    		int i = 4;
    		for (String invalidUsername : invalidUsernames ){
    			pstmt.setString(i, invalidUsername);
    			i++;
    		}
    		
    		ResultSet rs = pstmt.executeQuery();
    		GameRepository gameRepo = new GameRepository(dbManager);
    		
    		while (rs.next()){
    			
				User randomUser = User.generate(rs, true);
				
				if (gameRepo.getNumActiveGames(randomUser.username, applicationId) < 4){
					return randomUser;
				}
				
				invalidUsernames.add(randomUser.username);
			}
    		
    		if (ratingDifference < 200){
    			return matchRandomUser(username, applicationId, userRating, ratingDifference+DEFAULT_RATING_DIFFERENCE, invalidUsernames);
    		}
    		
    		return null;


		} 
    	catch (SQLException e) {
    		throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
    	}
    	finally {
    		dbManager.closeStatement(pstmt);
    	}
    	
    	
    }
    
   
    
    public Opponent getOpponent(String username, String opponentUsername, int applicationId, Boolean includeAllData)
    {
    	Opponent opponent = null;
    	
    	String selectOpponent = "SELECT * FROM(" +
		
		"				 SELECT opposition.oppositionId, applicationId, username2 as opponentUsername, user1wins as winsAgainst, user2wins as lossesAgainst, ties as tiesAgainst, activeGames, lastPlayedDate, NOW() as currentDate  "+
						 "FROM opposition "+ 
						 "LEFT OUTER JOIN applications_opposition ON opposition.oppositionId = applications_opposition.oppositionId " +
						 "WHERE LOWER(username1)=LOWER(?) AND LOWER(username2)=LOWER(?) "+
							
						 "UNION ALL " +
							
						 "SELECT opposition.oppositionId, applicationId, username1 as opponentUsername, user2wins as winsAgainst, user1wins as lossesAgainst, ties as tiesAgainst, activeGames, lastPlayedDate, NOW() as currentDate   " +
						 "FROM opposition " +
						 "LEFT OUTER JOIN applications_opposition ON opposition.oppositionId = applications_opposition.oppositionId " +
						 "WHERE LOWER(username2)=LOWER(?) AND LOWER(username1)=LOWER(?) " +
					  ") as opponents " +
					  
					  "WHERE (applicationId = ?  OR applicationId  IS NULL) " +
					  "ORDER BY lastPlayedDate DESC";
    	
    	PreparedStatement pstmt = dbManager.getPreparedStatement(selectOpponent);
    	
    	try
    	{	
    		
			pstmt.setString(1, username);
			pstmt.setString(2, opponentUsername);
			pstmt.setString(3, username);
			pstmt.setString(4, opponentUsername);
			pstmt.setInt(5, applicationId);
			
			ResultSet rs = pstmt.executeQuery();
						
			if (rs.next()){
				opponent = (includeAllData) ? generateApplicationOpponentData(rs, applicationId) : generateApplicationOpponentData(rs);
			}

		} 
    	catch (SQLException e) {
    		throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
    	}
    	finally {
    		dbManager.closeStatement(pstmt);
    	}
		
		return opponent;
    }
    
    /**
     * @param username
     * @param applicationId
     * @return list of all opponents attached to the given user
     */
    public Set<String> getOpponentUsernames(String username)
    {
    	
    	
    	String selectopponents = "SELECT * FROM(" +
    			
	    							"SELECT username2 as opponentUsername "+
									 "FROM opposition "+ 
									 "WHERE LOWER(username1)=LOWER(?) AND user1Validated = 1 " +
										
									 "UNION ALL " +
										
									 "SELECT username1 as opponentUsername  " +
									 "FROM opposition " +
									 "WHERE LOWER(username2)=LOWER(?) AND user2Validated = 1" +
									 
								  ") as opponents";
								  
    	
    	PreparedStatement pstmt = dbManager.getPreparedStatement(selectopponents);
    	
    	try
    	{
			pstmt.setString(1, username);
			pstmt.setString(2, username);
			
			ResultSet rs = pstmt.executeQuery();
			
			Set<String> opponentUsernames = new HashSet<String>();
			
			while (rs.next()){
				opponentUsernames.add(rs.getString("opponentUsername"));
			}
			
			return opponentUsernames;

		} 
    	catch (SQLException e) {
    		throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
    	}
    	finally {
    		dbManager.closeStatement(pstmt);
    	}
    	
    	
    }
    
    /**
     * @param username
     * @param applicationId
     * @return list of all opponents attached to the given user
     */
    public List<Opponent> getAllOpponents(String username, int applicationId)
    {
    	List<Opponent> opponents;
    	
    	String selectopponents = "SELECT * FROM(" +
    			
	    			"				 SELECT opposition.oppositionId, applicationId, username2 as opponentUsername, user1wins as winsAgainst, user2wins as lossesAgainst, ties as tiesAgainst, activeGames, lastPlayedDate, NOW() as currentDate "+
									 "FROM opposition "+ 
									 "LEFT OUTER JOIN applications_opposition ON opposition.oppositionId = applications_opposition.oppositionId " +
									 "WHERE LOWER(username1)=LOWER(?) AND user1Validated = 1 " +
										
									 "UNION ALL " +
										
									 "SELECT opposition.oppositionId, applicationId, username1 as opponentUsername, user2wins as winsAgainst, user1wins as lossesAgainst, ties as tiesAgainst, activeGames, lastPlayedDate, NOW() as currentDate  " +
									 "FROM opposition " +
									 "LEFT OUTER JOIN applications_opposition ON opposition.oppositionId = applications_opposition.oppositionId " +
									 "WHERE LOWER(username2)=LOWER(?) AND user2Validated = 1" +
									 
								  ") as opponents " +
								  
								  "WHERE (applicationId = ?  OR applicationId  IS NULL) " +
								  "ORDER BY lastPlayedDate DESC LIMIT ?";
    	
    	PreparedStatement pstmt = dbManager.getPreparedStatement(selectopponents);
    	
    	try
    	{
    		
			pstmt.setString(1, username);
			pstmt.setString(2, username);
			pstmt.setInt(3, applicationId);
			pstmt.setInt(4, Constants.MAX_SEARCH_RESULTS);
			
			ResultSet rs = pstmt.executeQuery();
			
			opponents = new ArrayList<Opponent>();
			
			while (rs.next()){
				opponents.add(generateApplicationOpponentData(rs, applicationId));
			}

		} 
    	catch (SQLException e) {
    		throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
    	}
    	finally {
    		dbManager.closeStatement(pstmt);
    	}
    	
    	return opponents;
    	
    }
    
    private Opponent generateApplicationOpponentData(ResultSet rs) throws SQLException
    {
    	return generateApplicationOpponentData(rs, -1);
    }
    
    private Opponent generateApplicationOpponentData(ResultSet rs, int applicationId) throws SQLException
    {
    	String opponentUsername = rs.getString("opponentUsername");    	
    	Boolean hasApplication = false;
    	
    	User opponentInfo = null;
    	
    	if (applicationId > 0){
    		opponentInfo = getApplicationUser(opponentUsername, applicationId);
    		hasApplication = (opponentInfo != null);
    	}
    	
    	if (!hasApplication){
    		opponentInfo = getUser(opponentUsername);
    	}
    	
		Opponent opponent = new Opponent();
		opponent.username = opponentInfo.username;
		opponent.icon = opponentInfo.icon;
		opponent.hasApplication = hasApplication;
		
		if (opponent.hasApplication)
		{			
			
			
			opponent.applicationWins = ((ApplicationUser)opponentInfo).wins;
			opponent.applicationTies = ((ApplicationUser)opponentInfo).ties;
			opponent.applicationLosses = ((ApplicationUser)opponentInfo).losses;
			opponent.winsAgainst = rs.getInt("winsAgainst");
			opponent.lossesAgainst = rs.getInt("lossesAgainst");
			opponent.tiesAgainst = rs.getInt("tiesAgainst");
			opponent.numActiveGames = rs.getInt("activeGames");
			
			Timestamp ts = rs.getTimestamp("lastPlayedDate");
					
			if (ts != null){
				long currentDate = rs.getTimestamp("currentDate").getTime();
				opponent.lastPlayedAgainstDate= Utility.generateRoboDate(ts.getTime(), currentDate);
			}
		}
		return opponent;


    }

  
    public int addOpponent(String username, String opponentUsername)
    {
    	return addOpponent(username, opponentUsername, true);
    }
    
    public int addOpponent(String username, String opponentUsername, Boolean validate)
    {    	
    	String selectOppositon = "SELECT oppositionId, 1 as isUser1, user1Validated as validated FROM opposition " +
								  "WHERE (LOWER(username1) = LOWER(?) AND LOWER(username2) = LOWER(?)) " +
								  "UNION ALL " +
								  "SELECT oppositionId, 0 as isUser1, user2Validated as validated FROM opposition " +
								  "WHERE (LOWER(username2) = LOWER(?) AND LOWER(username1) = LOWER(?)) ";
    	
    	PreparedStatement pstmt = dbManager.getPreparedStatement(selectOppositon);
    	
    	try{
		    pstmt.setString(1, username);
		    pstmt.setString(2, opponentUsername);
		    pstmt.setString(3, username);
		    pstmt.setString(4, opponentUsername);
		    
		    ResultSet rs = pstmt.executeQuery();
		    
		    //If opposition doesn't yet exist insert it, else validate it if needed
		    if (!rs.next() ){
		    	return insertOpposition(username, opponentUsername, validate);
		    }
		    else{

			    int oppositionId = rs.getInt("oppositionId");
		    	if (validate && !rs.getBoolean("validated")){
		    		updateOpponentValidation(oppositionId, rs.getBoolean("isUser1"), true);
		    	}
		    	return oppositionId;
		    }
		    
		    
		} 
    	catch (SQLException e) {
    		throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
    	}
    	finally {
    		dbManager.closeStatement(pstmt);
    	}
    	
    }
    
    private int insertOpposition(String username, String opponentUsername, Boolean validate)
    {
    	String insertOpposition = "INSERT INTO opposition(username1, username2, user1Validated) VALUES (?, ?, ?)";
		PreparedStatement pstmt = dbManager.getPreparedStatement(insertOpposition);
		
    	try{
  
		    pstmt.setString(1, username);
		    pstmt.setString(2, opponentUsername);
		    pstmt.setBoolean(3, validate);
		    
		    pstmt.executeUpdate();
		    
		    ResultSet rs = pstmt.getGeneratedKeys();
		    rs.next();
		    return rs.getInt(1);
    
		} 
    	catch (SQLException e) {
    		throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
    	}
    	finally {
    		dbManager.closeStatement(pstmt);
    	}
    }
    
    
    public void removeOpponent(String username, String opponentUsername)
    {
	    	String selectOppositon = "SELECT oppositionId, 1 as isUser1, user1Validated as validated FROM opposition " +
			  "WHERE (LOWER(username1) = LOWER(?) AND LOWER(username2) = LOWER(?)) " +
			  "UNION ALL " +
			  "SELECT oppositionId, 0 as isUser1, user2Validated as validated FROM opposition " +
			  "WHERE (LOWER(username2) = LOWER(?) AND LOWER(username1) = LOWER(?)) ";
			
			PreparedStatement pstmt = dbManager.getPreparedStatement(selectOppositon);
			
			try{
				pstmt.setString(1, username);
				pstmt.setString(2, opponentUsername);
				pstmt.setString(3, username);
				pstmt.setString(4, opponentUsername);
				
				ResultSet rs = pstmt.executeQuery();
			
				//If  invalidate it if needed
				if (rs.next() ){
					updateOpponentValidation(rs.getInt("oppositionId"), rs.getBoolean("isUser1"), false);
				}
			}

			catch (SQLException e) {
				throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
			}
			finally {
				dbManager.closeStatement(pstmt);
			}
    }
    
    private void updateOpponentValidation(int oppositionId, Boolean isUser1, Boolean validated)
    {
    	
    	String updateOpposition= "UPDATE opposition SET " + ((isUser1) ? "user1Validated" : "user2Validated") + " = ? WHERE oppositionId = ?";
    	PreparedStatement pstmt = dbManager.getPreparedStatement(updateOpposition);
    	
    	try
    	{
    		pstmt.setBoolean(1, validated);
		    pstmt.setInt(2, oppositionId);
		   
		    pstmt.executeUpdate();
		} 
    	catch (SQLException e) {
    		throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
    	}
    	finally {
    		dbManager.closeStatement(pstmt);
    	}
    }
    
    /**
     * Add an row to the applications_opposition table in the database.
     * Only works if a general opposition has been created using the call above.
     * 
     * @param applicationId the unique identifier for the application
     * @param oppositionId the unique identifier for the opposition
     */
    public void addApplicationOppostion(int applicationId, int oppositionId)
    {

	    	String insertOppositionApplication = "INSERT IGNORE INTO applications_opposition(oppositionId, applicationId) VALUES (?, ?)";
		    PreparedStatement pstmt = dbManager.getPreparedStatement(insertOppositionApplication);
		    
		    try{
		    	pstmt.setInt(1, oppositionId);
		    	pstmt.setInt(2, applicationId);
		    	pstmt.executeUpdate();
		    }
		    catch (SQLException e) {
	    		throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
	    	}
	    	finally {
	    		dbManager.closeStatement(pstmt);
	    	}
		   
    }
    
    
    
    /**
     * Updates the lastPlayedData field in the applications_user table to the current date
     * 
     * @param applicationId
     * @param oppositionId
     */
    public void updateOppositionActiveGames(int applicationId, int oppositionId, int increment)
    {
    	String updateapplicationsOpposition = "UPDATE applications_opposition " +
    										  "SET activeGames = activeGames + ?, lastPlayedDate = now() " +
    										  "WHERE applicationID = ? AND oppositionId = ?";
    	
    	PreparedStatement pstmt = dbManager.getPreparedStatement(updateapplicationsOpposition);

    	try{	
    		pstmt.setInt(1, increment);
	    	pstmt.setInt(2, applicationId);
	    	pstmt.setInt(3, oppositionId);
	    	pstmt.executeUpdate();   
		} 
    	catch (SQLException e) {
    		throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
    	}
    	finally {
    		dbManager.closeStatement(pstmt);
    	}
    }
    
    
    public void updateUserExperience(String username, int level, float unlockPercent)
    {
    	String updateUser = "UPDATE users SET level = ?, unlockPercent = ? WHERE username = ?";
		PreparedStatement pstmt = dbManager.getPreparedStatement(updateUser);
		
    	try{
        	pstmt.setInt(1, level);
        	pstmt.setDouble(2, unlockPercent);
        	pstmt.setString(3, username);
        	
        	pstmt.executeUpdate();
    	}
    	catch (SQLException e) {
    		throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
    	}
    	finally {
    		dbManager.closeStatement(pstmt);
    	}
    }
    
    /**
     * Updates the records of given set of Users
     * @param players list of players for which their records should be updated
     * @param applicationId
     */
    public void updateUserRecords(List<Player> players, int applicationId)
    {

		//Loop through the player's list, determine if they won, lost or tied, and then update their record in the database accordingly
    	for (int i = 0; i < players.size(); i++)
    	{
    		
    		Player player = players.get(i);;
    		
    		int winValue = PlayerStatus.WON.equals(player.playerStatus) ? 1 : 0;
    		int lostValue = PlayerStatus.LOST.equals(player.playerStatus) ? 1 : 0;
    		int tiedValue = PlayerStatus.TIED.equals(player.playerStatus) ? 1 : 0;
    		
    		String updateUserRecord = "UPDATE applications_users SET wins = wins + ?, losses = losses + ?, ties = ties + ? " +
    		"WHERE username = ? AND applicationID = ?";
        	
        	PreparedStatement updateUserPstmt = dbManager.getPreparedStatement(updateUserRecord); 
        	
        	String selectOppositon = "Select oppositionId, username1, username2 FROM opposition " +
			"WHERE (LOWER(username1) = LOWER(?) AND LOWER(username2) = LOWER(?)) " +
			"OR (LOWER(username1) = LOWER(?) AND LOWER(username2) = LOWER(?))";
			
			PreparedStatement selectOppositionPstmt = dbManager.getPreparedStatement(selectOppositon);
        	
        	String updateOppositionRecord = "UPDATE applications_opposition SET user1Wins = user1Wins + ?, user2Wins = user2Wins  + ?, ties = ties + ? " +
			"WHERE oppositionId = ? AND applicationID = ?";
			
			PreparedStatement updateOppositionPstmt = dbManager.getPreparedStatement(updateOppositionRecord);
        	
        	try
        	{
        		//First update the user/player's overall record
        		updateUserPstmt.setInt(1, winValue);
        		updateUserPstmt.setInt(2, lostValue);
        		updateUserPstmt.setInt(3, tiedValue);
        		updateUserPstmt.setString(4, player.username);
        		updateUserPstmt.setInt(5, applicationId);
        		
        		updateUserPstmt.executeUpdate();
        		
        		//Next updated the user/player's application_user record between them and each other Player in the list
        		for (int j = i+1; j < players.size(); j++)
        		{
        			Player opposingPlayer = players.get(j);
        			
 
    				selectOppositionPstmt.setString(1, player.username);
	    			selectOppositionPstmt.setString(2, opposingPlayer.username);
	    			selectOppositionPstmt.setString(3, opposingPlayer.username);
	    			selectOppositionPstmt.setString(4, player.username);
	    			
	    			ResultSet rs = selectOppositionPstmt.executeQuery();
	    			
	    			if (rs.next())
	    			{
	    				int user1WinValue = 0;
	    				int user2WinValue = 0;
	    				int opponentsTieValue = 0;
	    				
	    				Boolean isUser1= (rs.getString("username1").compareToIgnoreCase(player.username) == 0);
	    				
	    				if (winValue > 0){
	    					user1WinValue = (isUser1) ? 1 : 0;
	    					user2WinValue = (isUser1) ? 0 : 1;
	    				}
	    				else if (lostValue > 0){
	    					user1WinValue = (isUser1) ? 0 : 1;
	    					user2WinValue = (isUser1) ? 1 : 0;
	    				}
	    				else if (tiedValue > 0)
	    				{
	    					if (PlayerStatus.TIED.equals(opposingPlayer.playerStatus)){
	    						opponentsTieValue = 1;
	    					}
	    					else{
	    						user1WinValue = (isUser1) ? 1 : 0;
		    					user2WinValue = (isUser1) ? 0 : 1;
	    					}
	    				}

    					updateOppositionPstmt.setInt(1, user1WinValue);
	    				updateOppositionPstmt.setInt(2, user2WinValue);
	    	    		updateOppositionPstmt.setInt(3, opponentsTieValue);
	    	    		updateOppositionPstmt.setInt(4, rs.getInt("oppositionId"));
	    	    		updateOppositionPstmt.setInt(5, applicationId);

	    				updateOppositionPstmt.executeUpdate();
	    				
	    			}
        		}
        	}
        	catch (SQLException e) {
        		throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
        	}
        	finally {
        		dbManager.closeStatement(updateUserPstmt);
        		dbManager.closeStatement(selectOppositionPstmt);
        		dbManager.closeStatement(updateOppositionPstmt);
        	}			
	    }
    }
    
    
    public List<ApplicationUser> getUsersByRank(int applicationId) 
    {	   
    	List<ApplicationUser> users = new ArrayList<ApplicationUser>();
    	
    	String userSelect = "SELECT users.username, iconKey, wins, losses, ties, rating, rank FROM applications_users " +
    						"INNER JOIN users ON applications_users.username = users.username " +
							"WHERE applicationId = ? AND NOT rank IS NULL "+
							"ORDER BY rank ASC " +
							"LIMIT ?";
				
		PreparedStatement pstmt = dbManager.getPreparedStatement(userSelect);
		
		try 
		{
		   pstmt.setInt(1, applicationId);
		   pstmt.setInt(2, Constants.NUM_RANKED_USERS);
		   ResultSet rs = pstmt.executeQuery();
		   
		   
		   while (rs.next()){
               users.add(ApplicationUser.generate(rs, true));
		   }
		} 
		catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt);
		}	
		
		return users;
     }
    
    public void resetUserRankings(int applicationId){
    	
    	String resetRank = "UPDATE applications_users SET rank = NULL WHERE applicationId = ?";
    	PreparedStatement pstmt = dbManager.getPreparedStatement(resetRank);

		try {
		   pstmt.setInt(1, applicationId);
		   pstmt.executeUpdate();
		   updateUserRankings(applicationId);
		} 
		catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt);
		}	
	
	
    }
    
    public void updateUserRankings(int applicationId) 
    {	   
    	String userSelect = "SELECT users.username, rating, rank FROM applications_users INNER JOIN users ON users.username = applications_users.username " +
							"WHERE applicationId = ? AND isDebug = 0 AND (wins+losses+ties) >= ? " +
							"ORDER BY rating DESC " +
							"LIMIT ?";
		
		String updateRank = "UPDATE applications_users SET rank = ? WHERE username = ? AND applicationId = ?";
		
		PreparedStatement pstmt1 = dbManager.getPreparedStatement(userSelect);
		PreparedStatement pstmt2 = dbManager.getPreparedStatement(updateRank);
		
		try 
		{
		   pstmt1.setInt(1, applicationId);
		   pstmt1.setInt(2, Constants.MIN_GAMES_PLAYED_FOR_RANK);
		   pstmt1.setInt(3, Constants.NUM_RANKED_USERS*2);
		   ResultSet rs = pstmt1.executeQuery();
		   
		   int currentRank = 1;
		   int lastRating = -1;
		   
		   while (rs.next())
		   {
			   String username = rs.getString("username");
			   int rating = rs.getInt("rating");
			   int rank = rs.getInt("rank");
			   
			   if (rating != lastRating){
				   currentRank = rs.getRow();
				   lastRating = rating;
			   }
			   
			   if (currentRank <= Constants.NUM_RANKED_USERS && currentRank != rank){
				   pstmt2.setInt(1, currentRank);
				   pstmt2.setString(2, username);
				   pstmt2.setInt(3, applicationId);
				   pstmt2.executeUpdate();
			   }
			   else if (currentRank > Constants.NUM_RANKED_USERS && rank > 0){
				   pstmt2.setNull(1, Types.INTEGER);
				   pstmt2.setString(2, username);
				   pstmt2.setInt(3, applicationId);
				   pstmt2.executeUpdate();
			   }
			   
		   }
		} 
		catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt1);
			dbManager.closeStatement(pstmt2);
		}	
     }
    
    


}

