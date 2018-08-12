var arDrone = require('/usr/lib/node_modules/ar-drone');
var client  = arDrone.createClient();

client
  .after(3000, function() {
    this.stop();
    this.land();
	process.exit();
  });
