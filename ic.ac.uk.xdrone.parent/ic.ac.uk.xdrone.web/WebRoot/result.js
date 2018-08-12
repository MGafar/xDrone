var arDrone = require('/usr/lib/node_modules/ar-drone'); 
var http    = require('http');
var fs		= require('fs');

var option = new Object();
option.imageSize = "1280x720";
var client = arDrone.createClient(option);
var pngStream = client.getPngStream();
		
var lastPng;
pngStream
  .on('error', console.log)
  .on('data', function(pngBuffer) {
    lastPng = pngBuffer;
  });
  
  
client
  .after(5000, function() {
fs.writeFile('WebRoot/images/latest.png', lastPng, (err) => {});
  }).after(5000, function () {
  	process.exit(0);
  });

