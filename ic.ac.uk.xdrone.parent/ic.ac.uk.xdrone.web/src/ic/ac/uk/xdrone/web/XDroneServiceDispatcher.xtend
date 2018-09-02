/*
 * generated by Xtext 2.10.0
 */
package ic.ac.uk.xdrone.web

import com.google.inject.Inject
import java.io.File
import java.io.FileWriter
import org.eclipse.xtext.web.server.IServiceContext
import org.eclipse.xtext.web.server.InvalidRequestException
import org.eclipse.xtext.web.server.XtextServiceDispatcher
import org.eclipse.xtext.web.server.persistence.IResourceBaseProvider
import org.eclipse.xtext.web.server.model.DocumentStateResult
import org.eclipse.xtext.web.server.generator.GeneratorService

class XDroneServiceDispatcher extends XtextServiceDispatcher {

    @Inject IResourceBaseProvider resourceBaseProvider
    
    @Inject
    GeneratorService generatorService;

    override protected createServiceDescriptor(String serviceType, IServiceContext context) {
        switch serviceType {
            case 'deploy':
                getDeployService(context)
            case 'compile':
            	getCompileService(context)
            case 'emergencystop':
            	getStopService(context)
            default:
                super.createServiceDescriptor(serviceType, context)
        }
    }
	
 
	
	protected def getCompileService(IServiceContext context) throws InvalidRequestException {
		val resourceId = context.getParameter('resource')
		if (resourceId === null)
			throw new InvalidRequestException('The parameter \'resource\' is required.')
		
		val document = getDocumentAccess(context)
		println(document)
		new ServiceDescriptor => [
			service = [
				try {
					generatorService.getResult(document)
				} catch (Throwable throwable) {
					handleError(throwable)
				}
			]
		]
	}
	
	protected def getStopService(IServiceContext context) throws InvalidRequestException {
		val resourceId = context.getParameter('resource')
		if (resourceId === null)
			throw new InvalidRequestException('The parameter \'resource\' is required.')
		
		new ServiceDescriptor => [
			service = [
				try {
						val uri = resourceBaseProvider.getFileURI(resourceId)
						val file = new File(uri.toFileString)
						var FileWriter writer
						try {
							writer = new FileWriter(file)
							val fullText = context.getParameter('fullText')
							if (fullText !== null)
								writer.write(fullText)
						} finally {
							if (writer !== null)
								writer.close()
						}
						val document = getResourceDocument(resourceId, context)
						
						println("preparing to run command: /bin/bash -c /xdrone-emergencyland.sh "+file.getAbsolutePath()+" > /tmp/xdrone.log")
						
						val pb = new ProcessBuilder().inheritIO()
						.command("/bin/bash", "-c", System.getProperty("user.dir") + "/xdrone-emergencyland.sh" + " > /tmp/xdrone.log").start();
						
						
						if (!pb.alive){
							println("exit code: "+pb.exitValue)
						}
						
						return new DocumentStateResult(document.stateId)
						
				} catch (Throwable throwable) {
					handleError(throwable)
				}
			]
			hasSideEffects = true
		]
	}

	protected def getDeployService(IServiceContext context) throws InvalidRequestException {
		val resourceId = context.getParameter('resource')
		if (resourceId === null)
			throw new InvalidRequestException('The parameter \'resource\' is required.')
		new ServiceDescriptor => [
			service = [
				try {
					
					val uri = resourceBaseProvider.getFileURI(resourceId)
					val file = new File(uri.toFileString)
						var FileWriter writer
						try {
							writer = new FileWriter(file)
							val fullText = context.getParameter('fullText')
							if (fullText !== null)
								writer.write(fullText)
						} finally {
							if (writer !== null)
								writer.close()
						}
						val document = getResourceDocument(resourceId, context)
						
						println("preparing to run command: /bin/bash -c /xdrone-deploy.sh "+file.getAbsolutePath()+" > /tmp/xdrone.log")
						
						val pb = new ProcessBuilder().inheritIO()
						.command("/bin/bash", "-c", System.getProperty("user.dir") + "/xdrone-deploy.sh" + " > /tmp/xdrone.log").start();
						
						println(System.getProperty("user.dir") + "/xdrone-deploy.sh");
						
						pb.waitFor();
						
						if (!pb.alive){
							println("exit code: "+pb.exitValue)
						}
						
						return new DocumentStateResult(document.stateId)
						
				} catch (Throwable throwable) {
					handleError(throwable)
				}
			]
			hasSideEffects = true
		]

	}
	
//	protected def getDynamicGallery(IServiceContext context) throws InvalidRequestException {
//		val resourceId = context.getParameter('resource')
//		if (resourceId === null)
//			throw new InvalidRequestException('The parameter \'resource\' is required.')
//		
//		new ServiceDescriptor => [
//			service = [
//				var PrintWriter writer
//				try {
//					val document = getResourceDocument(resourceId, context);
//					var i = 1;
//
//					writer = new PrintWriter("WebRoot/html/lightbox.html", "UTF-8");
//					var File[] files = new File("WebRoot/images").listFiles();
//					
//					writer.println("<div class=\"row\">");
//					for (File file : files) {
//					    if (file.isFile()) {
//					    	writer.println("   <div class=\"column\">");
//					    	writer.println("      <img src=\"images/" + file.getName() + "\" style=\"width:100%\" onclick=\"openModal();currentSlide(" + i + ")\" class=\"hover-shadow cursor\">");
//					    	writer.println("   </div>");
//					    	i++;
//					    }
//					}
//					writer.println("</div>");
//					
//					writer.println("<div id=\"myModal\" class=\"modal\">");
//					writer.println("  <span class=\"close cursor\" onclick=\"closeModal()\">&times;</span>");
//					writer.println("  <div class=\"modal-content\">");
//				
//					var number_of_images = i-1;
//					i = 1;
//					for (File file : files) {
//					    if (file.isFile()) {
//							writer.println("    <div class=\"mySlides\">");
//							writer.println("      <div class=\"numbertext\">" + i + " / " + number_of_images + "</div>");
//							writer.println("      <img src=\"images/" + file.getName() + "\" style=\"width:100%\">");
//							writer.println("    </div>");
//					    	i++;
//					    }
//					}
//					
//					writer.println("	<a class=\"prev\" onclick=\"plusSlides(-1)\">&#10094;</a>");
//					writer.println("    <a class=\"next\" onclick=\"plusSlides(1)\">&#10095;</a>");
//					writer.println("    <div class=\"caption-container\">");
//					writer.println("      <p id=\"caption\"></p>");
//					writer.println("    </div>");					
//				
//					i = 1;
//					for (File file : files) {
//					    if (file.isFile()) {
//							writer.println("	<div class=\"column\">");
//							writer.println("      <img class=\"demo cursor\" src=\"images/" + file.getName() + "\" style=\"width:100%\" onclick=\"currentSlide("+ i +")\" alt=\"" + file.getName() + "\">");
//							writer.println("    </div>");
//					    	i++;
//					    }
//					}
//				
//					writer.println("   </div>");
//					writer.println("</div>");
//				
//					writer.close();
//					
//					return new DocumentStateResult(document.stateId);
//											
//				} catch (Throwable throwable) {
//					handleError(throwable)
//				}
//			]
//			hasSideEffects = true
//		]
//	}

}