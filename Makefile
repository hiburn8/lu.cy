all: clean package
package: 
	cp lu.cy layout/usr/bin/
	cp lucy layout/usr/bin/
	chmod +x layout/usr/bin/lucy
	dpkg-deb -b layout/ .
clean:
	rm *.deb
