package ic.ac.uk.xdrone.web


import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor
import org.eclipse.xtext.web.server.persistence.IServerResourceHandler
import org.eclipse.xtext.web.server.persistence.ResourceBaseProviderImpl
import org.eclipse.xtext.web.server.persistence.IResourceBaseProvider
import com.google.inject.Binder
import org.eclipse.xtext.web.server.XtextServiceDispatcher

/**
 * Use this class to register additional components to be used within the web application.
 */
class XDroneWebModule extends AbstractXDroneWebModule {
	
		def Class<? extends IServerResourceHandler> bindIServerResourceHandler()  {
		XDroneResourceHandler
	}
	
		def Class<? extends XtextServiceDispatcher> bindXtextServiceDispatcher() {
		XDroneServiceDispatcher
	}
	
	def void configureIResourceBaseProvider(Binder binder) {
		binder.bind(IResourceBaseProvider).toInstance(
		new ResourceBaseProviderImpl("./booster-files"))
	}	
}