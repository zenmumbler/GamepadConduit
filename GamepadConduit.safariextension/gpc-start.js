// gpc-start - part of GamepadConduit
// (c) 2016 by Arthur Langereis (@zenmumbler)

if (document.contentType == "text/html" && (location.protocol == "http:" || location.protocol == "https:")) {
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
		var active = commsElem.getAttribute("active");

		if ((active === "false") || (event.name === "getpollstatus")) {
			safari.self.tab.dispatchMessage("pollstatus", active);
		}
		else if (event.name === "controllerdata") {
			commsElem.setAttribute("controllers", event.message);
		}
	}, false);

	console.info("Installed GPC in " + location.href);
}
else {
	window.console && console.info("NOT installing GPC in incompatible document");
}
