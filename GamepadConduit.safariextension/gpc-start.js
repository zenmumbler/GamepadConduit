// gpc-start - part of GamepadConduit
// (c) 2016 by Arthur Langereis (@zenmumbler)

if (document.contentType == "text/html") {

	// -- add data communications element
	var commsElem = document.createElement("meta");
	commsElem.name = "GPCData";
	commsElem.setAttribute("controllers", "[]");
	commsElem.setAttribute("active", "false");
	document.head.appendChild(commsElem);

	// -- inject Gamepad types and associated functions into client page
	var scel = document.createElement("script");
	scel.src = safari.extension.baseURI + "gpc-local.js";
	document.head.appendChild(scel);

	safari.self.addEventListener("message", function(event) {
		if (event.name === "controllerdata") {
			commsElem.setAttribute("controllers", event.message);
		}
		else if (event.name === "getpollstatus") {
			var active = commsElem.getAttribute("active");
			safari.self.tab.dispatchMessage("pollstatus", active);
		}
	}, false);

	console.info("GPC is go, apes.");

}
