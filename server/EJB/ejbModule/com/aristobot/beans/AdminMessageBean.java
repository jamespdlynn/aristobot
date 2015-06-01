package com.aristobot.beans;

import javax.ejb.ActivationConfigProperty;
import javax.ejb.EJB;
import javax.ejb.MessageDriven;
import javax.jms.Message;
import javax.jms.MessageListener;
import javax.jms.ObjectMessage;

import com.aristobot.data.AdminTask;
import com.aristobot.managers.LogManager;

/**
 * Message-Driven Bean implementation class for: MailMessageBean
 *
 */
@MessageDriven(mappedName="jms/adminQueue",
			   activationConfig = { @ActivationConfigProperty(propertyName = "destinationType", propertyValue = "javax.jms.Queue")}
			  )
public class AdminMessageBean implements MessageListener {

	@EJB
	private AdminBean adminBean;
	
	
    public void onMessage(Message message) {
    	
    	try{
    		AdminTask adminTask = (AdminTask)((ObjectMessage)message).getObject();
    		switch (adminTask.task)
    		{
    				
    			case CLEAN:
    				adminBean.clean();
    				adminBean.sendQueuedItems();
    				break;
    				
    			case SEND_PENDING_NOTIFICATIONS:
    				adminBean.sendQueuedItems();
    				break;
    				
    			case UPDATE_RANKINGS:
    				int applicationId = (Integer)adminTask.data;
    				adminBean.updateRankings(applicationId);
    				break;
    				    				
    			default:
    				LogManager.log("Received unknown admin task: "+adminTask.task);
    				break;
    		}
    	}
        catch (Exception e){
        	LogManager.logException("Error parsing Admin Message",e);
        }
        
    }
    
    

   
}
