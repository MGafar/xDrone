var arDrone = require('/usr/lib/node_modules/ar-drone'); 
var cv      = require('/usr/lib/node_modules/opencv');
var http    = require('http');
var fs	    = require('fs');

var option = new Object();
var client = arDrone.createClient();

client.config('video:video_channel', 3);


var pngStream = client.getPngStream();

console.log('Connecting png stream ...');

var lastPng;
pngStream
  .on('error', console.log)
  .on('data', function(pngBuffer) {
    lastPng = pngBuffer;
  });

var run = setTimeout(imageSimilarity, 5000);

function imageSimilarity()
{
	dir="";	
	
	dir="WebRoot/images/landing2.jpg";

	cv.readImage(dir, function(err, im2) {
	  	if (err) throw err;

		//console.log('Loading reference image');
	
		drone_image();

		function drone_image()
		{
			  cv.readImage(lastPng, function(err, im1) {
			    if (err) throw err;
			
				//console.log('loading image from stream');
		
				cv.ImageSimilarity(im2, im1, function (err, dissimilarity) {
				if (err) throw err;
		
				console.log('Dissimilarity: ', dissimilarity);
					
					if(dissimilarity < 30 && dissimilarity != null)
					 //console.log('Dissimilarity: ', dissimilarity);
						console.log('Detected');
					});
		
			});
			
			run = setTimeout(drone_image, 300);
		}


	});
}


