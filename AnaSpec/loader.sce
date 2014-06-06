funcprot(0);
// Quel système utilise t-on ?
if strcmp(getos(),"Windows")==0 then
    [version, opts] = getversion();
// Quelles dll chargées 32 bits ou 64 bits?
    if grep(opts,"x86")~=[] then
        s1=[SCI+"/contrib/AnaSpec/portaudio_x86.dll"];
        s2=[SCI+"/contrib/AnaSpec/DllScilabPortAudio_x86.dll"];
    end
    if grep(opts,"x64")~=[] then
        s1=[SCI+"/contrib/AnaSpec/portaudio_x64.dll"];
        s2=[SCI+"/contrib/AnaSpec/DllScilabPortAudio_x64.dll"];
    end
else 
    if strcmp(getos(),"Linux")==0 then
        rep =pwd();
        repTmp=SCI+"/contrib/AnaSpec/";
        eval(['chdir('''+repTmp+''')']);
        w=G_make("libInterfacePortaudio"," ")
        s1="libportaudio.so";
        s2=repTmp+"/"+"libInterfacePortaudio.so";
    else
        disp("Vous devez charger Portaudio et recompiler le code source");
        disp("puis modifier ce code pour recharger les librairies");
    end
end
link(s1);
link(s2,"InitPortAudio","c");
link(s2,"FermerPortAudio","c");
link(s2,"NomPeripherique","c");
link(s2,"NbPeripherique","c");
link(s2,"NbEntree","c");
link(s2,"NbSortie","c");
link(s2,"PrepAcq","c");
link(s2,"OuvrirFlux","c");
link(s2,"OuvrirFluxFiltrage","c");
link(s2,"DebutAcq","c");
link(s2,"FinAcq","c");
link(s2,"PrepAcq","c");
link(s2,"Lecture","c");
link(s2,"DefNbEch","c");
link(s2,"DefTailleBuffer","c");
link(s2,"DefFreqEch","c");
link(s2,"DefNbCanaux","c");
link(s2,"LectureDonnee","c");

function err=OuvrirFluxFiltrage(pEntree,pSortie,num,den) 
  o = max(length(num),length(den));
  n=zeros(1,o);
  n(1:length(num))=num;
  d=zeros(1,o);
  d(1:length(den))=den;
  err=call("OuvrirFluxFiltrage",pEntree,1,"i",pSortie,2,"i",o,4,"i",n,5,"d",d,6,"d","out",[1 1],3,"i");
endfunction

function [yn,err,pos]=LectureDonnee(nb)  
  [yn,err,pos]=call("LectureDonnee",nb,1,"i","out",[1 nb],2,"d",[1,1],3,"i",[1,1],4,"i");
endfunction

function [nb]=InitPortAudio()  
  [nb]=call("InitPortAudio","out",[1 1],1,"i");
endfunction

function [nb]=FermerPortAudio()  
  [nb]=call("FermerPortAudio","out",[1 1],1,"i");
endfunction

function [nom]=NomPeripherique(n)  
  [nom]=call("NomPeripherique",n,1,"i","out",[1 256],2,"c");
  nom=stripblanks(nom);
endfunction

function [nb]=NbPeripherique()  
  [nb]=call("NbPeripherique","out",[1 1],1,"i");
endfunction

function [nbe]=NbEntree(n)  
  [nbe]=call("NbEntree",n,1,"i","out",[1 1],2,"i");
endfunction

function [nbs]=NbSortie(n)  
  [nbs]=call("NbSortie",n,1,"i","out",[1 1],2,"i");
endfunction

function [err]=DefTailleBuffer(n)  
  [err]=call("DefTailleBuffer",n,1,"i","out",[1 1],2,"i");
endfunction

function [err]=DefNbEch(n)  
  [err]=call("DefNbEch",n,1,"i","out",[1 1],2,"i");
endfunction

function [err]=DefFreqEch(n)  
  [err]=call("DefFreqEch",n,1,"i","out",[1 1],2,"i");
endfunction

function [err]=DefNbCanaux(n)  
  [err]=call("DefNbCanaux",n,1,"i","out",[1 1],2,"i");
endfunction

function err=PrepAcq(t,ind)
  err=call("PrepAcq",t,1,"d",ind,2,"i","out",[1 1],3,"i");
endfunction

function err=OuvrirFlux()
  err=call("OuvrirFlux","out",[1 1],1,"i");
endfunction

function err=DebutAcq()
  err=call("DebutAcq","out",[1 1],1,"i");
endfunction

function err=FinAcq()
  err=call("FinAcq","out",[1 1],1,"i");
endfunction

if strcmp(getos(),"Linux")==0 then
	eval(['chdir('''+rep+''')']);
end
exec(SCI+"/contrib/AnaSpec/AnaSpecEga.sce");
