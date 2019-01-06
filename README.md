# xDrone

This project was influenced by https://github.com/ProgrammableDrones/xTextLanguage. <br />
The project is an attempt at making Drone programming through a Domain Specific Language <br />
and user interface. It targets the Parrot AR Drone 2.0. If you are interested in this <br />
and have any questions feel free to message me on LinkedIn (https://www.linkedin.com/in/muhamadgafar/). <br />

This code has the following dependencies: <br />
 <br />

Java jdk 1.7 <br />
nodejs <br />
github.com/felixge/node-ar-drone <br />
OpenCV 2.4.9.1 <br />
github.com/tbutcaru/node-opencv <br />
ffmpeg <br />
 <br />
The program assumes the node modules are installed in the directory /usr/lib/node_modules <br />
 <br />
Ensure all of these modules and dependencies are working and tested or the project will not work as expected. <br />
 <br />

To build the project: <br />
1.) Navigate to ic.ac.uk.parent <br />
2.) Execute (./gradlew build) <br />
 <br />
To start the server: <br />
1.) Navigate to ic.ac.uk.parent <br />
2.) Execute (./gradlew jettyRun) <br />
3.) The web application can be accessed throgh the server's IP address in port 8087. <br />
	3.1) If just testing in same machine use the browser and type localhost:8087. <br />
4.) To stop the server, go on the terminal used to launch it and press "enter" <br />
