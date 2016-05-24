// gpc-start - part of GamepadConduit - (c) 2016 by Arthur Langereis (@zenmumbler)
var el = document.createElement("span");
el.style.display = "none !important";
el.dataset.stuff = [1,2,3,4];
el.someRandomProperty = [5,6,7,8];
document.body.appendChild(el);

safari.self.addEventListener("message", function(event) {
	console.info("Got msg from global: ", event.message);
}, false);

console.info("gpc is go, apes.");
