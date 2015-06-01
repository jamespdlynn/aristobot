package com.aristobot.as3srserrvice.model
{
	import com.aristobot.as3srserrvice.events.FaultEvent;
	import com.aristobot.as3srserrvice.events.ResultEvent;
	import com.aristobot.as3srserrvice.services.AdminService;
	import com.aristobot.as3srserrvice.services.AuthenticationService;
	import com.aristobot.as3srserrvice.services.GameService;
	import com.aristobot.as3srserrvice.services.IconService;
	import com.aristobot.as3srserrvice.services.LogService;
	import com.aristobot.as3srserrvice.services.MessageService;
	import com.aristobot.as3srserrvice.services.OpponentService;
	import com.aristobot.as3srserrvice.services.RestService;
	import com.aristobot.as3srserrvice.services.UserService;
	import com.aristobot.data.ChatMessage;
	import com.aristobot.data.ICustomGameObject;
	import com.aristobot.data.Tokens;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.getDefinitionByName;
	
	import mx.collections.ArrayList;

	public class ServiceModel extends EventDispatcher
	{

		public static const SERVICE_PRODUCTION_URL:String = "http://107.20.238.119:80/services/rest";
		public static const SERVICE_DEVELOPMENT_URL:String = "http://107.20.238.119:2080/services/rest";
		
		private static const SERVICE_VERSION_NUMBER:String = "1.38";
		
		private static var instance:ServiceModel;
		
		private var _serviceRootURL:String; 
		public function get serviceRootURL():String{
			return _serviceRootURL;
		}
		public function set serviceRootURL(value:String):void{
			unAuthenticate();
			_serviceRootURL = value;
		}
		
		private var _serviceVersionNumber:String;
		public function get serviceVersionNumber():String{
			return _serviceVersionNumber;
		}
		public function set serviceVersionNumber(value:String):void{
			unAuthenticate();
			_serviceVersionNumber = value;
		}
		
		private var _apiKey:String;
		public function get apiKey():String{
			return _apiKey;
		}
		public function set apiKey(value:String):void{
			unAuthenticate();
			_apiKey = value;
		}
				
		private var _accessToken:String;
		
		private var _tempServices:ArrayList;
		
		private var _cm:ChatMessage;
		
		private var _sessionExpirationDateTime:Number;
		public function get sessionExpirationDateTime():Number{
			return _sessionExpirationDateTime;
		}
		
		public function isAuthenticated():Boolean{
			if (!_accessToken) return false;

			return !sessionExpirationDateTime || sessionExpirationDateTime > new Date().time;
		}
		
		private var _defaultFaultHandler:Function;
		public function get defaultFaultHandler():Function{return _defaultFaultHandler;}
		public function set defaultFaultHandler(value:Function):void{_defaultFaultHandler = value;}
		
		private var _authenticationService:AuthenticationService;
		public function get authenticationService():AuthenticationService
		{
			if (!_apiKey) throw new Error("Authentication Service has not been instantiated. Call setUp() first");
			
			if (!_authenticationService){
				_authenticationService = new AuthenticationService(_serviceRootURL, _apiKey, _serviceVersionNumber);
				_authenticationService.addEventListener(ResultEvent.AUTHENTICATED, onAuthenticationSuccess, false, 0, true);
				_authenticationService.addEventListener(FaultEvent.UNHANLED_FAULT, onUnhandledFault, false, 0, true);
				
				_authenticationService.accessToken = _accessToken;
			}
			
			return _authenticationService;
		}
		
		private var _adminService:AdminService;
		public function get adminService():AdminService
		{
			if (!_apiKey) throw new Error("Admin Service has not been instantiated. Call setUp() first");
			
			if (!_adminService){
				_adminService = new AdminService(_serviceRootURL, _apiKey, _serviceVersionNumber);
				_adminService.addEventListener(ResultEvent.AUTHENTICATED, onAuthenticationSuccess, false, 0, true);
				_adminService.addEventListener(FaultEvent.UNHANLED_FAULT, onUnhandledFault, false, 0, true);
				
				_adminService.accessToken = _accessToken;
			}
			
			return _adminService;
		}
		
		private var _logService:LogService;
		public function get logService():LogService
		{
			if (!_apiKey) throw new Error("Log Service has not been instantiated. Call setUp() first");
			
			if (!_logService){
				_logService = new LogService(_serviceRootURL, _apiKey);
				_logService.accessToken = _accessToken;
			}
			
			return _logService;
		}
		
		public function get userService():UserService{
			if (!_accessToken) throw new Error("User Service has not been instantiated. Authenticate user first using the Authentication Service or .");
			
			var tempService:UserService = new UserService(_serviceRootURL, _apiKey, _accessToken);
			tempService.addEventListener(ResultEvent.RESULT, onSeviceCompleteHandler, false, 0, true);
			tempService.addEventListener(ResultEvent.RESULT, onSeviceCompleteHandler, false, 0, true);
			tempService.addEventListener(FaultEvent.UNHANLED_FAULT, onSeviceCompleteHandler, false, 0, true);			
			_tempServices.addItem(tempService);
			
			return tempService;
		}
		
		public function get opponentService():OpponentService{
			if (!_accessToken) throw new Error("Opponent Service has not been instantiated. Authenticate user first using the Authentication Service or .");
			var tempService:OpponentService = new OpponentService(_serviceRootURL, _apiKey, _accessToken);
			tempService.addEventListener(ResultEvent.RESULT, onSeviceCompleteHandler, false, 0, true);
			tempService.addEventListener(ResultEvent.RESULT, onSeviceCompleteHandler, false, 0, true);
			tempService.addEventListener(FaultEvent.UNHANLED_FAULT, onSeviceCompleteHandler, false, 0, true);			
			_tempServices.addItem(tempService);
			
			return tempService;
		}
		
		public function get gameService():GameService{
			if (!_accessToken) throw new Error("Game Service has not been instantiated. Authenticate user first using Authentication Service or .");
			var tempService:GameService = new GameService(_serviceRootURL, _apiKey, _accessToken);
			tempService.addEventListener(ResultEvent.RESULT, onSeviceCompleteHandler, false, 0, true);
			tempService.addEventListener(ResultEvent.RESULT, onSeviceCompleteHandler, false, 0, true);
			tempService.addEventListener(FaultEvent.UNHANLED_FAULT, onSeviceCompleteHandler, false, 0, true);			
			_tempServices.addItem(tempService);
			return tempService;
		}
		
		public function get iconService():IconService{
			if (!_accessToken) throw new Error("Icon Service has not been instantiated. Authenticate user first using Authentication Service or .");
			var tempService:IconService = new IconService(_serviceRootURL, _apiKey, _accessToken);
			tempService.addEventListener(ResultEvent.RESULT, onSeviceCompleteHandler, false, 0, true);
			tempService.addEventListener(ResultEvent.RESULT, onSeviceCompleteHandler, false, 0, true);
			tempService.addEventListener(FaultEvent.UNHANLED_FAULT, onSeviceCompleteHandler, false, 0, true);			
			_tempServices.addItem(tempService);
			return tempService;
		}
		
		public function get messageService():MessageService{
			if (!_accessToken) throw new Error("Update Service has not been instantiated. Authenticate user first using Authentication Service or .");
			var tempService:MessageService = new MessageService(_serviceRootURL, _apiKey, _accessToken);
			tempService.addEventListener(ResultEvent.RESULT, onSeviceCompleteHandler, false, 0, true);
			tempService.addEventListener(ResultEvent.RESULT, onSeviceCompleteHandler, false, 0, true);
			tempService.addEventListener(FaultEvent.UNHANLED_FAULT, onSeviceCompleteHandler, false, 0, true);			
			_tempServices.addItem(tempService);
			return tempService;
		}
				
		public function ServiceModel(enforcer:SingletonEnforcer){}
		
		public static function getInstance():ServiceModel
		{
			if (!instance){
				instance = new ServiceModel(new SingletonEnforcer());
			}
			return instance;
		}
		
		public function setUp(apiKey:String, defaultFaultHandler:Function = null, serviceRootURL:String=SERVICE_PRODUCTION_URL, serviceVersionNumber:String  = SERVICE_VERSION_NUMBER):void
		{
			unAuthenticate();
			
			_apiKey = apiKey;
			_serviceRootURL = serviceRootURL;
			_serviceVersionNumber = serviceVersionNumber;
			
			_defaultFaultHandler = defaultFaultHandler;
		}
		
		public function parseCustomGameObject(rawData:Object):ICustomGameObject
		{
			var customGameXML:XML = new XML(rawData);
			var customGameClass:Class = getDefinitionByName(customGameXML.name()) as Class;
			
			var customGameObj:ICustomGameObject =  new customGameClass() as ICustomGameObject;
			customGameObj.unmarshall(customGameXML);
			
			return customGameObj;
		}
		
		public function parseCustomGameObjects(dataArray:Array):Vector.<ICustomGameObject>
		{
			if (!dataArray || dataArray.length == 0) return null;
			
			var customObjArray:Vector.<ICustomGameObject> = new Vector.<ICustomGameObject>();
			
			for each (var dataString:String in dataArray){
				customObjArray.push(parseCustomGameObject(dataString));	
			}
			
			return customObjArray;
		}
		
		public function unAuthenticate():void
		{
			resetServices();
			_authenticationService = null;
			_logService = null;
			_accessToken = null;
		}
		
		
		public function resetServices():void
		{
			if (_authenticationService){
				_authenticationService.cancel();
			}
			
			if (_tempServices)
			{
				for each (var tempService:RestService in _tempServices.source){
					tempService.cancel();
				}
			}
			
			_tempServices = new ArrayList();
		}
		
		
		private function onAuthenticationSuccess(event:ResultEvent):void
		{
			var tokens:Tokens = event.resultObj as Tokens
			_accessToken = tokens.accessToken;		
			_sessionExpirationDateTime = (tokens.expirationTimeMinutes > 1) ? new Date().time + (tokens.expirationTimeMinutes-1)*60*1000 : null;	
			
			logService.accessToken = _accessToken;
		}
		
		private function onSeviceCompleteHandler(event:Event):void
		{
			if (event.type == FaultEvent.UNHANLED_FAULT){
				onUnhandledFault(event as FaultEvent);
			}
			
			_tempServices.removeItem(event.target);	
		}

		private function onUnhandledFault(event:FaultEvent):void
		{
			if (_defaultFaultHandler != null){
				_defaultFaultHandler(event);
			}
		}

	}
}

class SingletonEnforcer{}