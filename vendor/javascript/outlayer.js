// outlayer@2.1.1 downloaded from https://ga.jspm.io/npm:outlayer@2.1.1/outlayer.js

import t from"ev-emitter";import i from"get-size";import e from"fizzy-ui-utils";var n="undefined"!==typeof globalThis?globalThis:"undefined"!==typeof self?self:global;var s={};(function(e,n){if(s)s=n(t,i);else{e.Outlayer={};e.Outlayer.Item=n(e.EvEmitter,e.getSize)}})(window,(function factory(t,i){function isEmptyObj(t){for(var i in t)return false;i=null;return true}var e=document.documentElement.style;var s="string"==typeof e.transition?"transition":"WebkitTransition";var o="string"==typeof e.transform?"transform":"WebkitTransform";var r={WebkitTransition:"webkitTransitionEnd",transition:"transitionend"}[s];var a={transform:o,transition:s,transitionDuration:s+"Duration",transitionProperty:s+"Property",transitionDelay:s+"Delay"};function Item(t,i){if(t){(this||n).element=t;(this||n).layout=i;(this||n).position={x:0,y:0};this._create()}}var h=Item.prototype=Object.create(t.prototype);h.constructor=Item;h._create=function(){(this||n)._transn={ingProperties:{},clean:{},onEnd:{}};this.css({position:"absolute"})};h.handleEvent=function(t){var i="on"+t.type;(this||n)[i]&&this[i](t)};h.getSize=function(){(this||n).size=i((this||n).element)};h.css=function(t){var i=(this||n).element.style;for(var e in t){var s=a[e]||e;i[s]=t[e]}};h.getPosition=function(){var t=getComputedStyle((this||n).element);var i=(this||n).layout._getOption("originLeft");var e=(this||n).layout._getOption("originTop");var s=t[i?"left":"right"];var o=t[e?"top":"bottom"];var r=parseFloat(s);var a=parseFloat(o);var h=(this||n).layout.size;-1!=s.indexOf("%")&&(r=r/100*h.width);-1!=o.indexOf("%")&&(a=a/100*h.height);r=isNaN(r)?0:r;a=isNaN(a)?0:a;r-=i?h.paddingLeft:h.paddingRight;a-=e?h.paddingTop:h.paddingBottom;(this||n).position.x=r;(this||n).position.y=a};h.layoutPosition=function(){var t=(this||n).layout.size;var i={};var e=(this||n).layout._getOption("originLeft");var s=(this||n).layout._getOption("originTop");var o=e?"paddingLeft":"paddingRight";var r=e?"left":"right";var a=e?"right":"left";var h=(this||n).position.x+t[o];i[r]=this.getXValue(h);i[a]="";var u=s?"paddingTop":"paddingBottom";var l=s?"top":"bottom";var f=s?"bottom":"top";var m=(this||n).position.y+t[u];i[l]=this.getYValue(m);i[f]="";this.css(i);this.emitEvent("layout",[this||n])};h.getXValue=function(t){var i=(this||n).layout._getOption("horizontal");return(this||n).layout.options.percentPosition&&!i?t/(this||n).layout.size.width*100+"%":t+"px"};h.getYValue=function(t){var i=(this||n).layout._getOption("horizontal");return(this||n).layout.options.percentPosition&&i?t/(this||n).layout.size.height*100+"%":t+"px"};h._transitionTo=function(t,i){this.getPosition();var e=(this||n).position.x;var s=(this||n).position.y;var o=t==(this||n).position.x&&i==(this||n).position.y;this.setPosition(t,i);if(!o||(this||n).isTransitioning){var r=t-e;var a=i-s;var h={};h.transform=this.getTranslate(r,a);this.transition({to:h,onTransitionEnd:{transform:(this||n).layoutPosition},isCleaning:true})}else this.layoutPosition()};h.getTranslate=function(t,i){var e=(this||n).layout._getOption("originLeft");var s=(this||n).layout._getOption("originTop");t=e?t:-t;i=s?i:-i;return"translate3d("+t+"px, "+i+"px, 0)"};h.goTo=function(t,i){this.setPosition(t,i);this.layoutPosition()};h.moveTo=h._transitionTo;h.setPosition=function(t,i){(this||n).position.x=parseFloat(t);(this||n).position.y=parseFloat(i)};h._nonTransition=function(t){this.css(t.to);t.isCleaning&&this._removeStyles(t.to);for(var i in t.onTransitionEnd)t.onTransitionEnd[i].call(this||n)};h.transition=function(t){if(parseFloat((this||n).layout.options.transitionDuration)){var i=(this||n)._transn;for(var e in t.onTransitionEnd)i.onEnd[e]=t.onTransitionEnd[e];for(e in t.to){i.ingProperties[e]=true;t.isCleaning&&(i.clean[e]=true)}if(t.from){this.css(t.from);var s=(this||n).element.offsetHeight;s=null}this.enableTransition(t.to);this.css(t.to);(this||n).isTransitioning=true}else this._nonTransition(t)};function toDashedAll(t){return t.replace(/([A-Z])/g,(function(t){return"-"+t.toLowerCase()}))}var u="opacity,"+toDashedAll(o);h.enableTransition=function(){if(!(this||n).isTransitioning){var t=(this||n).layout.options.transitionDuration;t="number"==typeof t?t+"ms":t;this.css({transitionProperty:u,transitionDuration:t,transitionDelay:(this||n).staggerDelay||0});(this||n).element.addEventListener(r,this||n,false)}};h.onwebkitTransitionEnd=function(t){this.ontransitionend(t)};h.onotransitionend=function(t){this.ontransitionend(t)};var l={"-webkit-transform":"transform"};h.ontransitionend=function(t){if(t.target===(this||n).element){var i=(this||n)._transn;var e=l[t.propertyName]||t.propertyName;delete i.ingProperties[e];isEmptyObj(i.ingProperties)&&this.disableTransition();if(e in i.clean){(this||n).element.style[t.propertyName]="";delete i.clean[e]}if(e in i.onEnd){var s=i.onEnd[e];s.call(this||n);delete i.onEnd[e]}this.emitEvent("transitionEnd",[this||n])}};h.disableTransition=function(){this.removeTransitionStyles();(this||n).element.removeEventListener(r,this||n,false);(this||n).isTransitioning=false};h._removeStyles=function(t){var i={};for(var e in t)i[e]="";this.css(i)};var f={transitionProperty:"",transitionDuration:"",transitionDelay:""};h.removeTransitionStyles=function(){this.css(f)};h.stagger=function(t){t=isNaN(t)?0:t;(this||n).staggerDelay=t+"ms"};h.removeElem=function(){(this||n).element.parentNode.removeChild((this||n).element);this.css({display:""});this.emitEvent("remove",[this||n])};h.remove=function(){if(s&&parseFloat((this||n).layout.options.transitionDuration)){this.once("transitionEnd",(function(){this.removeElem()}));this.hide()}else this.removeElem()};h.reveal=function(){delete(this||n).isHidden;this.css({display:""});var t=(this||n).layout.options;var i={};var e=this.getHideRevealTransitionEndProperty("visibleStyle");i[e]=(this||n).onRevealTransitionEnd;this.transition({from:t.hiddenStyle,to:t.visibleStyle,isCleaning:true,onTransitionEnd:i})};h.onRevealTransitionEnd=function(){(this||n).isHidden||this.emitEvent("reveal")};h.getHideRevealTransitionEndProperty=function(t){var i=(this||n).layout.options[t];if(i.opacity)return"opacity";for(var e in i)return e};h.hide=function(){(this||n).isHidden=true;this.css({display:""});var t=(this||n).layout.options;var i={};var e=this.getHideRevealTransitionEndProperty("hiddenStyle");i[e]=(this||n).onHideTransitionEnd;this.transition({from:t.visibleStyle,to:t.hiddenStyle,isCleaning:true,onTransitionEnd:i})};h.onHideTransitionEnd=function(){if((this||n).isHidden){this.css({display:"none"});this.emitEvent("hide")}};h.destroy=function(){this.css({position:"",left:"",right:"",top:"",bottom:"",transition:"",transform:""})};return Item}));var o=s;var r="undefined"!==typeof globalThis?globalThis:"undefined"!==typeof self?self:global;var a={};(function(n,s){a?a=s(n,t,i,e,o):n.Outlayer=s(n,n.EvEmitter,n.getSize,n.fizzyUIUtils,n.Outlayer.Item)})(window,(function factory(t,i,e,n,s){var o=t.console;var a=t.jQuery;var noop=function(){};var h=0;var u={};function Outlayer(t,i){var e=n.getQueryElement(t);if(e){(this||r).element=e;a&&((this||r).$element=a((this||r).element));(this||r).options=n.extend({},(this||r).constructor.defaults);this.option(i);var s=++h;(this||r).element.outlayerGUID=s;u[s]=this||r;this._create();var l=this._getOption("initLayout");l&&this.layout()}else o&&o.error("Bad element for "+(this||r).constructor.namespace+": "+(e||t))}Outlayer.namespace="outlayer";Outlayer.Item=s;Outlayer.defaults={containerStyle:{position:"relative"},initLayout:true,originLeft:true,originTop:true,resize:true,resizeContainer:true,transitionDuration:"0.4s",hiddenStyle:{opacity:0,transform:"scale(0.001)"},visibleStyle:{opacity:1,transform:"scale(1)"}};var l=Outlayer.prototype;n.extend(l,i.prototype);l.option=function(t){n.extend((this||r).options,t)};l._getOption=function(t){var i=(this||r).constructor.compatOptions[t];return i&&void 0!==(this||r).options[i]?(this||r).options[i]:(this||r).options[t]};Outlayer.compatOptions={initLayout:"isInitLayout",horizontal:"isHorizontal",layoutInstant:"isLayoutInstant",originLeft:"isOriginLeft",originTop:"isOriginTop",resize:"isResizeBound",resizeContainer:"isResizingContainer"};l._create=function(){this.reloadItems();(this||r).stamps=[];this.stamp((this||r).options.stamp);n.extend((this||r).element.style,(this||r).options.containerStyle);var t=this._getOption("resize");t&&this.bindResize()};l.reloadItems=function(){(this||r).items=this._itemize((this||r).element.children)};l._itemize=function(t){var i=this._filterFindItemElements(t);var e=(this||r).constructor.Item;var n=[];for(var s=0;s<i.length;s++){var o=i[s];var a=new e(o,this||r);n.push(a)}return n};l._filterFindItemElements=function(t){return n.filterFindElements(t,(this||r).options.itemSelector)};l.getItemElements=function(){return(this||r).items.map((function(t){return t.element}))};l.layout=function(){this._resetLayout();this._manageStamps();var t=this._getOption("layoutInstant");var i=void 0!==t?t:!(this||r)._isLayoutInited;this.layoutItems((this||r).items,i);(this||r)._isLayoutInited=true};l._init=l.layout;l._resetLayout=function(){this.getSize()};l.getSize=function(){(this||r).size=e((this||r).element)};l._getMeasurement=function(t,i){var n=(this||r).options[t];var s;if(n){"string"==typeof n?s=(this||r).element.querySelector(n):n instanceof HTMLElement&&(s=n);(this||r)[t]=s?e(s)[i]:n}else(this||r)[t]=0};l.layoutItems=function(t,i){t=this._getItemsForLayout(t);this._layoutItems(t,i);this._postLayout()};l._getItemsForLayout=function(t){return t.filter((function(t){return!t.isIgnored}))};l._layoutItems=function(t,i){this._emitCompleteOnItems("layout",t);if(t&&t.length){var e=[];t.forEach((function(t){var n=this._getItemLayoutPosition(t);n.item=t;n.isInstant=i||t.isLayoutInstant;e.push(n)}),this||r);this._processLayoutQueue(e)}};l._getItemLayoutPosition=function(){return{x:0,y:0}};l._processLayoutQueue=function(t){this.updateStagger();t.forEach((function(t,i){this._positionItem(t.item,t.x,t.y,t.isInstant,i)}),this||r)};l.updateStagger=function(){var t=(this||r).options.stagger;if(null!==t&&void 0!==t){(this||r).stagger=getMilliseconds(t);return(this||r).stagger}(this||r).stagger=0};l._positionItem=function(t,i,e,n,s){if(n)t.goTo(i,e);else{t.stagger(s*(this||r).stagger);t.moveTo(i,e)}};l._postLayout=function(){this.resizeContainer()};l.resizeContainer=function(){var t=this._getOption("resizeContainer");if(t){var i=this._getContainerSize();if(i){this._setContainerMeasure(i.width,true);this._setContainerMeasure(i.height,false)}}};l._getContainerSize=noop;l._setContainerMeasure=function(t,i){if(void 0!==t){var e=(this||r).size;e.isBorderBox&&(t+=i?e.paddingLeft+e.paddingRight+e.borderLeftWidth+e.borderRightWidth:e.paddingBottom+e.paddingTop+e.borderTopWidth+e.borderBottomWidth);t=Math.max(t,0);(this||r).element.style[i?"width":"height"]=t+"px"}};l._emitCompleteOnItems=function(t,i){var e=this||r;function onComplete(){e.dispatchEvent(t+"Complete",null,[i])}var n=i.length;if(i&&n){var s=0;i.forEach((function(i){i.once(t,tick)}))}else onComplete();function tick(){s++;s==n&&onComplete()}};l.dispatchEvent=function(t,i,e){var n=i?[i].concat(e):e;this.emitEvent(t,n);if(a){(this||r).$element=(this||r).$element||a((this||r).element);if(i){var s=a.Event(i);s.type=t;(this||r).$element.trigger(s,e)}else(this||r).$element.trigger(t,e)}};l.ignore=function(t){var i=this.getItem(t);i&&(i.isIgnored=true)};l.unignore=function(t){var i=this.getItem(t);i&&delete i.isIgnored};l.stamp=function(t){t=this._find(t);if(t){(this||r).stamps=(this||r).stamps.concat(t);t.forEach((this||r).ignore,this||r)}};l.unstamp=function(t){t=this._find(t);t&&t.forEach((function(t){n.removeFrom((this||r).stamps,t);this.unignore(t)}),this||r)};l._find=function(t){if(t){"string"==typeof t&&(t=(this||r).element.querySelectorAll(t));t=n.makeArray(t);return t}};l._manageStamps=function(){if((this||r).stamps&&(this||r).stamps.length){this._getBoundingRect();(this||r).stamps.forEach((this||r)._manageStamp,this||r)}};l._getBoundingRect=function(){var t=(this||r).element.getBoundingClientRect();var i=(this||r).size;(this||r)._boundingRect={left:t.left+i.paddingLeft+i.borderLeftWidth,top:t.top+i.paddingTop+i.borderTopWidth,right:t.right-(i.paddingRight+i.borderRightWidth),bottom:t.bottom-(i.paddingBottom+i.borderBottomWidth)}};l._manageStamp=noop;l._getElementOffset=function(t){var i=t.getBoundingClientRect();var n=(this||r)._boundingRect;var s=e(t);var o={left:i.left-n.left-s.marginLeft,top:i.top-n.top-s.marginTop,right:n.right-i.right-s.marginRight,bottom:n.bottom-i.bottom-s.marginBottom};return o};l.handleEvent=n.handleEvent;l.bindResize=function(){t.addEventListener("resize",this||r);(this||r).isResizeBound=true};l.unbindResize=function(){t.removeEventListener("resize",this||r);(this||r).isResizeBound=false};l.onresize=function(){this.resize()};n.debounceMethod(Outlayer,"onresize",100);l.resize=function(){(this||r).isResizeBound&&this.needsResizeLayout()&&this.layout()};l.needsResizeLayout=function(){var t=e((this||r).element);var i=(this||r).size&&t;return i&&t.innerWidth!==(this||r).size.innerWidth};l.addItems=function(t){var i=this._itemize(t);i.length&&((this||r).items=(this||r).items.concat(i));return i};l.appended=function(t){var i=this.addItems(t);if(i.length){this.layoutItems(i,true);this.reveal(i)}};l.prepended=function(t){var i=this._itemize(t);if(i.length){var e=(this||r).items.slice(0);(this||r).items=i.concat(e);this._resetLayout();this._manageStamps();this.layoutItems(i,true);this.reveal(i);this.layoutItems(e)}};l.reveal=function(t){this._emitCompleteOnItems("reveal",t);if(t&&t.length){var i=this.updateStagger();t.forEach((function(t,e){t.stagger(e*i);t.reveal()}))}};l.hide=function(t){this._emitCompleteOnItems("hide",t);if(t&&t.length){var i=this.updateStagger();t.forEach((function(t,e){t.stagger(e*i);t.hide()}))}};l.revealItemElements=function(t){var i=this.getItems(t);this.reveal(i)};l.hideItemElements=function(t){var i=this.getItems(t);this.hide(i)};l.getItem=function(t){for(var i=0;i<(this||r).items.length;i++){var e=(this||r).items[i];if(e.element==t)return e}};l.getItems=function(t){t=n.makeArray(t);var i=[];t.forEach((function(t){var e=this.getItem(t);e&&i.push(e)}),this||r);return i};l.remove=function(t){var i=this.getItems(t);this._emitCompleteOnItems("remove",i);i&&i.length&&i.forEach((function(t){t.remove();n.removeFrom((this||r).items,t)}),this||r)};l.destroy=function(){var t=(this||r).element.style;t.height="";t.position="";t.width="";(this||r).items.forEach((function(t){t.destroy()}));this.unbindResize();var i=(this||r).element.outlayerGUID;delete u[i];delete(this||r).element.outlayerGUID;a&&a.removeData((this||r).element,(this||r).constructor.namespace)};Outlayer.data=function(t){t=n.getQueryElement(t);var i=t&&t.outlayerGUID;return i&&u[i]};Outlayer.create=function(t,i){var e=subclass(Outlayer);e.defaults=n.extend({},Outlayer.defaults);n.extend(e.defaults,i);e.compatOptions=n.extend({},Outlayer.compatOptions);e.namespace=t;e.data=Outlayer.data;e.Item=subclass(s);n.htmlInit(e,t);a&&a.bridget&&a.bridget(t,e);return e};function subclass(t){function SubClass(){t.apply(this||r,arguments)}SubClass.prototype=Object.create(t.prototype);SubClass.prototype.constructor=SubClass;return SubClass}var f={ms:1,s:1e3};function getMilliseconds(t){if("number"==typeof t)return t;var i=t.match(/(^\d*\.?\d*)(\w*)/);var e=i&&i[1];var n=i&&i[2];if(!e.length)return 0;e=parseFloat(e);var s=f[n]||1;return e*s}Outlayer.Item=s;return Outlayer}));var h=a;export default h;

