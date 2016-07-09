(function() {

var gamepads_s = [];
var nextGamepadIndex_s = 0;
var commsElem = null;
var lastGamepadDataString = "[]";


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

	this.axes = [0,0,0,0];
	this.buttons = [];
	for (var i = 0; i < 17; ++i) {
		this.buttons.push(new GamepadButton());
	}
}
window.Gamepad = GamepadPrototype;


function GamepadEventPrototype() {
}
window.GamepadEvent = GamepadEventPrototype;


navigator.getGamepads = function() {
	if (commsElem === null) {
		commsElem = document.querySelector('meta[name="GPCData"]');
		commsElem.setAttribute("active", true);
		return [];
	}
	else {
		var gamepadDataString = commsElem.getAttribute("controllers");

		if (gamepadDataString !== lastGamepadDataString) {
			lastGamepadDataString = gamepadDataString;
			var gamepadData = JSON.parse(gamepadDataString);

			if (gamepadData.length === 7) {
				if (gamepads_s.length === 0) {
					gamepads_s.push(new GamepadPrototype());
				}
				var gamepad0 = gamepads_s[0];
				var btnState = gamepadData[0];
				var stateMask = 1;

				// map button bit states to GamepadButton fields
				for (var btn = 0; btn < 17; ++btn) {
					var button = gamepad0.buttons[btn];

					// special case the triggers
					if (btn === 6) {
						button.value = gamepadData[5];
						button.pressed = gamepadData[5] > 0.6;
					}
					else if (btn === 7) {
						button.value = gamepadData[6];
						button.pressed = gamepadData[6] > 0.6;
					}
					else {
						if (btnState & stateMask) {
							button.value = 1;
							button.pressed = true;
						}
						else {
							button.value = 0;
							button.pressed = false;
						}
					}

					stateMask <<= 1;
				}

				// copy left and right axes
				gamepad0.axes[0] = gamepadData[1];
				gamepad0.axes[1] = gamepadData[2];
				gamepad0.axes[2] = gamepadData[3];
				gamepad0.axes[3] = gamepadData[4];

				gamepad0.timestamp = performance.now();
			}
		}

		return gamepads_s;
	}
};

}());
