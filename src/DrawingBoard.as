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
	
	public class DrawingBoard extends Sprite
	{
		private var connection:Connection, client:Client;
		private var roomName:String;
		
		public function DrawingBoard(roomName:String="Paris")
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
			var color:uint = uint(uint.MAX_VALUE*Math.random());
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN,
				function(e:MouseEvent):void {
					connection.send("penDown",e.stageX,e.stageY);
				});
			stage.addEventListener(MouseEvent.MOUSE_MOVE,
				function(e:MouseEvent):void {
					if(e.buttonDown)
						connection.send("penMove",e.stageX,e.stageY,color);
				});
		}
		
		private function penDown(x:Number,y:Number):void {
			graphics.moveTo(x,y);
		}
		
		private function penMove(x:Number,y:Number,color:uint):void {
			graphics.lineStyle(1,color);
			graphics.lineTo(x,y);
		}
		
		private function handleError(error:PlayerIOError):void{
			log(error);
		}
		
		private function handleConnect(client:Client):void {
			log("Successfully connected to Yahoo Games Network");
			var roomType:String = "bounce";
			client.multiplayer.createJoinRoom(roomName,roomType,true,{game:"DrawingBoard"},{},onJoin,handleError);
		}
		
		private function onJoin(connection:Connection):void {
			log("Sucessfully joined room:",connection.roomId);
			this.connection = connection;	
			connection.addMessageHandler("penDown",
				function(m:Message,x:Number,y:Number):void {
					penDown(x,y);
				});
			connection.addMessageHandler("penMove",
				function(m:Message,x:Number,y:Number,color:uint):void {
					penMove(x,y,color);
				});
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
				tf.mouseEnabled = false;
				addChild(tf);
			}
			tf.appendText(params.join(" ")+"\n");			
		}
	}
}