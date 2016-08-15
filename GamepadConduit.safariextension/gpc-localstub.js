(function() {
// gpc-localstub - part of GamepadConduit
// (c) 2016 by Arthur Langereis (@zenmumbler)

if (! navigator.getGamepads) {
	navigator.getGamepads = function() {
		return [];
	};
}

}());
