package tests;

import ig.aspects.Aspect;
import ig.aspects.AspectManager;
import ig.aspects.Sleepable;
import ig.core.Actor;
import ig.core.ActorManager;

class MapItem extends Aspect {

    public var x:Int;
    public var y:Int;

    public function new( x:Int, y:Int ) {
        super();

        this.x = x;
        this.y = y;
    }

    public override function update() {
        // take the position aspect of the actor
        // and modify it according to current
        // map x and map y values.
        var position = cast(this.actor.getAspect(Position), Position);
        position.set( this.x*100, this.y*100 );
    }

}

class Position extends Aspect {

    public var x:Int;
    public var y:Int;

    public function new() {
        super();

        x = 0;
        y = 0;
    }

    public function set( x:Int, y:Int ) {
        this.x = x;
        this.y = y;
    }

}

class Health extends Aspect {

    public var health : Float;

    public function new( amount:Float ) {
        super();

        health = amount;
    }

    public function isAlive() : Bool {
        return health > 0.0;
    }

    public function isDead() : Bool {
        return health == 0.0;
    }

    public function reduce( amount:Float ) {
        health -= amount;
    }

    public function increase( amount:Float ) {
        health += amount;
    }

}

class Poisonable extends Aspect {

    var _counter : Int;
    var _doWait : Bool;
    var _health : Health;
    var _duration : Int;
    var _damage : Int;
    var _wait : Int;

    public function new( duration:Int, damage:Int, wait:Int ) {
        super();

        this.active = false;
        _counter = 0;
        _doWait = false;
        _health = cast(this.actor.getAspect(Health), Health);
        _duration = duration;
        _damage = damage;
        _wait = wait;
    }

    public override function update() {
        switch (_doWait) {
            case true:
                if (_counter > _wait) {
                    _counter = 0;
                    _doWait = false;
                }
            case false:
                if (_counter > _duration) {
                    _counter = 0;
                    _doWait = true;
                } else {
                    _health.reduce(_damage);
                }
        }
        _counter++;
    }

}

class Flying extends Aspect {
    public function new( speed:Float ) {
        super();
    }
}

class Character extends Actor {
    public override function setup() {
        this.name = "character";
        this.aspects = [
            [Health, 10],
            Position,
            [Sleepable, [2]]
        ];
    }
}

class GhostCharacter extends Character {
    public override function setup() {
        super.setup();
        this.name = "ghost_character";
        this.removeAspect(Position);
    }
}

class StrongerCharacter extends Character {
    public override function setup() {
        super.setup();
        this.name = "stronger_character";
        this.changeAspect(Health, [20]);
    }
}

class FlyingCharacter extends Character {
    public override function setup() {
        super.setup();
        this.name = "flying_character";
        this.removeAspect(Position);
        this.addAspect(Flying, [25]);
    }
}

class Wall extends Actor {

    public var counter:Int;

    public override function setup() {
        this.counter = 0;
        // TODO: make sure that we can access these Aspect args
        // TODO: passing the arguments here is awkard atm, let the compiler
        //       find mistakes at compile time.
        // TODO: find a way to enable subclassing of this actor and taking
        //       the parents' aspects, and only overriding the required
        //       aspects.
        // TODO: use case: an Actor 'SleepTile', that puts anyone marching
        //       colliding with it to sleep with a 30% probability.
        // TODO: add "dependencies checking" for Actors at compile time.
        //       Each aspect supplies a list of required aspects that
        //       it depends on. If an Actor does not have any of them,
        //       it should result in a compilation error.
        this.name = "wall";
        this.aspects = [
            [MapItem, [1,2]],
            Position,
            [Sleepable, [2]] // can sleep for two update ticks
        ];
    }

    public override function preUpdate() {
        counter++;
    }

    public override function postUpdate() {

    }
}

class AspectTest extends haxe.unit.TestCase {

    public function testAspect() {

        var wall1:Wall = cast(ActorManager.create(Wall), Wall);
        var location = cast(wall1.getAspect(Position), Position);
        assertEquals(wall1.counter, 0);
        assertEquals(location.x, 0);
        assertEquals(location.y, 0);

        ActorManager.update();

        assertEquals(wall1.counter, 1);
        assertEquals(location.x, 100);
        assertEquals(location.y, 200);

        // from this point on the wall will sleep for two ticks
        cast(wall1.getAspect(Sleepable), Sleepable).activate();

        ActorManager.update();

        assertEquals(wall1.counter, 1);

        ActorManager.update();

        assertEquals(wall1.counter, 1);

        // the wall woke up again
        ActorManager.update();

        assertEquals(wall1.counter, 2);

        ActorManager.update();

        assertEquals(wall1.counter, 3);
    }
}
