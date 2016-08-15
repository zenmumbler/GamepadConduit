// gpc-beforeload - part of GamepadConduit
// (c) 2016 by Arthur Langereis (@zenmumbler)

if (document.contentType == "text/html" && (location.protocol == "http:" || location.protocol == "https:")) {
	function checkHeadBody() {
		if (document.head || document.body) {
			if (! navigator.getGamepads) {
				var elem = document.head || document.body;
				var scel = document.createElement("script");
				scel.src = safari.extension.baseURI + "gpc-localstub.js";
				elem.appendChild(scel);
				console.info("Installed GPC STUB");
			}
		}
		else {
			setTimeout(checkHeadBody, 1);
		}
	}

	checkHeadBody();
}
