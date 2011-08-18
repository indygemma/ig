package ig.aspects;

class Sleepable extends Aspect {

    var _duration:Int;
    var _counter:Int;

    public function new( duration ) {
        super();

        this.active = false;
        // duration
        _duration = duration;
        _counter = 1;
    }

    public override function update() {
        if (_counter >= _duration ) {
            this.deactivate();
        } else {
            _counter++;
        }
    }

    public override function activate() {
        super.activate();
        this.actor.skip_update = true;
        _counter = 1;
    }

    public override function deactivate() {
        super.deactivate();
        this.active = false;
        this.actor.skip_update = false;
        _counter = 1;
    }

}
