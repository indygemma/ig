package tests;

import ig.aspects.Aspect;
import ig.aspects.AspectManager;
import ig.core.Actor;

class MapItem extends Aspect {

}

class Location extends Aspect {

}

class Wall extends Actor {

    public function setup() {
        this.name = "wall";
        this.aspects = [
            [MapItem, { id : 1 }],
            Location
        ];
    }
}

class AspectTest extends haxe.unit.TestCase {

    public function testAspect() {
        /*var wall1 = AspectManager.create("wall");*/
        assertEquals(1, 1);
    }
}
