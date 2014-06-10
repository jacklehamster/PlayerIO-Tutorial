package
{
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.TextEvent;
	import flash.text.TextField;
	
	import playerio.Client;
	import playerio.PlayerIO;
	import playerio.PlayerIOError;
	import playerio.RoomInfo;
	
	public class Lobby extends Sprite
	{
		static private const roomType:String = "bounce";

		private var client:Client;
		public function Lobby()
		{
			var username:String = "user"+Math.random();
			var game_id:String = "dobukiland-ymhkxklve0qg9ksunqrsq";
			var color:uint = uint(uint.MAX_VALUE*Math.random());
			
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
		}
		
		private function handleError(error:PlayerIOError):void{
			log(error);
		}
		
		private function handleConnect(client:Client):void {
			log("Successfully connected to Yahoo Games Network");
			this.client = client;
			listRooms(roomType);
		}
		
		private function listRooms(roomType:String,gameType:String=null):void {
			log("==== list rooms ==== " + (gameType?gameType:""));
			log("Filter rooms by: ",
				gameType=="Tutorial"?"[ Tutorial ]":"[ <a href='event:filter:Tutorial'><u><font color='#0000FF'>Tutorial</font></u></a> ]",
				gameType=="ShootEmUp"?"[ ShootEmUp ]":"[ <a href='event:filter:DrawingBoard'><u><font color='#0000FF'>DrawingBoard</font></u></a> ]",
				gameType=="ShootEmUp"?"[ ShootEmUp ]":"[ <a href='event:filter:ShootEmUp'><u><font color='#0000FF'>ShootEmUp</font></u></a> ]"
			);
			log("Create room for: ",
				"[ <a href='event:create:Tutorial'><u><font color='#0000FF'>Tutorial</font></u></a> ]",
				"[ <a href='event:create:DrawingBoard'><u><font color='#0000FF'>DrawingBoard</font></u></a> ]",
				"[ <a href='event:create:ShootEmUp'><u><font color='#0000FF'>ShootEmUp</font></u></a> ]"
			);
			
			client.multiplayer.listRooms(roomType,gameType?{game:gameType}:{},100,0,onListRooms);
		}
		
		private function onListRooms(array:Array):void {
			for each(var room:RoomInfo in array) {
				if(room.data.game)
					log("<a href='event:join:"+room.data.game+":"+room.id+"'><u><font color='#0000FF'>"+room.data.game+" ("+room.onlineUsers+")"+"</font></u></a>");
			}
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
				tf.addEventListener(TextEvent.LINK,onLink);
//				tf.mouseEnabled = false;
				addChild(tf);
			}
			tf.htmlText += params.join("&nbsp;") + "<br>";
		}
		
		private function get self():Lobby {
			return this;
		}
		
		private function randomRoom(base:String):String {
			return base+Math.random();
		}
		
		private function onLink(e:TextEvent):void {
			var commands:Array = e.text.split(":");
			var stage:Stage = self.stage;
			switch(commands[0]) {
				case "join":
					switch(commands[1]) {
						case "DrawingBoard":
							stage.removeChild(self);
							stage.addChild(new DrawingBoard(commands[2]));
							break;
						case "Tutorial":
							stage.removeChild(self);
							stage.addChild(new Tutorial(commands[2]));
							break;
						case "ShootEmUp":
							stage.removeChild(self);
							stage.addChild(new ShootEmUp(commands[2]));
							break;
					}
					break;
				case "create":
					switch(commands[1]) {
						case "DrawingBoard":
							stage.removeChild(self);
							stage.addChild(new DrawingBoard(randomRoom("DrawingBoard")));
							break;
						case "Tutorial":
							stage.removeChild(self);
							stage.addChild(new Tutorial(randomRoom("Tutorial")));
							break;
						case "ShootEmUp":
							stage.removeChild(self);
							stage.addChild(new ShootEmUp(randomRoom("ShootEmUp")));
							break;
					}
					break;
				case "filter":
					listRooms(roomType,commands[1]);
					break;
			}
		}
	}
}