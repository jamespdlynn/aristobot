package com.aristobot.filters;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

import com.aristobot.utils.Utility;

public class ServletContextInitializer implements ServletContextListener {


	@Override
	public void contextInitialized(ServletContextEvent sce) {
		Utility.initialize();
	}
	
	@Override
	public void contextDestroyed(ServletContextEvent sce) {
		// TODO Auto-generated method stub
	}

}
