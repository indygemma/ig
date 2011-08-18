package ig.aspects;

import ig.core.Actor;

class Aspect {

    var _actor : Actor;
    var _dependencies : Array<Class<Aspect>>;
    var _active : Bool;

    public var actor(getActor, setActor) : Actor;
    public var dependencies(getDependencies, null) : Array<Class<Aspect>>;
    public var active(getActive, setActive) : Bool;

    public function new() {
        // aspects are updated only when they're active
        active = true;
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

    public function getActor() : Actor {
        return _actor;
    }

    public function setActor(actor:Actor) : Actor {
        _actor = actor;
        return _actor;
    }

    public function getDependencies() : Array<Class<Aspect>> {
        return _dependencies;
    }

    public function depends( aspect_class:Class<Aspect> ) {
        _dependencies.push(aspect_class);
    }

    public function getActive() { return _active; }
    public function setActive( active:Bool ) { _active = active; return _active; }

    public function activate() {
        this.active = true;
    }

    public function deactivate() {
        this.active = false;
    }
}
