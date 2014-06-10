package
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import playerio.Client;
	import playerio.Connection;
	import playerio.Message;
	import playerio.PlayerIO;
	import playerio.PlayerIOError;
	
	public class ShootEmUp extends Sprite
	{
		private var connection:Connection, client:Client;
		private var ships:Object = {}, missiles:Object = {}, gameOver:Boolean = false;
		private var roomName:String;
		
		public function ShootEmUp(roomName:String="Paris")
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
			stage.addEventListener(MouseEvent.MOUSE_DOWN,
				function(e:MouseEvent):void {
					if(connection && !gameOver)
						connection.send("shoot",e.stageX,e.stageY,client.connectUserId);
				});
			stage.addEventListener(MouseEvent.MOUSE_MOVE,
				function(e:MouseEvent):void {
					if(connection && !gameOver) {
						connection.send("moveShip",e.stageX,e.stageY,client.connectUserId);
						moveShip(e.stageX,e.stageY,client.connectUserId);
					}
				});
			addEventListener(Event.ENTER_FRAME,animateScene);
		}
		
		private function animateScene(e:Event):void {
			graphics.clear();
			for each(var ship:Object in ships) {
				graphics.lineStyle(1,ship.color);
				graphics.moveTo(ship.x,ship.y-10);
				graphics.lineTo(ship.x+10,ship.y);
				graphics.lineTo(ship.x,ship.y+10);
				graphics.lineTo(ship.x-10,ship.y);
				graphics.lineTo(ship.x,ship.y-10);
			}
			graphics.lineStyle(1,0xFF0000);
			for(var mid:String in missiles) {
				var missile:Object = missiles[mid];
				graphics.moveTo(missile.x,missile.y);
				graphics.lineTo(missile.x+missile.xmov,missile.y+missile.ymov);
				missile.x += missile.xmov;
				missile.y += missile.ymov;
				if(missile.x>stage.stageWidth || missile.x<0 || missile.y>stage.stageHeight || missile.y<0) {
					delete missiles[mid];
				}
			}
			
			if(client && ships[client.connectUserId] && !gameOver) {
				var myShip:Object = ships[client.connectUserId];
				var rect:Rectangle = new Rectangle(myShip.x-10,myShip.y-10,20,20);
				for each(missile in missiles) {
					if(rect.contains(missile.x,missile.y)) {
						//	ship has been hit
						gameOver = true;
						connection.send("gotHit",client.connectUserId);
						break;
					}
				}
			}
		}
		
		private function getShip(id:String):Object {
			return ships[id] ? ships[id]: (ships[id] = {color:uint(uint.MAX_VALUE*Math.random())});
		}
		
		private function moveShip(x:Number,y:Number,id:String):void {
			var ship:Object = getShip(id);
			ship.x = x;
			ship.y = y;
		}
		
		private function shoot(x:Number,y:Number,id:String):void {
			var ship:Object = getShip(id);
			ship.x = x;
			ship.y = y;
			createMissile(x,y,-10,0);
			createMissile(x,y,10,0);
			createMissile(x,y,0,10);
			createMissile(x,y,0,-10);
		}
		
		private function createMissile(x:Number,y:Number,xmov:Number,ymov:Number):void {
			missiles[Math.random()] = {x:x+xmov,y:y+ymov,xmov:xmov,ymov:ymov};
		}
		
		private function handleError(error:PlayerIOError):void{
			log(error);
		}
		
		private function handleConnect(client:Client):void {
			log("Successfully connected to Yahoo Games Network");
			this.client = client;
			var roomType:String = "bounce";
			client.multiplayer.createJoinRoom(roomName,roomType,true,{game:"ShootEmUp"},{},onJoin,handleError);
		}
		
		private function onJoin(connection:Connection):void {
			log("Sucessfully joined room:",connection.roomId);
			this.connection = connection;	
			connection.addMessageHandler("shoot",
				function(m:Message,x:Number,y:Number,id:String):void {
					shoot(x,y,id);
				});
			connection.addMessageHandler("moveShip",
				function(m:Message,x:Number,y:Number,id:String):void {
					if(id!=client.connectUserId)
						moveShip(x,y,id);
				});
			connection.addMessageHandler("gotHit",
				function(m:Message,id:String):void {
					delete ships[id];
					log("Ship",id,"has been destroyed!");
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