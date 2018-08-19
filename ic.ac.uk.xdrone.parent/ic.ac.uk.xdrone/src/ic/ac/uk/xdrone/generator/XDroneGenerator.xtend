package ic.ac.uk.xdrone.generator

import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import ic.ac.uk.xdrone.xDrone.Main
import java.io.IOException
import java.io.PrintWriter
import ic.ac.uk.xdrone.xDrone.Up
import ic.ac.uk.xdrone.xDrone.Command
import ic.ac.uk.xdrone.xDrone.Down
import ic.ac.uk.xdrone.xDrone.Left
import ic.ac.uk.xdrone.xDrone.Right
import ic.ac.uk.xdrone.xDrone.Forward
import ic.ac.uk.xdrone.xDrone.Backward
import ic.ac.uk.xdrone.xDrone.RotateL
import ic.ac.uk.xdrone.xDrone.RotateR
import ic.ac.uk.xdrone.xDrone.Wait
import ic.ac.uk.xdrone.xDrone.Snapshot
import ic.ac.uk.xdrone.xDrone.FunctionName
import ic.ac.uk.xdrone.xDrone.UserFunction

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class XDroneGenerator extends AbstractGenerator {

	def compile(Main main)'''
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
		
		«FOR dc : main.downwardcamera»
		client.config('video:video_channel', 3);
		«ENDFOR»
		
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
		
		«FOR fm : main.facedetect»
			using_conditional = Boolean(true);
			var run = setTimeout(detectFaces, 5000);
		«ENDFOR»
		
		«FOR fm : main.featurematch»
			using_conditional = Boolean(true);
			var run = setTimeout(imageSimilarity, 5000);
		«ENDFOR»
		
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
			
			«FOR fm : main.featurematch»
				dir = "WebRoot/images/«fm.image_name».png"
			«ENDFOR»
				
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
			«FOR cc : main.conditional_commands»
				«IF cc instanceof Command »
					.then((res) => {
						«cc.compile»
					})
				«ENDIF»
				«IF cc instanceof FunctionName»
					«FOR nv : main.custom_function»
						«IF cc.func_name == nv.name »
							«compile_custom(nv, false)»
						«ENDIF»
					«ENDFOR»
				«ENDIF»
			«ENDFOR»
			
			«FOR cl : main.land»
			.then((res) => {			
				return delay(2000).then(function() {
				  	client.stop();
					client.land();
				});
			})
			«ENDFOR»
			
			.then((res) => {
				return delay(2000).then(function() {
					process.exit(0);
				});
			});
		}
		
		function delay(t, v) {
		   return new Promise(function(resolve) { 
		       setTimeout(resolve.bind(null, v), t)
		   });
		}
		  
		«FOR to : main.takeoff»  
			client.takeoff();
		«ENDFOR»
		
		var p = new Promise((resolve, reject) => {
			return resolve();
		}).then((res) => {
				return delay(5000).then(function() {
				});
			})
		
		«FOR f : main.commands»
			«IF f instanceof Command »
				.then((res) => {
						if (detected_face || feature_matched) return Promise.resolve();
					«f.compile»
				})
			«ENDIF»
			«IF f instanceof FunctionName»
				«FOR nv : main.custom_function»
					«IF f.func_name == nv.name »
						«compile_custom(nv, true)»
					«ENDIF»
				«ENDFOR»
			«ENDIF»
		«ENDFOR»
		
		«FOR ln : main.land» 
		.then((res) => {
			if (detected_face || feature_matched) return Promise.resolve();
		
			return delay(2000).then(function() {
			  	client.stop();
				client.land();
			});
		})
		«ENDFOR»
		.then((res) => {
			if (detected_face || feature_matched) return Promise.resolve();

			return delay(2000).then(function() {
				process.exit(0);
			});
		});
	'''
	
	def compile_custom(UserFunction ur, Boolean main) '''
		«FOR cs  : ur.func»  
			.then((res) => {
				«IF main»
				if (detected_face || feature_matched) return Promise.resolve();
				«ENDIF»
				«cs.compile»
			})
		«ENDFOR»
	'''
	
	def compile(Command cmd) '''
		«IF cmd instanceof Snapshot »
			return delay(200).then(function() {
				fs.writeFile('WebRoot/images/«cmd.image_name».png', lastPng, (err) => {});
			})
	  	«ENDIF»
		«IF cmd instanceof Up »
			return delay(«cmd.milliseconds»).then(function() {	
			  	client.stop();
			  	client.up(0.2);
			});
	  	«ENDIF»
	  	«IF cmd instanceof Down »
	  		return delay(«cmd.milliseconds»).then(function() {	
			  	client.stop();
			  	client.down(0.2);
			});
	  	«ENDIF»
	  	«IF cmd instanceof Left »
	  		return delay(«cmd.milliseconds»).then(function() {	
			  	client.stop();
			  	client.left(0.1);
			});
	  	«ENDIF»
	  	«IF cmd instanceof Right »
	  		return delay(«cmd.milliseconds»).then(function() {	
			  	client.stop();
			  	client.right(0.1);
			});
	  	«ENDIF»
	  	«IF cmd instanceof Forward »
	  		return delay(«cmd.milliseconds»).then(function() {	
			  	client.stop();
			  	client.front(0.1);
			});
	  	«ENDIF»
	  	«IF cmd instanceof Backward »
	  		return delay(«cmd.milliseconds»).then(function() {	
			  	client.stop();
			  	client.back(0.1);
			});
	  	«ENDIF»
	  	«IF cmd instanceof RotateL »
	  		return delay(«cmd.milliseconds»).then(function() {	
			  	client.stop();
			  	client.counterClockwise(0.5);
			});
	  	«ENDIF»
	  	«IF cmd instanceof RotateR »
	  		return delay(«cmd.milliseconds»).then(function() {	
			  	client.stop();
			  	client.clockwise(0.5);
			});
	  	«ENDIF»
	  	«IF cmd instanceof Wait »
	  		return delay(«cmd.milliseconds»).then(function() {	
			  	client.stop();
			});
	  	«ENDIF»
	'''
	
	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		var result = "";
		for(main : resource.allContents.toIterable.filter(Main)) {
			result = main.compile.toString; 
			fsa.generateFile('result.js', result)
		}
		
		try {
		    var writer = new PrintWriter("WebRoot/result.js", "UTF-8");
		    writer.println(result);
		    writer.close();   
		} catch (IOException e) {
		   // do something
		}
		
		fsa.generateFile('result.js', result)

	}
}