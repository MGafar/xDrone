var arDrone = require('/usr/lib/node_modules/ar-drone'); 
var cv	    = require('/usr/lib/node_modules/opencv');
var http    = require('http');
var fs		= require('fs');
var face_cascade = new cv.CascadeClassifier('/usr/lib/node_modules/opencv/data/haarcascade_frontalface_alt2.xml');


//var option = new Object();
//option.imageSize = "1280x720";
//var client = arDrone.createClient(option);
var client = arDrone.createClient();
var pngStream = client.getPngStream();
		
var lastPng;
pngStream
  .on('error', console.log)
  .on('data', function(pngBuffer) {
    lastPng = pngBuffer;
  });
  
var detected_face = Boolean(false);
var count = 0;

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

function do_this_last()
{
	//var detected_face = Boolean(false);
	
	client
	  .after(2000, function() {
	
		fs.writeFile('WebRoot/images/detectiontest2.png', lastPng, (err) => {});
	
	
	}).after(2000, function() {
	
		console.log('Finished!');
		process.exit(0);
	
	});
}



  
  
client
  .after(5000, function() {
  });

