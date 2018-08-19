var arDrone = require('/usr/lib/node_modules/ar-drone'); 
var cv	    = require('/usr/lib/node_modules/opencv');
var http    = require('http');
var fs		= require('fs');
var face_cascade = new cv.CascadeClassifier('/usr/lib/node_modules/opencv/data/haarcascade_frontalface_alt2.xml');
var promise	    = require('/usr/lib/node_modules/promise');

//var option = new Object();
//option.imageSize = "1280x720";
//var client = arDrone.createClient(option);
var client = arDrone.createClient();


client.config('video:video_channel', 0);


var pngStream = client.getPngStream();
		
var lastPng;
pngStream
  .on('error', console.log)
  .on('data', function(pngBuffer) {
    lastPng = pngBuffer;
  });
  
var detected_face = Boolean(false);
var feature_matched = Boolean(false);
var using_conditional = Boolean(false);
var count = 0;

using_conditional = Boolean(true);
var run = setTimeout(detectFaces, 5000);


function detectFaces()
{
	cv.readImage(lastPng, function(err, im) 
	{
		im.resize(160, 90);

		var detectedFace = face_cascade.detectMultiScale(im, function(err, faces) 
		{
			if(faces.length)
			{
				count++;
				//console.log('Incrementing count');
				if(count == 3)
				{
					console.log('Face Detected');		
					clearTimeout(run);
					detected_face = Boolean(true);
					do_this_last();				
				}
			}
			else
			{
				count = 0;
				console.log ('No faces Detected');
			}
		});	
	});

	run = setTimeout(detectFaces, 200);
}

function imageSimilarity()
{
	dir = "";
	
		
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
					{
						console.log('Detected');
						feature_matched = Boolean(true);
						clearTimeout(run);
						do_this_last();
						
					}
					 //console.log('Dissimilarity: ', dissimilarity);
						
					});
		
			});
			
			run = setTimeout(drone_image, 300);
		}
	});
}

function do_this_last()
{
	client.stop();
	
	var p2 = new Promise((resolve, reject) => {
		return resolve();
	})			
	.then((res) => {
			  	return delay(1000).then(function() {	
					  	client.stop();
					  	client.counterClockwise(0.5);
					});
	})
	.then((res) => {
		return delay(200).then(function() {
			fs.writeFile('WebRoot/images/shuaitest.png', lastPng, (err) => {});
		})
	})
	
	.then((res) => {			
		return delay(5000).then(function() {
		  	client.stop();
			client.land();
		});
	})
	
	.then((res) => {
		return delay(5000).then(function() {
			process.exit(0);
		});
	});
}

function delay(t, v) {
   return new Promise(function(resolve) { 
       setTimeout(resolve.bind(null, v), t)
   });
}
  
client.takeoff();

var p = new Promise((resolve, reject) => {
	return resolve();
}).then((res) => {
		return delay(5000).then(function() {
		});
	})
.then((res) => {
	if (detected_face || feature_matched) return Promise.resolve();
return delay(2000).then(function() {	
  	client.stop();
  	client.up(0.2);
});
})
.then((res) => {
	if (detected_face || feature_matched) return Promise.resolve();
	  	return delay(1000).then(function() {	
			  	client.stop();
			});
})
.then((res) => {
	if (detected_face || feature_matched) return Promise.resolve();
	  	return delay(2000).then(function() {	
			  	client.stop();
			});
})
.then((res) => {
	if (detected_face || feature_matched) return Promise.resolve();
	  	return delay(2000).then(function() {	
			  	client.stop();
			});
})
.then((res) => {
	if (detected_face || feature_matched) return Promise.resolve();
	  	return delay(2000).then(function() {	
			  	client.stop();
			});
})
.then((res) => {
	if (detected_face || feature_matched) return Promise.resolve();
	  	return delay(2000).then(function() {	
			  	client.stop();
			});
})
.then((res) => {
	if (detected_face || feature_matched) return Promise.resolve();

	return delay(5000).then(function() {
	  	client.stop();
		client.land();
	});
})
.then((res) => {
	if (detected_face || feature_matched) return Promise.resolve();

	return delay(5000).then(function() {
		process.exit(0);
	});
});

