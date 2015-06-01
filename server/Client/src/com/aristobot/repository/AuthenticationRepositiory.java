package com.aristobot.repository;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.aristobot.data.AuthenticationData;
import com.aristobot.data.DeviceData;
import com.aristobot.data.PushNotificationToken;
import com.aristobot.exceptions.DatabaseException;
import com.aristobot.managers.JDBCManager;
import com.aristobot.utils.Constants;
import com.aristobot.utils.Constants.DeviceType;
import com.aristobot.utils.Constants.WriteAccess;
import com.aristobot.utils.Utility;

public class AuthenticationRepositiory 
{
	private JDBCManager dbManager;
	
	public AuthenticationRepositiory(JDBCManager manager)
	{
		dbManager = manager;
	}
	
	
	public AuthenticationData getApplicationData(int applicationId)
    {
		AuthenticationData data = new AuthenticationData();
    	    	
    	String selectAPIKey = "SELECT applications.applicationId, applications.title, applications.currentVersion, applications.rankingEnabled " +
    						  "FROM applications WHERE applicationId = ?";

    	PreparedStatement pstmt = dbManager.getPreparedStatement(selectAPIKey); 
    	
    	try 
        {
        	pstmt.setInt(1, applicationId);
        	ResultSet rs = pstmt.executeQuery();
        	
            if (rs.next()){
            	data.isValid = true;
            	data.applicationId = rs.getInt("applicationId");
            	data.applicationName = rs.getString("title");
            	data.applicationVersion = rs.getString("currentVersion");
            	data.rankingEnabled = rs.getBoolean("rankingEnabled");
            }
            else{
            	data.isValid = false;
            }
           
        } 
    	catch (SQLException e) {
 			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
 		}
 		finally {
 			dbManager.closeStatement(pstmt);
 		}
 		
 		return data;
    	
    }
	
	public List<AuthenticationData> getAllApplicationData()
    {
		List<AuthenticationData> applications = new ArrayList<AuthenticationData>();
    	    	
    	String selectAPIKey = "SELECT applications.applicationId, applications.title, applications.currentVersion, applications.rankingEnabled " +
    						  "FROM applications";

    	PreparedStatement pstmt = dbManager.getPreparedStatement(selectAPIKey);

    	try 
        {
        	ResultSet rs = pstmt.executeQuery();
        	
            while (rs.next())
            {
            	AuthenticationData data = new AuthenticationData();
            	data.isValid = true;
            	data.applicationId = rs.getInt("applicationId");
            	data.applicationName = rs.getString("title");
            	data.applicationVersion = rs.getString("currentVersion");
            	data.rankingEnabled = rs.getBoolean("rankingEnabled");
            	
            	applications.add(data);
            }
           
        } 
    	catch (SQLException e) {
 			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
 		}
 		finally {
 			dbManager.closeStatement(pstmt);
 		}
 		
 		return applications;
    	
    }
	
	public AuthenticationData authenticateApiKey(String apiKey)
    {
		AuthenticationData data = new AuthenticationData();
    	    	
    	String selectAPIKey = "SELECT applications.applicationId, applications.title, applications.currentVersion, applications.rankingEnabled, apikeys.writeAccess FROM apikeys " +
						      "LEFT OUTER JOIN applications ON applications.applicationId = apikeys.applicationId " +
							  "WHERE apiKey = ? AND enabled=1";

    	PreparedStatement pstmt = dbManager.getPreparedStatement(selectAPIKey);
    	
    	try 
        {
        	pstmt.setString(1, apiKey);
        	ResultSet rs = pstmt.executeQuery();
        	
            if (rs.next()){
            	data.isValid = true;
            	data.apiKey = apiKey;
            	data.applicationId = rs.getInt("applicationId");
            	data.applicationName = rs.getString("title");
            	data.applicationVersion = rs.getString("currentVersion");
            	data.writeAccess =  (WriteAccess.valueOf(rs.getString("writeAccess").toUpperCase()));
            	data.rankingEnabled = rs.getBoolean("rankingEnabled");
            }
            else{
            	data.isValid = false;
            }
           
        } 
    	catch (SQLException e) {
 			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
 		}
 		finally {
 			dbManager.closeStatement(pstmt);
 		}
 		
 		return data;
    	
    }
    
    public AuthenticationData authenticateDeviceId(String deviceId)
    {
    	
    	AuthenticationData data = new AuthenticationData();
    	    	
    	String selectDeviceId = "SELECT deviceId, deviceType, registeredUsername FROM devices WHERE deviceId = ?";

    	PreparedStatement pstmt = dbManager.getPreparedStatement(selectDeviceId);
    	
    	try 
        {
        	pstmt.setString(1, deviceId);
        	ResultSet rs = pstmt.executeQuery();
        	
            if (rs.next()){
            	data.isValid = true;
            	data.deviceId = rs.getString("deviceId");
            	data.deviceType = DeviceType.generate(rs.getString("deviceType"));
            	data.username = rs.getString("registeredUsername");
            }
            else{
            	data.isValid = false;
            }
           
        } 
    	catch (SQLException e) {
 			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
 		}
 		finally {
 			dbManager.closeStatement(pstmt);
 		}
 		
 		return data;
    	
    }
    
    /**
     * Check if the access token is valid by ensuring that both it exists in the Database and that it's associated
     * with the Client application gained from the API Key given.
     * If the access token is valid it stores both the token and the username associated with the token.
     * 
     * @param _accessToken
     */
    public AuthenticationData authenticateAccessToken(String accessToken, int applicationId)
    {
    	
    	AuthenticationData data = new AuthenticationData();
    
    	
    	String selectAccessToken = 	"SELECT authenticatedusers.refreshToken, authenticatedusers.applicationId, authenticatedusers.username, authenticatedusers.pushNotificationToken, devices.deviceId, deviceType " +
    								"FROM authenticatedusers "+
    								"INNER JOIN devices ON devices.deviceId = authenticatedusers.deviceId "+
    								"INNER JOIN accesstokens ON accesstokens.refreshToken = authenticatedusers.refreshToken "+
    								"WHERE authenticatedusers.applicationId = ? AND accesstokens.accessToken = ? AND TIMESTAMPDIFF(MINUTE, accesstokens.createdDate, NOW()) < ? " +
    								"LIMIT 1";
    	
    	String selectUpdates = "SELECT name, url FROM applicationurls WHERE applicaitonId = ? AND deviceType = ?";

		PreparedStatement pstmt = dbManager.getPreparedStatement(selectAccessToken);
		
	
	 	   
	 	PreparedStatement pstmt2 = dbManager.getPreparedStatement(selectUpdates);
		    	
    	try 
		{    		
    		pstmt.setInt(1, applicationId);
			pstmt.setString(2, accessToken);
			pstmt.setInt(3, Constants.ACCESS_TOKEN_EXPIRATION_TIME_MINUTES);
			
			ResultSet rs = pstmt.executeQuery();
			
			if (rs.next()){
				data.isValid = true;
				data.refreshToken = rs.getString("refreshToken");
				data.username = rs.getString("username");
				data.applicationId = rs.getInt("applicationId");
				data.deviceId = rs.getString("deviceId");
				data.deviceType = DeviceType.generate(rs.getString("deviceType"));
				data.pushNotificationToken = rs.getString("pushNotificationToken");
				
				pstmt2.setInt(1, applicationId);
		 		pstmt2.setString(2, data.deviceType.value());
		 		   
		 		ResultSet rs2 = pstmt2.executeQuery();
		 			
		 		if (rs2.next()){
	 			   data.updateName = rs2.getString("name");
	 			   data.updateURL = rs2.getString("url");
		 		}
            }
			else{
				data.isValid = false;
			}
		}
    	catch (SQLException e) {
 			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
 		}
 		finally {
 			dbManager.closeStatement(pstmt);
 			dbManager.closeStatement(pstmt2);
 		}
 		
 		return data;
    }
        
   public String authenticateUserLogin(String username, String password) 
   {
	   String authenticatedUsername;
	   
	   String selectUser = "SELECT users.username FROM users WHERE LOWER(username) = LOWER(?) AND password = PASSWORD(?)";
		
       PreparedStatement pstmt = dbManager.getPreparedStatement(selectUser);
	   
	   try {
            pstmt.setString(1, username);
            pstmt.setString(2, password);

            ResultSet rs = pstmt.executeQuery();

            authenticatedUsername = rs.next() ? rs.getString("username") : null;
        }
	    catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt);
		}
		
		return authenticatedUsername;
    }
	
	
	
	public String authenticateAdminLogin(String username, String password)
    {
		 String authenticatedUsername;
		   
		   String selectUser = "SELECT users.username FROM users WHERE LOWER(username) = LOWER(?) AND password = PASSWORD(?) AND isAdmin = 1";
			
	       PreparedStatement pstmt = dbManager.getPreparedStatement(selectUser);
		   
		   try {
	            pstmt.setString(1, username);
	            pstmt.setString(2, password);

	            ResultSet rs = pstmt.executeQuery();

	            authenticatedUsername = rs.next() ? rs.getString("username") : null;
	        }
		    catch (SQLException e) {
				throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
			}
			finally {
				dbManager.closeStatement(pstmt);
			}
			
			return authenticatedUsername;
    }
	
	public Boolean isAuthenticated(String refreshToken){
		 String selectUser = "SELECT refreshToken FROM authenticatedusers WHERE refreshToken = ?";
		 PreparedStatement pstmt = dbManager.getPreparedStatement(selectUser);
		 try {
            pstmt.setString(1, refreshToken);
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

    
    /**
	    * Authenticates a User based on given refreshToken
	    * 
	    * @param refreshToken 
	    * 
	    * @return case sensitive if user is authenticated, null otherwise
	    */
   public AuthenticationData getAuthenticatedUser(String refreshToken) 
   {
	   AuthenticationData data = new AuthenticationData();
	   
	   String selectUser = "SELECT refreshToken, username, applicationId, deviceId, pushNotificationToken FROM authenticatedusers WHERE refreshToken = ?";
	   
	   PreparedStatement pstmt = dbManager.getPreparedStatement(selectUser);
       
	   try {
            pstmt.setString(1, refreshToken);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()){
            	data.isValid = true;
            	data.refreshToken = rs.getString("refreshToken");
				data.username = rs.getString("username");
				data.applicationId = rs.getInt("applicationId");
				data.deviceId = rs.getString("deviceId");
				data.pushNotificationToken = rs.getString("pushNotificationToken");
            }
            else{
            	data.isValid = false;
            }
        }
	    catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt);
		}
		
		return data;
    }
   
 
   
   public AuthenticationData getAuthenticatedUser(String deviceId, int applicationId) 
   {
	   AuthenticationData data = new AuthenticationData();
	   
	   String selectedAuthenticatedUser = "SELECT authenticatedusers.refreshToken, authenticatedusers.applicationId, authenticatedusers.username, authenticatedusers.deviceId, authenticatedusers.pushNotificationToken, devices.deviceType, devices.registeredUsername " +
											"FROM authenticatedusers RIGHT OUTER JOIN devices ON authenticatedusers.deviceId = devices.deviceId "+
											"WHERE devices.deviceID = ? AND (authenticatedusers.applicationId = ? OR authenticatedusers.applicationId IS NULL)" +
											"LIMIT 1";
	   
	   PreparedStatement pstmt = dbManager.getPreparedStatement(selectedAuthenticatedUser);
       
	   try {
            pstmt.setString(1, deviceId);
            pstmt.setInt(2, applicationId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()){
            	data.isValid = true;
            	data.refreshToken = rs.getString("refreshToken");
				data.username = rs.getString("registeredUsername");
				data.applicationId = rs.getInt("applicationId");
				data.deviceId = rs.getString("deviceId");
				data.pushNotificationToken = rs.getString("pushNotificationToken");
            }
            else{
            	data.isValid = false;
            }
        }
	    catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt);
		}
		
		return data;
    }
   
   public AuthenticationData getAuthenticatedUser(String username, String deviceId, int applicationId) 
   {
	   AuthenticationData data = new AuthenticationData();
	   
	   String selectedAuthenticatedUser = "SELECT username, deviceId, applicationId, refreshToken, pushNotificationToken " +
										   "FROM authenticatedusers "+
										   "WHERE LOWER(username) = LOWER(?) AND deviceId = ? AND applicationId = ? " +
										   "LIMIT 1";
	   
	   PreparedStatement pstmt = dbManager.getPreparedStatement(selectedAuthenticatedUser);
       
	   try {
		    pstmt.setString(1, username);
            pstmt.setString(2, deviceId);
            pstmt.setInt(3, applicationId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()){
            	data.isValid = true;
            	data.refreshToken = rs.getString("refreshToken");
				data.username = rs.getString("username");
				data.applicationId = rs.getInt("applicationId");
				data.deviceId = rs.getString("deviceId");
				data.pushNotificationToken = rs.getString("pushNotificationToken");
            }
            else{
            	data.isValid = false;
            }
        }
	    catch (SQLException e) {
			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		}
		finally {
			dbManager.closeStatement(pstmt);
		}
		
		return data;
    }

	   
    public List<AuthenticationData> getAuthenticatedUsers(String username, int applicationId)
    {
    	
    	List<AuthenticationData> authDataList = new ArrayList<AuthenticationData>();
    
    	
    	String selectedAuthenticatedUsers = "SELECT authenticatedusers.refreshToken, authenticatedusers.applicationId, authenticatedusers.username, authenticatedusers.pushNotificationToken, devices.deviceId, devices.deviceType " +
		    								"FROM authenticatedusers "+
		    								"INNER JOIN devices ON devices.deviceId = authenticatedusers.deviceId " +
		    								"WHERE authenticatedusers.username = ? AND authenticatedusers.applicationId = ? ";

    	
    	PreparedStatement pstmt = dbManager.getPreparedStatement(selectedAuthenticatedUsers);
		
    	try 
		{    		
			pstmt.setString(1, username);
			pstmt.setInt(2, applicationId);
			
			
			ResultSet rs = pstmt.executeQuery();
			
			while (rs.next())
			{
				
				AuthenticationData data = new AuthenticationData();
				
				data.isValid = true;
				data.refreshToken = rs.getString("refreshToken");
				data.username = rs.getString("username");
				data.applicationId = rs.getInt("applicationId");
				data.deviceId = rs.getString("deviceId");
				data.deviceType = DeviceType.generate(rs.getString("deviceType"));
				data.pushNotificationToken = rs.getString("pushNotificationToken");
				
				authDataList.add(data);
            }

		}
    	catch (SQLException e) {
 			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
 		}
 		finally {
 			dbManager.closeStatement(pstmt);
 		}
 		
 		return authDataList;
    }
    
    
    public DeviceData getDevice(String deviceId)
    {
    	
    	DeviceData data = null;
    	    	
    	String selectDeviceId = "SELECT deviceId, deviceType, os, registeredUsername FROM devices WHERE deviceId = ?";

    	PreparedStatement pstmt = dbManager.getPreparedStatement(selectDeviceId);
    	
    	try 
        {
        	pstmt.setString(1, deviceId);
        	ResultSet rs = pstmt.executeQuery();
        	
            if (rs.next()){
            	data = new DeviceData();
            	data.deviceId = rs.getString("deviceId");
            	data.deviceType = rs.getString("deviceType");
            	data.os = rs.getString("os");
            	//data.registeredUsername = rs.getString("registeredUsername");
            }
           
        } 
    	catch (SQLException e) {
 			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
 		}
 		finally {
 			dbManager.closeStatement(pstmt);
 		}
 		
 		return data;
    	
    }
	
	public void addDevice(DeviceData data)
	{		
		String deviceInsert = "INSERT IGNORE INTO devices(deviceId, deviceType, os, screenDPI, cpuArchitecture) VALUES(?, LOWER(?), ?, ?, ?)";

        PreparedStatement pstmt = dbManager.getPreparedStatement(deviceInsert);
         
    	try{
    		pstmt.setString(1, data.deviceId);
    		pstmt.setString(2, data.deviceType);
    		pstmt.setString(3, data.os);
    		pstmt.setInt(4, data.screenDPI);
    		pstmt.setString(5, data.cpuArchitecture);
    		
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
	     * add a user to the application_user table in the database if one does not already exists
	     * @param applicationId
	     * @param username
	     */
	    public Boolean addApplicationUser(int applicationId, String username) 
	    {
	    	Boolean added = false;
        	String applicationsusersInsert = "INSERT IGNORE INTO applications_users(applicationId, username) VALUES(?, ?)";

            PreparedStatement pstmt = dbManager.getPreparedStatement(applicationsusersInsert);
             
        	try{
        		pstmt.setInt(1, applicationId);
        		pstmt.setString(2, username);
        		added = pstmt.executeUpdate() == 1;
        	}
        	catch (SQLException e) {
        		throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
        	}
        	finally {
        		dbManager.closeStatement(pstmt);
        	}

        	return added;
	    }
	    
	    
	    
	   
	    public String addAuthenticatedUser(int applicationId, String username, String deviceId, PushNotificationToken pushToken) 
	    {
	    	String refreshToken = null;
	    	
	    	//Check if we already have an authenticated user with this device
	    	AuthenticationData data = getAuthenticatedUser(username, deviceId, applicationId);
	    	
	    	if (data.isValid)
	    	{
		    	updatePushNotifcationToken(data.refreshToken, pushToken);
	    		updateRefreshToken(data.refreshToken);
	    		return data.refreshToken;
	    	}
	    	else
	    	{
	    		refreshToken = Utility.generateRandomToken();
		        String refreshTokenInsert = "INSERT INTO authenticatedusers (refreshToken, username, applicationId, deviceId, pushNotificationToken)  VALUES(?,?,?,?,?)";
	
		        PreparedStatement pstmt = dbManager.getPreparedStatement(refreshTokenInsert);
		        
		        String token = (pushToken != null) ? pushToken.token : null;
		    	
		    	try {
		            pstmt.setString(1, refreshToken);
		            pstmt.setString(2, username);
		            pstmt.setInt(3, applicationId);
		            pstmt.setString(4, deviceId);
		            pstmt.setString(5, token);
		            
		            pstmt.executeUpdate();   
		            
		            addApplicationUser(applicationId, username);
		        } 
		    	catch (SQLException e) {
		    		throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
		    	}
		    	finally {
		    		dbManager.closeStatement(pstmt);
		    	}
	    	}
	    	
	    	return refreshToken;
	    }
	    
	    public void deleteAuthenticatedUser(String refreshToken) 
	    {
	    	String refreshTokenDelete = "DELETE FROM authenticatedusers WHERE refreshToken = ?";
	    	PreparedStatement pstmt = dbManager.getPreparedStatement(refreshTokenDelete);
	    	
	    	try{
				pstmt.setString(1, refreshToken);
			    pstmt.executeUpdate();
					
			} 
	    	catch (SQLException e) {
	    		throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
	    	}
	    	finally {
	    		dbManager.closeStatement(pstmt);
	    	}
	    }
	    

	    public void deleteAuthenticatedUsers(int applicationId, String username) 
	    {
	    	String refreshTokenDelete = "DELETE FROM authenticatedusers WHERE applicationId = ? AND LOWER(username) = LOWER(?)";
	    	PreparedStatement pstmt = dbManager.getPreparedStatement(refreshTokenDelete);
	    	
	    	try{
	    		pstmt.setInt(1, applicationId);
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
	     * Generates a random 32 bit access token and adds it to the accesstokens table in the database 
	     * @param applicationId
	     * @param username
	     * @return generated access token
	     */
	    public String createAccessToken(String refereshToken) {

	    	String accessToken = Utility.generateRandomToken();
	    	 
	        String accessTokenInsert = "INSERT INTO accesstokens (accessToken, refreshToken) VALUES(?,?)";

	        PreparedStatement pstmt = dbManager.getPreparedStatement(accessTokenInsert);
		        
	    	try 
	    	{
	            pstmt.setString(1, accessToken);
	            pstmt.setString(2, refereshToken);

	            pstmt.executeUpdate();
	            
	        } 
	    	catch (SQLException e) {
	    		throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
	    	}
	    	finally {
	    		dbManager.closeStatement(pstmt);
	    	}
	    	
	    	 
	    	 return accessToken;
	    }
	   
	    /**
	     * Refreshes the expiration date of an access token
	     * @param accessToken
	     */
	    public void updateRefreshToken(String refreshToken) 
	    {	    	
	    	String refreshTokenUpdate = "UPDATE authenticatedusers SET createdDate = NOW() WHERE refreshToken = ?";
	    	PreparedStatement pstmt = dbManager.getPreparedStatement(refreshTokenUpdate);
		    	
	    	try{
	 		    pstmt.setString(1, refreshToken);
	 		    pstmt.executeUpdate();
	 				
	 		} 
	    	catch (SQLException e) {
	    		throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
	    	}
	    	finally {
	    		dbManager.closeStatement(pstmt);
	    	}
	    }
	    
	    public void updatePassword(String username, String password) throws DatabaseException 
	    {
	    	String userUpdate = "Update users SET password = PASSWORD(?) WHERE username = ?";

	    	PreparedStatement pstmt = dbManager.getPreparedStatement(userUpdate);

	    	try 
	    	{
	            pstmt.setString(1, password);
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
	    public void deleteAllAccessTokens(String refreshToken) 
	    {
	    	String accessTokensDelete = "DELETE FROM accesstokens WHERE refreshToken = ?";
	    	PreparedStatement pstmt = dbManager.getPreparedStatement(accessTokensDelete);

	    	try{
				pstmt.setString(1, refreshToken);
			    pstmt.executeUpdate();
					
			} 
	    	catch (SQLException e) {
	    		throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
	    	}
	    	finally {
	    		dbManager.closeStatement(pstmt);
	    	}
	    }

	    
	    public void deleteExpiredAccessTokens()
	    {
	    	String deleteAccessTokens = "DELETE FROM accesstokens WHERE TIMESTAMPDIFF(MINUTE, createdDate, NOW()) > ?";
			PreparedStatement pstmt = dbManager.getPreparedStatement(deleteAccessTokens);
			
	    	try{
	    		pstmt.setInt(1, Constants.ACCESS_TOKEN_EXPIRATION_TIME_MINUTES);
	    		pstmt.executeUpdate();
	    	}
	    	catch (SQLException e) {
				throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
			}
			finally {
				dbManager.closeStatement(pstmt);
			}
	    }
	    
	    public void deleteExpiredRefreshTokens()
	    {
	    	String deleteRefreshTokens = "DELETE FROM authenticatedusers WHERE TIMESTAMPDIFF(DAY, createdDate, NOW()) > ?";
			PreparedStatement pstmt = dbManager.getPreparedStatement(deleteRefreshTokens);
			
	    	try{
	    		pstmt.setInt(1, Constants.REFRESH_TOKEN_EXPIRATION_TIME_DAYS);
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
	     * Refreshes the expiration date of an access token
	     * @param accessToken
	     */
	    public void setRegisteredUsername(String username, String deviceId) 
	    {	    	
	    	String registeredUsernameUpdate = "UPDATE devices SET registeredUsername = ? WHERE deviceId = ?";
	    	PreparedStatement pstmt = dbManager.getPreparedStatement(registeredUsernameUpdate);
		    	
	    	try{
	 		    pstmt.setString(1, username);
	 		    pstmt.setString(2, deviceId);
	 		    pstmt.executeUpdate();
	 				
	 		} 
	    	catch (SQLException e) {
	    		throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
	    	}
	    	finally {
	    		dbManager.closeStatement(pstmt);
	    	}
	    }
	    
	    public void deletePushNotifcationToken(String refreshToken)
	    {
	    	String pushTokenUpdate = "UPDATE authenticatedusers SET pushNotificationToken = NULL " +
	    							 "WHERE refreshToken = ?";
	    	
	    	PreparedStatement pstmt = dbManager.getPreparedStatement(pushTokenUpdate);
	    	
	    	try{
	 		    pstmt.setString(1, refreshToken);
	 		    pstmt.executeUpdate();
	 				
	 		} 
	    	catch (SQLException e) {
	    		throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
	    	}
	    	finally {
	    		dbManager.closeStatement(pstmt);
	    	}
	    }
	    
	    public void deletePushNotifcationToken(PushNotificationToken token)
	    {
	    	String pushTokenUpdate = "UPDATE authenticatedusers SET pushNotificationToken = NULL " +
	    							 "WHERE pushNotificationToken = ?";
	    	
	    	PreparedStatement pstmt = dbManager.getPreparedStatement(pushTokenUpdate);
	    	
	    	try{
	 		    pstmt.setString(1, token.token);
	 		    pstmt.executeUpdate();
	 				
	 		} 
	    	catch (SQLException e) {
	    		throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
	    	}
	    	finally {
	    		dbManager.closeStatement(pstmt);
	    	}
	    }
	    
	    public void updatePushNotifcationToken(String refreshToken, PushNotificationToken token)
	    {
	    	
	    	if (token == null){
	    		deletePushNotifcationToken(refreshToken);
	    		return;
	    	}
	    	
	    	String pushTokenUpdate = "UPDATE authenticatedusers SET pushNotificationToken = ? " +
	    							 "WHERE refreshToken = ?";
	    	
	    	PreparedStatement pstmt = dbManager.getPreparedStatement(pushTokenUpdate);
	    	
	    	try{
	 		    pstmt.setString(1, token.token);
	 		    pstmt.setString(2, refreshToken);
	 		    pstmt.executeUpdate();
	 				
	 		} 
	    	catch (SQLException e) {
	    		throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
	    	}
	    	finally {
	    		dbManager.closeStatement(pstmt);
	    	}
	    }
	    
	    public void deleteLogs(int daysOld)
	    {
	    	String pushTokenUpdate = "DELETE FROM clientlogs WHERE TIMESTAMPDIFF(DAY, logDate , NOW()) > ? ";
	    	
	    	PreparedStatement pstmt = dbManager.getPreparedStatement(pushTokenUpdate);
	    	
	    	try{
	 		    pstmt.setInt(1, daysOld);
	 		    pstmt.executeUpdate();
	 				
	 		} 
	    	catch (SQLException e) {
	    		throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
	    	}
	    	finally {
	    		dbManager.closeStatement(pstmt);
	    	}
	    }
	    
	    public List<AuthenticationData> getAllUpdateSites(int applicationId) 
	    {	 	   
	 	  String selectUpdates = "SELECT name, url, deviceType FROM applicationurls WHERE applicaitonId = ?";
	 		
	      PreparedStatement pstmt = dbManager.getPreparedStatement(selectUpdates);
	 	   
	 	   try {
	             pstmt.setInt(1, applicationId);

	             ResultSet rs = pstmt.executeQuery();
	             
	             List<AuthenticationData> sites = new ArrayList<AuthenticationData>();
	             
	             while (rs.next()){
	            	 AuthenticationData authData = new AuthenticationData();
	            	 authData.deviceType = DeviceType.generate(rs.getString("deviceType"));
	            	 authData.updateName = rs.getString("name");
	            	 authData.updateURL = rs.getString("url");
	            	 
	            	 sites.add(authData);
	             }
	             
	             return sites;

	         }
	 	    catch (SQLException e) {
	 			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
	 		}
	 		finally {
	 			dbManager.closeStatement(pstmt);
	 		}
	    }
	    
	    public List<String> getPendingInviters(String emailAddress, int applicationId) 
	    {	   
	    	String inviteSelect = "SELECT username FROM pendinginvites WHERE emailAddress = ? AND applicationId = ?";
			
			
			PreparedStatement pstmt = dbManager.getPreparedStatement(inviteSelect);
			
			try 
			{
			   pstmt.setString(1, emailAddress);
			   pstmt.setInt(2, applicationId);
			   
			   ResultSet rs = pstmt.executeQuery();
			   
			   List<String> inviters = new ArrayList<String>();
			   
			   while (rs.next()){
				   inviters.add(rs.getString("username"));
			   }
			   
			   return inviters;
			 
			} 
			catch (SQLException e) {
				throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
			}
			finally {
				dbManager.closeStatement(pstmt);
			}	
	     }
	    
	    public void addPendingInvite(String inviter, String emailAddress, int applicationId) 
	    {	   
	    	String inviteInsert= "INSERT IGNORE INTO pendinginvites(username, emailAddress, applicationId) VALUES (?, ?, ?)";
			
			
			PreparedStatement pstmt = dbManager.getPreparedStatement(inviteInsert);
			
			try 
			{
			   pstmt.setString(1, inviter);
			   pstmt.setString(2, emailAddress);
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
	    
	    public void deletePendingInvitations(String emailAddress, int applicationId) 
	    {	   
	    	String inviteDelete = "DELETE FROM pendinginvites WHERE emailAddress = ? AND applicationId = ?";
			
			
			PreparedStatement pstmt = dbManager.getPreparedStatement(inviteDelete);
			
			try 
			{
			   pstmt.setString(1, emailAddress);
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
	    
	    public Boolean isSubscribed(String emailAddress) 
	    {	
	    	String subscribedSelect = "SELECT 1 FROM unsubscribed WHERE emailAddress = ?";
			
			
			PreparedStatement pstmt = dbManager.getPreparedStatement(subscribedSelect);
			
			try 
			{
			   pstmt.setString(1, emailAddress);			   
			   ResultSet rs = pstmt.executeQuery();

			   return !rs.next();
			 
			} 
			catch (SQLException e) {
				throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
			}
			finally {
				dbManager.closeStatement(pstmt);
			}	
	    }
	    
	    public void unsubscribe(String emailAddress) 
	    {	   
	    	String insertUnsubscribed = "INSERT IGNORE INTO unsubscribed VALUES(?)";
			
			
			PreparedStatement pstmt = dbManager.getPreparedStatement(insertUnsubscribed);
			
			try 
			{
			   pstmt.setString(1, emailAddress);
			   
			   pstmt.executeUpdate();
			 
			} 
			catch (SQLException e) {
				throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
			}
			finally {
				dbManager.closeStatement(pstmt);
			}	
	     }
	    
	    public void resubscribe(String emailAddress) 
	    {	   
	    	String deleteUnsubscribed = "DELETE FROM unsubscribed WHERE emailAddress = ?";
			
			
			PreparedStatement pstmt = dbManager.getPreparedStatement(deleteUnsubscribed);
			
			try 
			{
			   pstmt.setString(1, emailAddress);
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

