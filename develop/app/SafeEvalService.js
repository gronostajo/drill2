/*!
 Based on types.js v0.314 | http://code.google.com/p/obremsdk/ | BSD 2-Clause
 Stripped down to SafeEval() and dependencies only.
 */

(function () {

	var app = angular.module('DrillApp');


	app.service('SafeEvalService', function () {
		this.eval = function (oneliner, variables) {

			var InArray = function (a, v, skip, nm) {
				var i;

				if (null == a || Array !== a.constructor || 0 === a.length)
					return false;

				if (null == skip || skip < 0 || skip >= a.length) {
					for (i = 0; i < a.length; i++)
						if (a[i] == v)
							return true;
				}
				else if (null != nm) {
					for (i = 0; i < skip; i++)
						if (a[i][nm] == v)
							return true;

					for (i = 1 + skip; i < a.length; i++)
						if (a[i][nm] == v)
							return true;
				}
				else {
					for (i = 0; i < skip; i++)
						if (a[i] == v)
							return true;

					for (i = 1 + skip; i < a.length; i++)
						if (a[i] == v)
							return true;
				}

				return false;

			}; // InArray()

			var FilterScript = function (s, filter) {
				var wi = 0;	// last written index
				var sb = [];	// string builder
				var i = -1;	// general indexer
				var pts = 0;	// parenthesis count ( )
				var fst = 0;	// started for statement?  alters use of parens/semi
				var sts = 0;	// statement status (0 = new, 1 = started)
				var bcs = 0;	// braces count { }
				var bks = 0;	// brackets count [ ]
				var nte = 0;	// next type expected: 0==identifer, 1==operator

				// 'for' is safe but it has special handling
				var safe_keywords = ["if", "else", "while", "do", "break",
					"function", "return", "var", "switch", "case", "default",
					"null", "undefined"];
				var bad_keywords = ["eval", "new", "this", "arguments"];

				if (null == filter)
					filter = function FilterScript_filter(s, i) {
						throw Error(
							"Disallowed identifier " + s + " @ " + i);
					};

				for (var ri = 0; ri < s.length; ri++) {
					var c = s.charCodeAt(ri);

					// skip white space
					if (0x20 === c || 0x0D === c || 0x0A === c || 0x09 === c) {
						for (i = ri + 1; i < s.length; i++) {
							c = s.charCodeAt(i);
							if (0x20 !== c && 0x0D !== c && 0x0A !== c && 0x09 !== c)
								break;
						}
						ri = i - 1;
					}
					// identifier or keyword
					else if (0x24 === c || 0x5F === c ||	// '$' or '_'
						(c >= 0x41 && c <= 0x5A) ||	// A-Z
						(c >= 0x61 && c <= 0x7A))	// a-z
					{
						for (i = ri + 1; i < s.length; i++) {
							c = s.charCodeAt(i);

							if (0x24 === c || 0x5F === c ||	// '$' || '_'
								(c >= 0x41 && c <= 0x5A) ||	// A-Z
								(c >= 0x61 && c <= 0x7A) ||	// a-z
								(c >= 0x30 && c <= 0x39))	// 0-9
							{
								// continue
							}
							else {
								break;
							}
						}

						var key = s.slice(ri, i);
						if (InArray(bad_keywords, key))
							throw Error("Disallowed Keyword '" + key + "' @ " + ri);

						if ("for" === key) {
							if (0 !== sts)
								throw Error("Unexpected keyword for @ " + ri);
							fst = 1;
							nte = 0;
						}
						else if (InArray(safe_keywords, key)) {
							if (0 !== sts && "function" !== key)
								throw Error("Unexpected keyword '" + key + "' @ " + ri);
							nte = 0;
						}
						else {
							if (ri - wi > 0)
								sb.push(s.slice(wi, ri));
							wi = i;

							var txt = filter(key, ri);
							sb.push(txt);
							nte = 1;
						}

						sts++;
						ri = i - 1;
					}
					// literal string ("" or '')
					else if (0x22 === c || 0x27 === c) {
						sts++;
						if (1 === nte)
							throw Error("Unexpected Start of String @ " + ri);

						var qc = c;
						for (i = ri + 1; i < s.length; i++) {
							c = s.charCodeAt(i);

							// backslash is for escape, skip the NEXT character
							if (0x5C === c)
								i++;
							else if (qc === c)
								break;
						}
						ri = i;
						nte = 1;
					}
					// literal number
					else if (c >= 0x30 && c <= 0x39) {
						sts++;
						if (1 === nte)
							throw Error("Unexpected Number Literal '" +
							s.charAt(ri) + "' @ " + ri + " (" + s + ")");

						var period = 0;
						for (i = ri + 1; i < s.length; i++) {
							c = s.charCodeAt(i);
							if (0x2E === c && (++period > 1))
								break;
							else if (c < 0x30 || c > 0x39)
								break;
						}
						ri = i - 1;
						nte = 1;
					}
					// semi-colon (end of statement), colon (end of select case),
					// or comma (next statement)
					else if (0x3B === c || 0x3A === c || 0x2C === c) {
						// a semi-colon/comma should not follow an operator
						if (0 === nte && sts > 1)
							throw Error("Unexpected Semi-Colon/Comma @ " + ri);

						if (0x3B === c)
							sts = 0;

						nte = 0;
					}
					// braces
					else if (0x7B === c || 0x7D === c) {
						// open {
						if (0x7B === c) {
							bcs++;
							if (bcs > 10)
								throw Error("Too Many Open Braces @ " + ri);
						}
						// close }
						else {
							bcs--;
							if (bcs < 0)
								throw Error("Unexpected Close Brace @ " + ri);
						}

						nte = 0;
						fst = 0;
						sts = 0;
					}
					// begin parenthesis
					else if (0x28 === c) {
						pts++;
						if (pts > 10)
							throw Error("Too Many Open Parens @ " + ri);

						nte = 0; // always expect identifier after open paren
					}
					// end parenthesis
					else if (0x29 === c) {
						pts--;
						if (pts < 0)
							throw Error("Extra Close Paren @ " + ri);

						nte = 1; // always expect operator after close paren
					}
					// forward slash: regular expression, division, comment?
					else if (0x2F === c) {
						// comment, skip to end of line
						if (c === s.charCodeAt(ri + 1)) {
							for (i = ri + 2; i < s.length; i++) {
								c = s.charCodeAt(i);
								if (0xD === c || 0xA === c)
									break;
							}
							ri = i;
						}
						// block comment, skip to end of block (*/)
						else if (0x2A === s.charCodeAt(ri + 1)) {
							for (i = ri + 2; i < s.length; i++) {
								if (0x2A === s.charCodeAt(i) &&
									0x2F === s.charCodeAt(i + 1))
									break;
							}
							ri = i + 1;
						}
						// expecting operator, assume division symbol
						else if (1 === nte) {
							nte = 0;
						}
						// expecting identifier, parse regular expression
						else {
							for (i = ri + 1; i < s.length; i++) {
								c = s.charCodeAt(i);
								if (0x5C === c)
									i++;
								else if (0x2F === c)
									break;
							}

							// g, i, m
							var flags = {};
							for (i++; i < s.length; i++) {
								c = s.charCodeAt(i);
								if (0x67 === c || 0x69 === c || 0x6D === c) {
									if (undefined !== flags[c])
										throw Error("RegExp flag '" + s.charAt(i) +
										"' defined twice @ " + i);
									flags[c] = 1;
								}
								else {
									break;
								}
							}

							ri = i - 1;
							nte = 1;
						}
					}
					// open square bracket
					else if (0x5B === c) {
						// a bracket can mean the beginning of an Array declaration OR
						// a subscript, so it can follow anything (1 or 0 nte)
						bks++;
						nte = 0;
					}
					// close square bracket
					else if (0x5D === c) {
						bks--;
						if (bks < 0)
							throw Error("Unexpected Close Bracket @ " + ri);
						nte = 1;
					}
					// minus operator or negative number
					else if (0x2D === c) {
						// doubled
						if (c == s.charCodeAt(ri + 1)) {
							// wanted identifier, not op!
							if (0 === nte)
								throw Error("Unexpected Decrement Op @ " + ri);
							ri++;
							nte = 1;
						}
						else {
							nte = 0;
						}
					}
					// operator (possible double character)
					else if (0x3C === c ||	// '<'
						0x3D === c ||	// '='
						0x3E === c ||	// '>'
						0x26 === c ||	// '&'
						0x2B === c ||	// '+'
						0x7C === c)		// '|'
					{
						if (1 !== nte)
							throw Error("Unexpected Operator @ " + ri + " (" + s + ")");

						// doubled
						if (c === s.charCodeAt(ri + 1)) {
							ri++;

							// increment operator is followed by another operator (or end
							// of statement) which is different from the other double-char
							// operators (except '--' which is handled above this 'if')
							if (0x2B === c)
								nte = 1;
							else
								nte = 0;
						}
						else if (0x3D === s.charCodeAt(ri + 1)) {
							if (0x3C !== c && 0x3E !== c)
								throw Error("Unexpected '=' Operator @ " + ri +
								" (" + s + ")");

							ri++;
							nte = 0;
						}
						else {
							nte = 0;
						}
					}
					// operator (not equal)
					else if (0x21 === c)		// '!'
					{
						if (1 !== nte)
							throw Error("Unexpected Operator @ " + ri + " (" + s + ")");

						if (0x3D === s.charCodeAt(ri + 1)) // '='
							ri++;

						nte = 0;
					}
					// operator (single only)
					else if (0x25 === c ||	// '%'
						0x2A === c ||	// '*'
						0x2E === c ||	// '.'
						0x3F === c ||	// '?'
						0x5E === c)		// '^'
					{
						if (1 !== nte)
							throw Error("Unexpected Operator @ " + ri);

						nte = 0;
					}
					else {
						throw Error("Unexpected code 0x" + c.toString(16) + " @ " + ri);
					}

				} // for (ri; enumerate all character codes in string)

				if (s.length - wi > 0)
					sb.push(s.substr(wi, s.length));

				return sb.join("");

			}; // FilterScript()

			var SafeEval = function (s, filter) {
				var filtered = FilterScript(s, filter);
				return eval(filtered);

			}; // SafeEval()


			return SafeEval(oneliner, variables);

		}

	});

})();
