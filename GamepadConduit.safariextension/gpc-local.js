(function() {

var gamepads_s = [];
var nextGamepadIndex_s = 0;


function GamepadButtonPrototype() {
	this.value = 0;
	this.pressed = false;
}
window.GamepadButton = GamepadButtonPrototype;


function GamepadPrototype() {
	var index = nextGamepadIndex_s++;

	this.id = "Ultimate Gamepad Pro " + index;
	this.index = index;
	this.connected = true;
	this.timestamp = performance.now();
	this.mapping = "standard";

	this.axes = [0,0,0, 0,0,0];
	this.buttons = [];
	for (var i = 0; i < 16; ++i) {
		this.buttons.push(new GamepadButton());
	}

	gamepads_s.push(this);
}
window.Gamepad = GamepadPrototype;


function GamepadEventPrototype() {
}
window.GamepadEvent = GamepadEventPrototype;


navigator.getGamepads = function() {
	return gamepads;
};

}());
