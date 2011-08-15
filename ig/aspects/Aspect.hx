package ig.aspects;

import ig.core.Actor;

class Aspect {

    var _actor : Actor;

    public var actor(getActor, setActor) : Actor;

    public function new() {

    }

    /*
    * setup - called when the aspect is created on
    *         actor construction. Setup anything
    *         that is required by subclass aspects
    *         here after their construction.
    */
    public function setup() {

    }

    /*
    * postSetup - called after every aspect inside an
    *             actor has been setup
    */
    public function postSetup() {

    }

    /*
    * update - called every iteration. Always to be
    *          re-implemented by subclasses.
    */
    public function update() {

    }

    public function setActor(actor:Actor) : Actor {
        _actor = actor;
        return _actor;
    }

    public function getActor() : Actor {
        return _actor;
    }
}
