.PHONE: clean
clean:
	-rm *.box
	-vagrant destroy -f

package: package.box
	./main.sh package
