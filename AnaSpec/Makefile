libInterfacePortaudio	: InterfacePortaudio.o  LienPortaudio.o
	g++ -shared -fPIC InterfacePortaudio.o LienPortaudio.o -o libInterfacePortaudio.so
InterfacePortaudio.o	:
	g++ -D_USRDLL -fpermissive -fPIC -c InterfacePortaudio.cpp  
LienPortaudio.o	:
	g++ -fpermissive -fPIC -c  LienPortaudio.cpp 
