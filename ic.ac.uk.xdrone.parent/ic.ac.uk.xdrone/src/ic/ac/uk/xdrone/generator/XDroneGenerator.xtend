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

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class XDroneGenerator extends AbstractGenerator {

	def compile(Main main)'''
		var arDrone = require('/usr/local/lib/node_modules/ar-drone'); 
		var http    = require('http');
		var fs		= require('fs');
		
		var option = new Object();
		option.imageSize = "1280x720";
		var client = arDrone.createClient(option);
		var pngStream = client.getPngStream();
		
		client.takeoff();
		
		var lastPng;
		pngStream
		  .on('error', console.log)
		  .on('data', function(pngBuffer) {
		    lastPng = pngBuffer;
		  });
		  
		client
		  .after(5000, function() {
		«FOR f : main.commands» 
			«f.compile»
		«ENDFOR»
		   this.stop();
		   this.land();
		  }).after(5000, function () {
		  	process.exit(0);
		  });
	'''
	def compile(Command cmd) '''
		«IF cmd instanceof Snapshot »
	    	fs.writeFile('WebRoot/images/«cmd.image_name».png', lastPng, (err) => {});
	  	«ENDIF»
		«IF cmd instanceof Up »
		    this.stop();
		    this.up(0.2);
		  })
		  .after(«cmd.milliseconds», function() {
	  	«ENDIF»
	  	«IF cmd instanceof Down »
		    this.stop();
		    this.down(0.2);
		  })
		  .after(«cmd.milliseconds», function() {
	  	«ENDIF»
	  	«IF cmd instanceof Left »
		    this.stop();
		    this.left(0.1);
		  })
		  .after(«cmd.milliseconds», function() {
	  	«ENDIF»
	  	«IF cmd instanceof Right »
		    this.stop();
		    this.right(0.1);
		  })
		  .after(«cmd.milliseconds», function() {
	  	«ENDIF»
	  	«IF cmd instanceof Forward »
		    this.stop();
		    this.front(0.1);
		  })
		  .after(«cmd.milliseconds», function() {
	  	«ENDIF»
	  	«IF cmd instanceof Backward »
		    this.stop();
		    this.back(0.1);
		  })
		  .after(«cmd.milliseconds», function() {
	  	«ENDIF»
	  	«IF cmd instanceof RotateL »
		    this.stop();
		    this.counterClockwise(0.5);
		  })
		  .after(«cmd.milliseconds», function() {
	  	«ENDIF»
	  	«IF cmd instanceof RotateR »
		    this.stop();
		    this.clockwise(0.5);
		  })
		  .after(«cmd.milliseconds», function() {
	  	«ENDIF»
	  	«IF cmd instanceof Wait »
		    this.stop();	
		  })
		  .after(«cmd.milliseconds», function() {
	  	«ENDIF»
	'''
	
	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		var result = "";
		for(main : resource.allContents.toIterable.filter(Main)) {
			result = main.compile.toString; 
			fsa.generateFile('result.js', result)
			fsa.generateFile('/DEFAULT_ARTIFACT', result)
		}
//		var main = null;
//		if (resource.allContents
//				.filter(typeof(Main)) !== null) {
//					////main = resource.allContents.toIterable.filter(typeof(Main))
//				}
		
		try {
		    var writer = new PrintWriter("WebRoot/result.js", "UTF-8");
		    writer.println(result);
		    writer.close();
		} catch (IOException e) {
		   // do something
		}
		
		
		
		/*
		var fsa1 = new JavaIoFileSystemAccess();
		
		Guice.createInjector(new AbstractGenericModule() {
			
			public Class<? extends IEncodingProvider> bindIEncodingProvider() {
				return IEncodingProvider.Runtime.class;
			}
			
		}).injectMembers(fsa);
		
		fsa1.setOutputPath("/tmp");
		fsa1.generateFile("xxxx.txt", "contents");
		*/
		
		//fsa.setOutputPath('/tmp')
		fsa.generateFile('result.js', result)
		fsa.generateFile('/DEFAULT_ARTIFACT', result)
			/* 
			resource.allContents
				.filter(typeof(Main))
				.map[name]
				.join(', ')
				)*/
	}
}