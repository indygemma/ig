package ig.core;

import ig.core.GameState;

class Application {

    var _state : GameState;

    public var state(getState, changeState) : GameState;

    public function new() {
        _state = null;
    }

    public function changeState( new_state : Dynamic ) : GameState {
        if (_state != null) {
            _state.onShutdown();
            _state = null;
        }
        if (Std.is(new_state, GameState)) {
            _state = new_state;
        } else if (Reflect.isFunction(new_state)) {
            _state = new_state();
        }
        _state.onInit();
        return _state;
    }

    public function getState() : GameState {
        return _state;
    }

    /*
    * update - call this method every step to run the game
    */
    public function update() : Void {
        _state.onUpdate();
    }

    /*
    * shutdown - shutdown the whole application
    */
    public function shutdown() : Void {
        _state.onShutdown();
    }
}
