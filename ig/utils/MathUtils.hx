package ig.utils;

class MathUtils {
    public static function add() : Dynamic -> Dynamic -> Dynamic {
        return function(a,b) { return a+b; };
    }

    public static function subtract() : Dynamic -> Dynamic -> Dynamic {
        return function(a,b) { return a-b; };
    }
}
