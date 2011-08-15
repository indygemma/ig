package ig.core;

import ig.core.Application;

class GameState {
    var app : Application;

    public function new() {

    }

    /*
    * onInit - called when registering the current GameState
    *          to the running application.
    */
    public function onInit() {
        // TODO: may need to add ability to supply args/kwargs
        //       that is executed at a later time.

    }

    /*
    * onUpdate - do something every tick of the game
    */
    public function onUpdate() {

    }

    /*
    * onShutdown - do some cleanup either when the application is
    *              shut down or the state is being changed.
    */
    public function onShutdown() {

    }
}
