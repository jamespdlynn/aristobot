package com.aristobot.managers;

import java.io.Serializable;
import java.util.HashMap;
import java.util.HashSet;

import net.sf.ehcache.CacheException;
import net.sf.ehcache.CacheManager;
import net.sf.ehcache.Ehcache;
import net.sf.ehcache.Element;

import com.aristobot.exceptions.AuthenticationException;
import com.aristobot.utils.Constants;

public class LocalCacheManager <T extends Serializable> {

	private static CacheManager cacheManager;
	private static HashMap<String, HashSet<String>> globalLocks;
	
	private String cacheName;
	private Ehcache cache;
	private HashSet<String> currentLocks;
	
	public static void initializeCache()
	{
		if (Constants.CACHE_ENABLED) 
        {
   			try{
   				cacheManager = CacheManager.newInstance(Constants.CACHE_CONFIG_PATH);
   			}
   			catch (Exception e){
   				LogManager.logException("Unable to load Cache Manager -- Disabling Cache", e);
   				Constants.CACHE_ENABLED = false;
   			}
		}
		
		globalLocks = new HashMap<String, HashSet<String>>();
	}
	
	public LocalCacheManager(String cacheName)
	{
		this.cacheName = cacheName;
		
		if (Constants.CACHE_ENABLED)
		{
			try{
				cache = cacheManager.getEhcache(cacheName);
			}
			catch (CacheException e) {
				LogManager.logException("Unable to load cache : "+cacheName, e);
			}
		}
		
		if (cache == null && !globalLocks.containsKey(cacheName)){
			globalLocks.put(cacheName, new HashSet<String>());
		}
		
		currentLocks = new HashSet<String>();
	}
	
	@SuppressWarnings(value = "unchecked")
	public T getFromCache(String key)
	{
		if (cache != null)
		{
			Element ele = cache.get(key);
			
			if (ele != null){
				return (T)ele.getValue();
			}
		}
		
		return null;
	}
	
	public void saveToCache(String key, T item)
	{
		if (cache != null){
			cache.put(new Element(key, item));
		}
	}
	
	public void removeFromCache(String key){
		if (cache != null){
			cache.remove(key);
		}
	}
	
	public void acquireLock(String key) throws AuthenticationException
	{
		if (cache != null)
		{
			try
			{
				if (!cache.tryWriteLockOnKey(key, 3)){
					throw new AuthenticationException(AuthenticationException.DATA_LOCKED);
				}
			}
			catch (InterruptedException e){
				throw new AuthenticationException(AuthenticationException.DATA_LOCKED);
			}
		}
		else
		{
			HashSet<String> globalCacheLocks = globalLocks.get(cacheName);
			
			if (globalCacheLocks.contains(key)){
				throw new AuthenticationException(AuthenticationException.DATA_LOCKED);
			}
			else{
				globalCacheLocks.add(key);
			}
		}
		
		currentLocks.add(key);
	}
	
	public void releaseLock(String key)
	{
		if (cache != null){
			cache.releaseWriteLockOnKey(key);
		}
		else{
			globalLocks.get(cacheName).remove(key);
		}
		
		currentLocks.remove(key);
	}
	
	public void releaseCurrentLocks()
	{
		try{
			for (String lockKey : currentLocks){
				releaseLock(lockKey);
			}
			
			currentLocks.clear();
		}
		catch (Exception e){
			LogManager.logException("Error releasing cache locks", e);
		}
	}
	
}
