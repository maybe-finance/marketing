// desandro-matches-selector@2.0.2 downloaded from https://ga.jspm.io/npm:desandro-matches-selector@2.0.2/matches-selector.js

var e={};(function(t,r){e?e=r():t.matchesSelector=r()})(window,(function factory(){var e=function(){var e=window.Element.prototype;if(e.matches)return"matches";if(e.matchesSelector)return"matchesSelector";var t=["webkit","moz","ms","o"];for(var r=0;r<t.length;r++){var o=t[r];var a=o+"MatchesSelector";if(e[a])return a}}();return function matchesSelector(t,r){return t[e](r)}}));var t=e;export default t;

