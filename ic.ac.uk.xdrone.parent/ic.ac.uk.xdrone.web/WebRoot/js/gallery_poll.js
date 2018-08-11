	exponentialBackoff(gallery_poll, 5, 1000, function(result) {
	    console.log('the result is',result);
	});	


function gallery_poll(){
		if(document.getElementById('myModal').style.display != "block"){
			ifHasChanged("html/lightbox.html", function(nModif, nVisit){
				$("#gallery").load("html/lightbox.html");
				return true;
			});	
		}
		return false;
}

	function exponentialBackoff(toTry, max, delay, callback) {
	    console.log('max',max,'next delay',delay);
	    var result = toTry();
	    
	    if (result) {
	        callback(result);
	    } else {
	        if (max > 0) {
	            setTimeout(function() {
	                exponentialBackoff(toTry, --max, delay * 2, callback);
	            }, delay);
	        } else {
	             console.log('we give up');   
	        }
	    }
	}
	
	/* Reference this code - NOT MINE DON'T FORGET - */
	function getHeaderTime () {
		  var nLastVisit = parseFloat(window.localStorage.getItem('lm_' + this.filepath));
		  var nLastModif = Date.parse(this.getResponseHeader("Last-Modified"));

		  if (isNaN(nLastVisit) || nLastModif > nLastVisit) {
		    window.localStorage.setItem('lm_' + this.filepath, Date.now());
		    isFinite(nLastVisit) && this.callback(nLastModif, nLastVisit);
		  }
		}

	function ifHasChanged(sURL, fCallback) {
	  var oReq = new XMLHttpRequest();
	  
/*  	  if(oReq.status != 200) {
	  	clearInterval(gallery_refresh); 	  	
 	  }  */
	  
	  oReq.open("HEAD", sURL);
	  oReq.callback = fCallback;
	  oReq.filepath = sURL;
	  oReq.onload = getHeaderTime;
	  oReq.send();
	}