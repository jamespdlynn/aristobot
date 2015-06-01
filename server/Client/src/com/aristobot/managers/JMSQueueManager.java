package com.aristobot.managers;

import java.io.Serializable;
import java.util.HashMap;
import java.util.LinkedHashSet;

import javax.jms.JMSException;
import javax.jms.ObjectMessage;
import javax.jms.Queue;
import javax.jms.QueueConnection;
import javax.jms.QueueConnectionFactory;
import javax.jms.Session;
import javax.naming.InitialContext;
import javax.naming.NamingException;

import com.aristobot.utils.Constants;
import com.aristobot.utils.Constants.QueueJDNI;

public class JMSQueueManager
{
	private InitialContext ctx;
	private QueueConnectionFactory queueConnectionFactory;
	private HashMap<QueueJDNI, JMSQueue> queueMap;
	
	
	public JMSQueueManager()
	{
		try{
			ctx = new InitialContext();
			queueConnectionFactory = (QueueConnectionFactory) ctx.lookup(Constants.QUEUE_CONNECTION_FACTORY_JDNI); 
		}
		catch (Exception e){
			LogManager.logException("Error Setting up Queue Connection Factory",e);
		}
		
		queueMap = new HashMap<Constants.QueueJDNI, JMSQueue>();
	}

	
	public void queueItem(QueueJDNI queueType, Serializable item)
	{
		try{
			if (!item.getClass().equals(queueType.getDataClass())){
				throw new Exception("Data item type does not match Queue Data Type");
			}
			
			getJMSQueue(queueType).queueItem(item);
		}
		catch (Exception e){
			LogManager.logException("Unable to queue item", e);
		}
	}
	
	public void sendItem(QueueJDNI queueType, Serializable item)
	{
		try{
			if (!item.getClass().equals(queueType.getDataClass())){
				throw new Exception("Data item type does not match Queue Data Type");
			}
			
			QueueConnection connection = queueConnectionFactory.createQueueConnection();
			Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
			
			getJMSQueue(queueType).sendItem(session, item);
			
			connection.close();
			
		}
		catch (Exception e){
			LogManager.logException("Unable to send item", e);
		}
	}
	
	
	
	public void sendQueuedItems() 
	{
		try{
			QueueConnection connection = queueConnectionFactory.createQueueConnection();
			Session session = connection.createSession(false, Session.AUTO_ACKNOWLEDGE);
			
			for (JMSQueue queue : queueMap.values()){
				queue.sendQueuedItems(session);
			}
			
			queueMap.clear();
			
			connection.close();
		}
		catch (Exception e){
			LogManager.logException("Error establising queue connection",e);
		}

	}
	
	private JMSQueue getJMSQueue(QueueJDNI queueType) throws NamingException
	{
		//Create the Queue if it does not exist yet
		if (!queueMap.containsKey(queueType)){
			Queue queue = (Queue) ctx.lookup(queueType.getJdniName());
			queueMap.put(queueType, new JMSQueue(queue));
		}
		
		return queueMap.get(queueType);
	}
	
	private class JMSQueue
	{
		protected LinkedHashSet<Serializable> itemList;
		protected Queue queue;
		
		public JMSQueue(Queue queue)
		{
			this.queue = queue;
			itemList = new LinkedHashSet<Serializable>();
		}
		
		
		public void queueItem(final Serializable item)
		{
			itemList.add(item);
		}
		
		
		public void sendItem(final Session session, final Serializable item)
		{
			try{
				ObjectMessage msg = session.createObjectMessage(item);
				session.createProducer(queue).send(msg);
			}
			catch (JMSException e){
				LogManager.logException("Error sending item "+item.toString(), e);
			}
		}
		
		public void sendQueuedItems(final Session session)
		{
			for (Serializable obj : itemList){
				sendItem(session, obj);
			}
		
			itemList.clear();
		}
	}
	

}
