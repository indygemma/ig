package tests;

import ig.aspects.Aspect;
import ig.aspects.AspectManager;
import ig.core.Actor;
import ig.core.ActorManager;

class MapItem extends Aspect {

    public function new( data ) {
        super();
    }

}

class Position extends Aspect {

    

}

class Wall extends Actor {

    public override function setup() {
        // TODO: make sure that the correct setup method is called
        // TODO: make sure that we can access these Aspect args
        this.name = "wall";
        this.aspects = [
            [MapItem, { id: 1 }],
            Position
        ];
    }
}

class AspectTest extends haxe.unit.TestCase {

    public function testAspect() {
        var wall1 = ActorManager.create(Wall);
        var location = wall1.getAspect(Position);
        assertEquals(1, 1);
    }
}
