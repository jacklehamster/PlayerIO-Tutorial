package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import playerio.Client;
	import playerio.Connection;
	import playerio.Message;
	import playerio.PlayerIO;
	import playerio.PlayerIOError;
	
	public class Tutorial extends Sprite
	{
		private var connection:Connection, client:Client;
		private var roomName:String;
		
		public function Tutorial(roomName:String="Paris")
		{
			this.roomName = roomName;
			var username:String = "user"+Math.random();
			var game_id:String = "dobukiland-ymhkxklve0qg9ksunqrsq";
			
			PlayerIO.connect(
				stage,								//Reference to stage
				game_id,							//Game id (Get your own at playerio.com. 1: Create user, 2:Goto admin pannel, 3:Create game, 4: Copy game id inside the "")
				"public",							//Connection id, default is public
				username,							//Username
				"",									//User auth. Can be left blank if authentication is disabled on connection
				null,								//Current PartnerPay partner.
				handleConnect,						//Function executed on successful connect
				handleError							//Function executed if we recive an error
			);
			
			addEventListener(Event.ADDED_TO_STAGE,onStage);
		}
		
		private function onStage(e:Event):void {
			stage.addEventListener(MouseEvent.CLICK,
				function(e:MouseEvent):void {
					send("Hello, World");
				});
		}
		
		private function handleError(error:PlayerIOError):void{
			log(error);
		}
		
		private function handleConnect(client:Client):void {
			log("Successfully connected to Yahoo Games Network");
			var roomType:String = "bounce";
			client.multiplayer.createJoinRoom(roomName,roomType,true,{game:"Tutorial"},{},onJoin,handleError);
		}
		
		private function onJoin(connection:Connection):void {
			log("Sucessfully joined room:",connection.roomId);
			this.connection = connection;	
			connection.addMessageHandler("send",
				function(m:Message,message:String):void {
					log(message);
					trace(message);
				}
			);
		}
		
		private function log(...params):void {
			trace.apply(params);
			var tf:TextField = getChildByName("tf") as TextField;
			if(!tf) {
				tf = new TextField();
				tf.name = "tf";
				tf.width = stage.stageWidth;
				tf.height = stage.stageHeight;
				tf.multiline = true;
				addChild(tf);
			}
			tf.appendText(params.join(" ")+"\n");			
		}
		
		public function send(message:String):void {
			connection.send("send",message);
		}
	}
}