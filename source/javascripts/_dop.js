(function() {
	"use strict";

	var doP = { version : '0.2.0' };

	var global = (function () { return this || (0 || eval)('this'); }());

	if (typeof module !== 'undefined' && module.exports) {
		module.exports = doP;
	} else if (typeof define === 'function' && define.amd) {
		define(function() { return doP; });
	} else {
		global.doP = doP;
	}

	doP.templateSettings = {
		evaluate:    	  /\{([\s\S]+?)\}/g,
		interpolate: 	  /\{=([\s\S]+?)\}/g,
		encode:      	  /\{!([\s\S]+?)\}/g,
		use:         	  /\{#([\s\S]+?)\}/g,
		define:      	  /\{##\s*([\w\.$]+)\s*(\:|=)([\s\S]+?)#\}\}/g,
		conditional:	  /\{\?(\?)?\s*([\s\S]*?)\}/g,
		varname: 'it',
		strip : true,
		append: true,
		selfcontained: false
	};

	function resolveDefs(c, block, def) {
		return ((typeof block === 'string') ? block : block.toString())
		.replace(c.define, function (m, code, assign, value) {
			if (code.indexOf('def.') === 0) {
				code = code.substring(4);
			}
			if (!(code in def)) {
				if (assign === ':') {
					def[code]= value;
				} else {
					eval("def['"+code+"']=" + value);
				}
			}
			return '';
		})
		.replace(c.use, function(m, code) {
			var v = eval(code);
			return v ? resolveDefs(c, v, def) : v;
		});
	}

	function unescape(code) {
		return  code.replace(/\\'/g, "'").replace(/\\\\/g,"\\").replace(/[\r\t\n]/g, ' ');
	}

	function encodeHTMLSource() {
		var encodeHTMLRules = { "&": "&#38;", "<": "&#60;", ">": "&#62;", '"': '&#34;', "'": '&#39;', "/": '&#47;' },
			matchHTML = /&(?!\\w+;)|<|>|\"|'|\//g;
		return function(code) {
			return code ? code.toString().replace(matchHTML, function(m) { return encodeHTMLRules[m] || m; }) : code;
		};
	}
	global.encodeHTML = encodeHTMLSource();

	var startend = { // optimal choice depends on platform/size of templates
		append: { start: "'+(",      end: ")+'",      startencode: "'+encodeHTML(" },
		split:  { start: "';out+=(", end: ");out+='", startencode: "';out+=encodeHTML("}
	};

	doP.template = function(tmpl, c, def) {
		c = c || doP.templateSettings;
		var cse = c.append ? startend.append : startend.split, str, needhtmlencode;

		if (c.use || c.define) {
			var olddef = global.def; global.def = def || {}; // workaround minifiers
			str = resolveDefs(c, tmpl, global.def);
			global.def = olddef;
		} else str = tmpl;

		str = ("var out='" + ((c.strip) ? str.replace(/\s*<!\[CDATA\[\s*|\s*\]\]>\s*|[\r\n\t]|(\/\*[\s\S]*?\*\/)/g, ''): str)
			.replace(/\\/g, '\\\\')
			.replace(/'/g, "\\'")
			.replace(c.interpolate, function(m, code) {
				return cse.start + unescape(code) + cse.end;
			})
			.replace(c.encode, function(m, code) {
				needhtmlencode = true;
				return cse.startencode + unescape(code) + cse.end;
			})
			.replace(c.conditional, function(m, elsecase, code) {
				return elsecase ?
					(code ? "';}else if(" + unescape(code) + "){out+='" : "';}else{out+='") :
					(code ? "';if(" + unescape(code) + "){out+='" : "';}out+='");
			})
			.replace(c.evaluate, function(m, code) {
				return "';" + unescape(code) + "out+='";
			})
			+ "';return out;")
			.replace(/\n/g, '\\n')
			.replace(/\t/g, '\\t')
			.replace(/\r/g, '\\r')
			.split("out+='';").join('')
			.split("var out='';out+=").join('var out=');

		if (needhtmlencode && c.selfcontained) {
			str = "var encodeHTML=("+ encodeHTMLSource.toString()+"());"+str;
		}
		try {
			return new Function(c.varname, str);
		} catch (e) {
			if (typeof console !== 'undefined') console.log("Could not create a template function: " + str);
			throw e;
		}
	};

	doP.compile = function(tmpl, def) {
		return doP.template(tmpl, null, def);
	};
}());
