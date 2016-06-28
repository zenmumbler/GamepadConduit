// gpc-start - part of GamepadConduit
// (c) 2016 by Arthur Langereis (@zenmumbler)

if (document.contentType == "text/html") {

	// -- add data communications element
	var commsElem = document.createElement("meta");
	commsElem.name = "GPCData";
	commsElem.setAttribute("controllers", "[]");
	document.head.appendChild(commsElem);

	// -- inject Gamepad types and associated functions into client page
	var scel = document.createElement("script");
	scel.src = safari.extension.baseURI + "gpc-local.js";
	document.head.appendChild(scel);

	safari.self.addEventListener("message", function(event) {
		console.info("Got msg from global: ", Date.now(), event);
	}, false);


	console.info("gpc is go, apes.", typeof safari.extension, typeof safari.application);
}
