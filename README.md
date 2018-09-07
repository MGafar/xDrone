# xDrone

This code has the following dependencies:


Java jdk 1.7
nodejs
github.com/felixge/node-ar-drone
OpenCV 2.4.9.1
github.com/tbutcaru/node-opencv
ffmpeg

The program assumes the node modules are installed in the directory /usr/lib/node_modules

Ensure all of these modules and dependencies are working and tested or the project will not work as expected.


To build the project:
1.) Navigate to ic.ac.uk.parent
2.) Execute (./gradlew build)

To start the server:
1.) Navigate to ic.ac.uk.parent
2.) Execute (./gradlew jettyRun)
3.) The web application can be accessed throgh the server's IP address in port 8087.
	3.1) If just testing in same machine use the browser and type localhost:8087.
4.) To stop the server, go on the terminal used to launch it and press "enter"
