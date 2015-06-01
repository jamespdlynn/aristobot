package com.aristobot.managers;

import java.lang.reflect.Field;

import javax.ws.rs.WebApplicationException;
import javax.ws.rs.core.MultivaluedMap;

import com.aristobot.data.AuthenticationData;
import com.aristobot.exceptions.AuthenticationException;
import com.aristobot.repository.AuthenticationRepositiory;
import com.aristobot.utils.Constants;
import com.aristobot.utils.Constants.DeviceType;
import com.aristobot.utils.Constants.WriteAccess;

/**
 * Class used to determine and store client permissions gained from a given request
 * 
 * @author James
 */
public class AuthenticationManager 
{			
	//The applicationId is an integer identifier for a given client application, it has a one to one relationship to the API Key sent up in a request header
	private String _apiKey;
	
	//An accesstoken is a short lastings token granted to an authenticated user
	private String _accessToken;

	private AuthenticationData _authData;
	
	private AuthenticationRepositiory authRepo;
	
	private LocalCacheManager<AuthenticationData> cm;
	
		/**
	 * Determine permissions and store granted from the request headers
	 * 
	 * @param headers HTPP Request Headers
	 */
	
	public AuthenticationManager(JDBCManager dbManager)
	{
		authRepo = new AuthenticationRepositiory(dbManager);
		cm = new LocalCacheManager<AuthenticationData>(Constants.AUTH_CACHE_NAME);
	}
	
	public AuthenticationManager(JDBCManager dbManager, String apiKey)
	{
		this(dbManager);
		_apiKey = apiKey;    	
	}
	
	public AuthenticationManager(JDBCManager dbManager, String apiKey, String accessToken)
	{
		this(dbManager, apiKey);
		_accessToken = accessToken;
	}
	
	public AuthenticationManager(JDBCManager dbManager, MultivaluedMap<String, String> headers)
	{
		this(dbManager);
		setHeaders(headers);
	}
    
    /**
     * Ensure a valid API Key by throwing an exception otherwise
     */
    public void requireValidApiKey()
    {
    	if (!authenticateApiKey()){
    		throw new AuthenticationException(AuthenticationException.INVALID_API_KEY);
    	}
    }
    
    /**
     * Ensure a valid API Key and Access Token by throwing an exception otherwise
     */
    public void requireFullAuthentication() 
    {
    	if (_apiKey == null || _apiKey.length() == 0 ){
    		throw new AuthenticationException(AuthenticationException.INVALID_API_KEY);
    	}
    	
    	if (_accessToken == null || _accessToken.length() == 0){
    		throw new AuthenticationException(AuthenticationException.INVALID_ACCESS_TOKEN);
    	}
    	
    	_authData = cm.getFromCache(_accessToken);
    	
    	if (_authData == null || !_authData.apiKey.equals(_apiKey))
    	{
    		if (!authenticateApiKey()){
        		throw new AuthenticationException(AuthenticationException.INVALID_API_KEY);
        	}
        	
        	if (!authenticateAccessToken()){
        		throw new AuthenticationException(AuthenticationException.INVALID_ACCESS_TOKEN);
        	}
        	
    	}
    }
   
    
    public void requireAdminPrivelleges()
    {
    	if (_authData == null && !authenticateApiKey()){
    		throw new AuthenticationException(AuthenticationException.INVALID_API_KEY);
    	}
    	if ( _authData.writeAccess != WriteAccess.ADMIN){
    		throw new AuthenticationException(AuthenticationException.INVALID_WRITE_ACCESS);
    	}
    }

    /**
     * Ensure the user has partial write permissions by throwing an exception otherwise
     */
    public void requirePartialWriteAccess()
    {
    	if (_authData == null && !authenticateApiKey()){
    		throw new AuthenticationException(AuthenticationException.INVALID_API_KEY);
    	}
    	if (_authData.writeAccess != WriteAccess.FULL && _authData.writeAccess != WriteAccess.PARTIAL){
    		throw new AuthenticationException(AuthenticationException.INVALID_WRITE_ACCESS);
    	}
    }
    
    
    /**
     * Ensure the user has full write permissions by throwing an exception otherwise
     */
    public void requireFullWriteAccess()
    {
    	if (_authData == null && !authenticateApiKey()){
    		throw new AuthenticationException(AuthenticationException.INVALID_API_KEY);
    	}
    	
    	if (_authData.writeAccess != WriteAccess.FULL){
    		throw new AuthenticationException(AuthenticationException.INVALID_WRITE_ACCESS);
    	}
    }
    
   
   
    /**
     * Check if API Key given is valid by looking it up in the database.
     * If the key is valid store the id of the mapped application as well as the writeaccess granted to this apiKey
     * 
     * @param apiKey
     */ 
    public Boolean authenticateApiKey()
    {
    	
    	if (_apiKey == null || _apiKey.length() == 0){
    		return false;
    	}
    	
    	_authData = authRepo.authenticateApiKey(_apiKey);
    	return _authData.isValid;
    	
    }
    
    
    /**
     * Check if the access token is valid by ensuring that both it exists in the Database and that it's associated
     * with the Client application gained from the API Key given.
     * If the access token is valid it stores both the token and the username associated with the token.
     * 
     * @param _accessToken
     */
    public Boolean authenticateAccessToken()
    {
    	if (_authData == null || _accessToken == null || _accessToken.length() == 0){
    		return false;
    	}

    	AuthenticationData newAuthData = authRepo.authenticateAccessToken(_accessToken, _authData.applicationId);
    	
    	
    	if (newAuthData.isValid)
    	{
    		
    		try{
    			Field[] fields = AuthenticationData.class.getFields();
        		
        		for (Field field : fields)
        		{		
        			Object value = field.get(newAuthData);
        			
        			if (value != null){
        				field.set(_authData, value);
        			}
        		}
    		}
    		catch (IllegalAccessException e){
    			LogManager.logException(e);
    			throw new WebApplicationException(500);
    		}
    		
    		cm.saveToCache(_accessToken, _authData);
    			
    		return true;
    	}
    	
    	return false;
    }
    
    public AuthenticationData getAuthData(){
    	return _authData;
    }
    
    public String getAPIKey(){
    	return _apiKey;
    }
    
    public int getApplicationId()
    {
    	if (_authData == null) authenticateApiKey();
    	return _authData.applicationId;
    }
    
    public String getApplicationName()
    {
    	if (_authData == null) authenticateApiKey();
    	return _authData.applicationName;
    }
    
    public String getApplicationVersion()
    {
    	if (_authData == null) authenticateApiKey();
    	return _authData.applicationVersion;
    }
    
    public String getUsername()
    {
    	return _authData.username;
    }
    
    public String getRefreshToken()
    {
    	return _authData.refreshToken;
    }
    
    public String getAccessToken()
    {
    	return _accessToken;
    }
    
    public String getPushNotificationToken()
    {
    	return _authData.pushNotificationToken;
    }
    
    public String getDeviceId()
    {
    	return _authData.deviceId;
    }
    
    public DeviceType getDeviceType()
    {
    	return _authData.deviceType;
    }
    
    public Boolean getRankingEnabled()
    {
    	return _authData.rankingEnabled;
    }


    public void setApiKey(String value)
    {
    	_apiKey = value;
    }
    
    public void setAccessToken(String value)
    {
    	_accessToken = value;
    }
    
    public void setHeaders(MultivaluedMap<String, String> value)
    {
    	if (value != null){
    		_apiKey = value.getFirst("API");
			_accessToken = value.getFirst("AC");
    	}
    }
 
}
