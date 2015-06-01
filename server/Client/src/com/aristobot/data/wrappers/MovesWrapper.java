package com.aristobot.data.wrappers;

import java.util.List;


import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlElementWrapper;
import javax.xml.bind.annotation.XmlRootElement;
@XmlRootElement(name="com.aristobot.data.MovesWrapper")
public class MovesWrapper {

	public String gameKey;
	
	@XmlElementWrapper(name="gameMoves")
    @XmlElement(name="String")
    public List<Object> gameMoves;
}
