package com.aristobot.repository;

import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import com.aristobot.data.UserIcon;
import com.aristobot.exceptions.DatabaseException;
import com.aristobot.managers.JDBCManager;
import com.aristobot.utils.Utility;
import com.aristobot.utils.Constants.DeviceType;

public class IconRepository 
{
	private JDBCManager dbManager;
	
	public IconRepository(JDBCManager manager)
	{
		dbManager = manager;
	}

	
    public Boolean iconExists(String iconKey)
    {
    	Boolean iconExists;
    	
    	String selectIcon = "SELECT iconKey FROM icons WHERE iconKey = ?";
    	
    	PreparedStatement pstmt = dbManager.getPreparedStatement(selectIcon);
		try{
	    	pstmt.setString(1, iconKey);
	    	
	    	ResultSet rs = pstmt.executeQuery();
	    	iconExists = rs.next();
	        
	    }
		catch (SQLException e) {
 			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
 		}
 		finally {
 			dbManager.closeStatement(pstmt);
 		}
 		
 		return iconExists;
        
    }
    
    public UserIcon getIcon(String iconKey){
    	
    	 UserIcon icon;
    	 
    	 String selectIcon = "SELECT iconKey FROM icons WHERE iconKey = ?";
 		 PreparedStatement pstmt = dbManager.getPreparedStatement(selectIcon); 
 		 
    	 try {
        	pstmt.setString(1, iconKey);
        	ResultSet rs = pstmt.executeQuery();
        	icon = (rs.next()) ? Utility.getIcon(rs.getString("iconKey")) : null;  
        }
    	catch (SQLException e) {
  			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
  		}
  		finally {
  			dbManager.closeStatement(pstmt);
  		}
        
  		return icon;
    }
    
    public List<UserIcon> getAllIcons()
    {
    	
    	
    	
    	String selectIcons = "SELECT icons.iconKey, name, level, deviceType, applicationId, isDefault FROM icons";

    	PreparedStatement pstmt = dbManager.getPreparedStatement(selectIcons);
    	
    	try 
    	{
        	ResultSet rs = pstmt.executeQuery();
        		
        	List<UserIcon> icons = new ArrayList<UserIcon>();
        	
	        while (rs.next()){
	        	UserIcon icon = Utility.getIcon(rs.getString("iconKey"), rs.getString("name"), rs.getInt("level"), rs.getString("deviceType"), rs.getInt("applicationId"), rs.getBoolean("isDefault"));
	        	icons.add(icon);
	        }
	        
	        return icons;
	    }
    	catch (SQLException e) {
  			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
  		}
  		finally {
  			dbManager.closeStatement(pstmt);
  		}
        
        
    }
    
    public List<UserIcon> getIconsByLevel(int level)
    {
    	String selectIcons = "SELECT iconKey, name, level, deviceType, applicationId, isDefault FROM icons " +
		"WHERE level = ?";

    	PreparedStatement pstmt = dbManager.getPreparedStatement(selectIcons);
    	
    	try 
    	{
        	pstmt.setInt(1, level);
        	
        	ResultSet rs = pstmt.executeQuery();
        
        	List<UserIcon> icons = new ArrayList<UserIcon>();
        	
	        while (rs.next()){
	        	UserIcon icon = Utility.getIcon(rs.getString("iconKey"), rs.getString("name"), rs.getInt("level"), rs.getString("deviceType"), rs.getInt("applicationId"), rs.getBoolean("isDefault"));
	        	icons.add(icon);
	        }
	        
	        return icons;
	    }
    	catch (SQLException e) {
  			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
  		}
  		finally {
  			dbManager.closeStatement(pstmt);
  		}
        
    }
    
    public List<UserIcon> getUserIcons(String username){
    	
    	List<UserIcon> icons = new ArrayList<UserIcon>();
    	
    	String selectIcons = "SELECT icons.iconKey, name, level FROM icons " +
		"INNER JOIN users_icons ON icons.iconKey = users_icons.iconKey " +
		"WHERE LOWER(users_icons.username) = LOWER(?) " +
		"ORDER BY level ASC, users_icons.id ASC";

    	PreparedStatement pstmt = dbManager.getPreparedStatement(selectIcons);
    	
    	try 
    	{
        	pstmt.setString(1, username);
        	
        	ResultSet rs = pstmt.executeQuery();
        		
	        while (rs.next()){
	        	UserIcon icon = Utility.getIcon(rs.getString("iconKey"), rs.getString("name"), rs.getInt("level"));
	        	icons.add(icon);
	        }
	    }
    	catch (SQLException e) {
  			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
  		}
  		finally {
  			dbManager.closeStatement(pstmt);
  		}
        
        return icons;
    }
    
    public List<UserIcon> getDefaultIcons(int applicationId, String deviceType)
    {
    	List<UserIcon> icons = new ArrayList<UserIcon>();
    	PreparedStatement pstmt = dbManager.getPreparedStatement("SELECT iconKey, name, level FROM icons WHERE isDefault = 1 " +
    															 "AND (applicationId IS NULL OR applicationId = ?) AND (deviceType IS NULL OR deviceType = ?)");
    	
    	try {
    		pstmt.setInt(1, applicationId);
    		pstmt.setString(2, deviceType);
    		
	    	ResultSet rs = pstmt.executeQuery();
	    	
	        
	        while (rs.next()){
	        	UserIcon icon = Utility.getIcon(rs.getString("iconKey"), rs.getString("name"), rs.getInt("level"));
	        	icons.add(icon);
	        }
        }
        catch (SQLException e) {
            throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
        }
        finally{
        	dbManager.closeStatement(pstmt);
        }
        
        return icons;
    }
    
    public int getNumberOfIcons(String username, Boolean includeDefault)
    {
    	int numIcons;
    	
    	String selectUnlocked = "SELECT COUNT(icons.iconKey) FROM icons " +
		"LEFT OUTER JOIN users_icons ON users_icons.iconKey = icons.iconKey " +
		"WHERE users_icons.username = ? AND (icons.isDefault = ? OR icons.isDefault = 0)";		

    	PreparedStatement pstmt = dbManager.getPreparedStatement(selectUnlocked);
    	
    	try {
	    	pstmt.setString(1, username);
	    	pstmt.setBoolean(2, includeDefault);
	    	ResultSet rs = pstmt.executeQuery();
	    	
	    	rs.next();
    		numIcons = rs.getInt(1);
        }
    	catch (SQLException e) {
  			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
  		}
  		finally {
  			dbManager.closeStatement(pstmt);
  		}
  		
  		return numIcons;
    }
    
    public void addDefaultIcons(String username, DeviceType deviceType)
    {
    	String insertIcon = "INSERT INTO users_icons(username, iconKey) "+
    						"SELECT ?, iconKey FROM icons WHERE isDefault = 1 AND (deviceType IS NULL OR deviceType = ?)";
        
        PreparedStatement pstmt = dbManager.getPreparedStatement(insertIcon);
        
        try{
        	pstmt.setString(1, username);
        	pstmt.setString(2, deviceType.value());
	    	
        	pstmt.executeUpdate();
	        
        }
        catch (SQLException e) {
  			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
  		}
  		finally {
  			dbManager.closeStatement(pstmt);
  		}
    }
    
    
    public UserIcon unlockRandomIcon(String username, int level, int applicationId)
    {    	
    	String randomIconKey;
    	String randomIconName;
    	
    	String selectIcons = "SELECT iconKey, name FROM icons " +
    	"WHERE isUnlockable = 1 AND level = ? " +
    	"AND (applicationId IS NULL OR applicationId = ?) AND iconKey NOT IN (SELECT iconKey FROM users_icons WHERE username = ?)";
		
    	PreparedStatement pstmt = dbManager.getPreparedStatement(selectIcons);
    	
    	try 
    	{
    		pstmt.setInt(1, level);
    		pstmt.setInt(2, applicationId);
	    	pstmt.setString(3, username);
	    	ResultSet rs = pstmt.executeQuery();

	    	rs.last();
	    	int size = rs.getRow();
	    	
	    	if (size == 0){
	    		return (level > 1) ? unlockRandomIcon(username, level-1, applicationId) : null;
	    	}
	    	
	    	int random = new Random().nextInt(size);
	    	
	    	for (int i=0; i < random; i++) rs.previous();
	    	
	        randomIconKey= rs.getString("iconKey");
	        randomIconName= rs.getString("name");
    	}
    	catch (SQLException e) {
  			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
  		}
  		finally {
  			dbManager.closeStatement(pstmt);
  		}
        		        	        
		String insertIcon = "INSERT INTO users_icons(username, iconKey) VALUES (?,?)";
        
        PreparedStatement pstmt2 = dbManager.getPreparedStatement(insertIcon);
        
        try{
	        pstmt2.setString(1, username);
	        pstmt2.setString(2, randomIconKey);
	    	
	        pstmt2.executeUpdate();
	        
        }
        catch (SQLException e) {
  			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
  		}
  		finally {
  			dbManager.closeStatement(pstmt2);
  		}
	         
  		
  		return Utility.getIcon(randomIconKey, randomIconName, level); 

    }
    
    public void addIcon(UserIcon icon)
    {
    	
    	String addIcon = "INSERT INTO icons (iconKey, name, level, applicationId, deviceType, isDefault) VALUES (?,?,?,?,?,?)";

    	PreparedStatement pstmt = dbManager.getPreparedStatement(addIcon);
    	
    	try 
    	{
	    	pstmt.setString(1, icon.iconKey);
	    	pstmt.setString(2, icon.iconName);
	    	pstmt.setInt(3, icon.level);
	    	
	    	if (icon.applicationId >= 100000){
	    		pstmt.setInt(4, icon.applicationId);
	    	}
	    	else{
	    		pstmt.setNull(4, java.sql.Types.INTEGER);
	    	}
	    	
	    	pstmt.setString(5, icon.deviceType);
	    	pstmt.setBoolean(6, icon.isDefault);
	    	
	    	pstmt.executeUpdate();
        }
    	catch (SQLException e) {
  			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
  		}
  		finally {
  			dbManager.closeStatement(pstmt);
  		}
    }
    
    public void updateIcon(UserIcon icon)
    {
    	
    	String addIcon = "UPDATE icons SET name = ?, level = ?, applicationId = ?, deviceType = ?, isDefault = ? WHERE iconKey = ?";

    	PreparedStatement pstmt = dbManager.getPreparedStatement(addIcon);
    	
    	try 
    	{
	    	pstmt.setString(1, icon.iconName);
	    	pstmt.setInt(2, icon.level);
	    	
	    	if (icon.applicationId >= 100000){
	    		pstmt.setInt(3, icon.applicationId);
	    	}
	    	else{
	    		pstmt.setNull(3, java.sql.Types.INTEGER);
	    	}
	    	
	    	pstmt.setString(4, icon.deviceType);
	    	
	    	pstmt.setBoolean(5, icon.isDefault);
	    	
	    	pstmt.setString(6, icon.iconKey);

	    	
	    	pstmt.executeUpdate();
        }
    	catch (SQLException e) {
  			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
  		}
  		finally {
  			dbManager.closeStatement(pstmt);
  		}
    }
    
    public void deleteIcon(String iconKey)
    {
    	
    	String addIcon = "DELETE FROM icons WHERE iconKey = ?";

    	PreparedStatement pstmt = dbManager.getPreparedStatement(addIcon);
    	
    	try {
	    	pstmt.setString(1, iconKey);
	    	pstmt.executeUpdate();
        }
    	catch (SQLException e) {
  			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
  		}
  		finally {
  			dbManager.closeStatement(pstmt);
  		}
    }
    
    public List<String> getIconOwners(String iconKey)
    {
    	String getUsernames = "SELECT DISTINCT username FROM users_icons WHERE iconKey = ?";
    	
    	PreparedStatement pstmt = dbManager.getPreparedStatement(getUsernames);
    	    	
    	try 
    	{
	    	pstmt.setString(1, iconKey);
	    	ResultSet rs = pstmt.executeQuery();
	    	
	    	ArrayList<String> usernames = new ArrayList<String>();
	    	while (rs.next()){
	    		usernames.add(rs.getString("username"));
	    	}
	    	
	    	return usernames;
        }
    	catch (SQLException e) {
  			throw new DatabaseException(DatabaseException.DATABASE_QUERY_ERROR, e);
  		}
  		finally {
  			dbManager.closeStatement(pstmt);
  		}
    }
}

