/* AUTHOR: Maksim Ryzhikov
* NAME: youtube
* VERSION: 0.1
* URL: http://code.google.com/apis/youtube/js_api_reference.html#EventHandlers;
*/
 
//var app = dactyl.plugins.app;
(function () {
var YTB = {
_getState: function (player) {
//unstarted (-1), ended (0), playing (1), paused (2), buffering (3), video cued (5).
return player.getPlayerState();
},
_getPlayer: function(){
var w = XPCNativeWrapper.unwrap(window.content.window),
player = w.document.getElementById('movie_player');
return player;
},
//Video player API
toggle: function(){
var p = this._getPlayer(),
s = this._getState(p);
if (s === 1 ) {
p.pauseVideo();
}else if ( s === 2 ) {
p.playVideo();
}
},
play: function() {
var p = this._getPlayer();
p.playVideo();
},
pause: function(){
var p = this._getPlayer();
p.pauseVideo();
},
stop: function(){
var p = this._getPlayer();
p.stopVideo();
},
clear: function(){
var p = this._getPlayer();
p.clearVideo();
}
};
 
group.commands.add(["youtube", "youtb"], "YouTuBe Integration", function (args) {
if (args["-toggle"] || args["-t"]){
YTB.toggle();
}
},
{
argCount: "0",
options: [{
names: ["-toggle", "-t"],
description: "Stop/Play Video"
}]
});
} ());