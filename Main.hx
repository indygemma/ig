import Type;
import flash.display.Sprite;
import flash.display.Shape;
import flash.events.MouseEvent;
import flash.events.Event;

class BodyType {
    public static var CIRCLE = "circle";
}

class Entity {
    /* need a unique id */
    public static var id : Int;

    public function new() {
        id++;
    }
}

class Ball extends Entity {

    var _sprite : Sprite;
    var _shape  : Shape;

    public var x(getX, setX) : Float;
    public var y(getY, setY) : Float;

    public function new(width:Int, height:Int, ?sx:Int = 80, ?sy:Int = 80) {
        super();

        this._sprite = new Sprite();
        this._shape  = new Shape();

        flash.Lib.current.addChild(this._sprite);

        var orange = 0xff9933;
        var black = 0x000000;

        // creating a new shape instance
        this._shape = new Shape();
        // starting color filling
        this._shape.graphics.beginFill( black , 1 );
        // drawing circle 
        this._shape.graphics.drawCircle( 0 , 0 , 40 );
        // repositioning shape
        this._shape.x = sx;
        this._shape.y = sy;

        // adding displayobject to the display list
        this._sprite.addChild( this._shape );
    }

    public function getX() {
        return this._shape.x;
    }

    public function getY() {
        return this._shape.y;
    }

    public function setX(x:Float) {
        this._shape.x = x;
        return this._shape.x;
    }

    public function setY(y:Float) {
        this._shape.y = y;
        return this._shape.y;
    }

    public function updatePosFromEvent(e:MouseEvent) {
        this.x = e.stageX;
        this.y = e.stageY;
    }

    public function resetPos() {
        this.x = 0;
        this.y = 0;
    }
}

class GameLogic {

    var current_ball:Ball;
    var _isDown:Bool;

    public function new(ball:Ball) {
        /*flash.Lib.current.addEventListener(MouseEvent.CLICK, this.onMouseClick);*/
        /*flash.Lib.current.addEventListener(MouseEvent.MOUSE_DOWN, this.onMouseDown);*/
        /*flash.Lib.current.addEventListener(MouseEvent.MOUSE_UP, this.onMouseUp);*/
        flash.Lib.current.addEventListener(MouseEvent.MOUSE_MOVE, this.onMouseMove);
        this.current_ball = ball;
        this._isDown = false;
    }

    public function onMouseClick(e:MouseEvent) {
        trace("resetting position");
        this.current_ball.resetPos();
    }

    public function onMouseDown(e:MouseEvent) {
        this._isDown = true;
    }

    public function onMouseUp(e:MouseEvent) {
        this._isDown = false;
    }

    public function onMouseMove(e:MouseEvent) {
        if (e.buttonDown) {
            trace("moving " + e.type + " " + e.stageX + " " + e.stageY);
            this.current_ball.updatePosFromEvent(e);
            trace("ball: " + this.current_ball.x + " " + this.current_ball.y);
        }
    }
}

class GameWorld {

    var _world : phx.World;

    public function new(entities:Array<Entity>) {
        var size = new phx.col.AABB(-1000,-1000,1000,1000);
        var bf = new phx.col.SortedList();
        this._world = new phx.World(size, bf);

        var b1 = new phx.Body(210, -50);
        var b2 = new phx.Body(200, 250);

        b2.addShape( new phx.Circle(30, new phx.Vector(0,0)) );

        var b3 = new phx.Body(100, 270);
        trace(Type.getInstanceFields(phx.Body));
        b3.addShape( phx.Shape.makeBox(20,20) );

        var self = this;
        Lambda.map([b1,b2,b3], function(body) {
            self._world.addBody(body);
        });

        var floor = phx.Shape.makeBox(270, 50, 0, 280);
        this._world.addStaticShape(floor);
        this._world.gravity = new phx.Vector(0,0.9);

        flash.Lib.current.addEventListener(Event.ENTER_FRAME, this.loop);
    }

    public function loop(_) {
        this._world.step(1,20);
        var g = flash.Lib.current.graphics;
        g.clear();
        var fd = new phx.FlashDraw(g);
        fd.drawCircleRotation = true;
        fd.drawWorld(this._world);
    }

}

class Main extends Sprite {

   static public function main()
   {
      neash.Lib.Init("Simple",800,600); 
      neash.Lib.SetBackgroundColour(0x334433); 

      var ball:Ball = new Ball(20, 30);
      /*new GameLogic(ball);*/
      new GameWorld([cast(ball, Entity)]);

      neash.Lib.Run();
   }
}
