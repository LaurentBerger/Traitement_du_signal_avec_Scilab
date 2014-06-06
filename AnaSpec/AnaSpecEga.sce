funcprot(0);
// Fonctions présentes dans ce source :
// BasculeInter
// TypeOndelette
// ChoixOndelette
// TFCT
// ModeAffichage
// AfficherTFD
// AfficherPerio
// AfficherTFCT
// AfficherOndelette
// InitFigure
// InitFigureMono
// InitFigureMulti
// ModeMultiFenetre
// DemarrerAcq
// ArreterAcq
// FenetrePonderation
// ParamTFCT
// ParamPerio
// GestionFMinFMax
// SelectPeriph
// InstallMenuPeriph
// InterfaceSpec
// NouveauFiltre
// ArretFiltre
// ModifFiltre
// NouveauFiltre
// InterfaceIIR
// ***************************************************************
//  Définition des fonctions
// ***************************************************************
function BasculeInter(interface)
	// Fonction BasculeInter
    // Cette fonction est appelée lors d'un clic sur le bouton en haut à gauche 
    // de la fenêtre (IIR ou Ana.Spectre)
    // paramètre : 
    //      constante modeIIR pour afficher la fenêtre "égaliseur" ou 
    //      constante modeSPEC pour afficher la fenêtre "Ana.Spectre"
    global ffInterface
// Arrêt de l'acquisition
    FinAcq();
    if interface==modeIIR then
        // Affichage de l'interface RII
        for i=1:5
            if  is_handle_valid(fAxe(i)) then
                close(fAxe(i));
            end
            if  is_handle_valid(fFig(i)) then
                close(fFig(i));
            end
        end
        modeAffichage=0;
        InterfaceIIR(ffInterface);
    end
    if interface==modeSPEC then
        // Affichage de l'interface Analyseur de spectre
         InterfaceSpec(ffInterface);
       
    end
// Mise à jour des menus de la fenêtre
    InstallMenuPeriph(ffInterface,interface);
// On déplace légèrement la fenêtre pour assurer une mise à jour des menus
    ffInterface.figure_size = ffInterface.figure_size+[1 ,0];
    ffInterface.figure_size = ffInterface.figure_size-[1 ,0];
endfunction

function TypeOndelette()
//  Fonction appelée lors d'un clic dans la liste des noms d'ondelette
//  Génère la liste des ondelettes disponibles
//  en fontion du type choisi
    h=findobj("tag","listeDWT");
    if h==0 then
        return;
    end
    indNom=h.value;
// Fonction appelée lors du clic sur des boutons des ondelettes
    ondPossible=grep(nomWv,typeWv(indNom,2));
// Mise en place du menu associé lors du clic bouton
    h=findobj("tag","WNAME");
    h.string=nomWv(ondPossible);
    h.value=1;
endfunction

function ChoixOndelette()
// Fonction appelée pour choisir le nombre de moments nuls pour l'ondelette
    global wname nivMax
    h=findobj("tag","WNAME");
    if h==0 then
        return;
    end
    indNom=h.value;
    wname=h.string(indNom);
// Niveau maximum de décomposition de l'ondelette 
    nivMax=wmaxlev(length(y),wname);
endfunction
//
// Transformée de Fourier à court terme
//
function X=TFCT(x,w,pas,signe)
    larFen=length(w);
    if signe==-1 then
        N=length(x);
        origFen=1:pas:N-1;
        X=zeros(larFen,length(origFen));
         for i=1:length(origFen)
            xf=[x(origFen(i):min(origFen(i)+larFen-1,N));zeros(larFen-(min(origFen(i)+larFen-1,N)-origFen(i)+1),1)];
            X(:,i)=fft(xf.*w);
        end
    else
        X=zeros(signe,1);
        sw2=zeros(signe,1);
        [nbFreq nbSpectre ]=size(x);
        for i=1:nbSpectre
            ind=(i-1)*pas+1:min((i-1)*pas+larFen,length(X));
            xx=ifft(x(:,i)).*w;
            X(ind)= X(ind)+xx(1:ind($)-ind(1)+1);
            sw2(ind)=sw2(ind)+w(1:ind($)-ind(1)+1).^2;
        end
        ind=find(sw2==0)
        if length(ind)>0
            disp('Attention fenêtre avec valeur nulle. Reconstruction incomplète');
        end
        
        ind=find(abs(sw2)>0);
        X(ind) = X(ind) ./ sw2(ind);
    end    
endfunction

function ModeAffichage(s)
//  Fonction appelée lors d'un clic sur les boutons "Signal", "TFD", 
//  "Périodogramme", "TFCT" ou "DWT".
//  La couleur du bouton changera
    global modeAffichage
    hDWT=findobj("tag","DWT");
    hTFCT=findobj("tag","TFCT");
    hPERIO=findobj("tag","PERIO");
    hTFD=findobj("tag","TFD");
    hSTPS=findobj("tag","STPS");
    if strcmp(s,"DWT")==0 then
       if bitand(modeAffichage,mDWT)~=0
           modeAffichage=bitand(modeAffichage,255-mDWT);
           hDWT.backgroundcolor=[0.5 0.5 0.5];
       else
           modeAffichage=bitor(modeAffichage,mDWT);
           hDWT.backgroundcolor=[0 0.5 0];
       end
    end
    if strcmp(s,"TFCT")==0 then
       if bitand(modeAffichage,mTFCT)~=0
           modeAffichage=bitand(modeAffichage,255-mTFCT);
           hTFCT.backgroundcolor=[0.5 0.5 0.5];
       else
           modeAffichage=bitor(modeAffichage,mTFCT);
           hTFCT.backgroundcolor=[0 0.5 0];
       end
    end
    if strcmp(s,"PERIO")==0 then
       if bitand(modeAffichage,mPERIO)~=0
           modeAffichage=bitand(modeAffichage,255-mPERIO);
           hPERIO.backgroundcolor=[0.5 0.5 0.5];
       else
           modeAffichage=bitor(modeAffichage,mPERIO);
           hPERIO.backgroundcolor=[0 0.5 0];
       end
    end
    if strcmp(s,"TFD")==0 then
       if bitand(modeAffichage,mTFD)~=0
           modeAffichage=bitand(modeAffichage,255-mTFD);
           hTFD.backgroundcolor=[0.5 0.5 0.5];
       else
           modeAffichage=bitor(modeAffichage,mTFD);
           hTFD.backgroundcolor=[0 0.5 0];
       end
    end
    if strcmp(s,"STPS")==0 then
       if bitand(modeAffichage,mSTPS)~=0
           modeAffichage=bitand(modeAffichage,255-mSTPS);
           hSTPS.backgroundcolor=[0.5 0.5 0.5];
       else
           modeAffichage=bitor(modeAffichage,mSTPS);
           hSTPS.backgroundcolor=[0 0.5 0];
       end
    end
    InitFigure();
endfunction

function AfficherTFD()
//  Affichage du module de la TFD du signal après fenêtrage
    z=fft(y.*wTFD);
//  indTFD est mis à jour par les glissières horizontales.
    title('T.F.D.')
    plot((indTFD-1)'*Fe/nbEch,abs(z(indTFD)))
    xlabel('Hz');
endfunction

function AfficherPerio()
//  Affichage du périodogramme 
    h=findobj("tag","listeFCT");fctPond=lFctPond(h.value);h.enable="off";
    if h.value<=4 then
        sm=pspect(pasFenetreP,larFenetreP,fctPond,y );
     else
        if h.value==5 then
            h=findobj("tag","BETA");beta=evstr(h.string);
            sm=pspect(pasFenetreP,larFenetreP,fctPond,y,beta );
        end
        if h.value==6 then
            h=findobj("tag","DP");beta=evstr(h.string);
           sm=pspect(pasFenetreP,larFenetreP,fctPond,y,[beta -1] );
        end
    end
    title('Périodogramme')
    plot((indPERIO-1)*Fe/larFenetreP,abs(sm(indPERIO)))
    xlabel('Hz');
endfunction


function AfficherTFCT()
//   Affichage de la TFCT du signal après fenêtrage
    stft=TFCT(y,wTFCT,pasFenetre,-1);
    [nbFreq nbSpec]=size(stft);// Nombre de fréquences Nombre de spectres
    indFreqHaute=indTFCT($);
    indFreqBasse=indTFCT(1)
    Matplot(abs(stft(indFreqHaute:-1:indFreqBasse,:))/max(abs(stft))*256);
    legGradx=[];
    nbGradX=5
    px=[];
    for i=0:nbGradX-1
             ind=fix(i*size(stft,2)/(nbGradX-1))+1;
             px=[px ind];
             legGradx=[legGradx; string(fix(ind*pasFenetre/Fe*100)/100)];
    end
    legGrady=[];
    nbGradY=10;
    py=[];
    for i=0:nbGradY-1
             ind=fix(i*(indFreqHaute-indFreqBasse)/(nbGradY-1))+1;
             py=[py ind];
             legGrady=[ string(fix(((nbGradY-1-i)/(nbGradY-1)*(indFreqHaute-indFreqBasse)+indFreqBasse-1)*Fe/larFenetre));legGrady];
    end
    aa=gca();
    aa.x_ticks = tlist(["ticks", "locations", "labels"], px', legGradx);  
    aa.y_ticks = tlist(["ticks", "locations", "labels"], py', legGrady);  
    aa.x_location = 'bottom';
    aa.y_location = 'left';
    xlabel('$ Temps(s) $')
    ylabel('$ \nu (Hz) $'),
    title('Transformée de Fourier à court terme');
endfunction

function AfficherOndelette()
//  Affichage de la décomposition en ondelette
//  Le module ATOMS swt doit être disponible
//  Modification du code de wavedecplot
//  Authors
//  Holger Nahrstaedt - 2010-2012
    if swtInstall==0 wavedecplot
        return;
    end
    global y nivMax;   
    [C,L]=wavedec(y,nivMax,wname);
    level=nivMax-2;
    len=L($);
    cfd=zeros(level,len);

    for k=1:level
      d=detcoef(C,L,k);
      d=d(ones(1,2^k),:);
      cfd(k,:)=wkeep(d(:)',len);
    end
    cfd=cfd(:);

    I=find(abs(cfd) <sqrt(%eps));
    cfd(I)=zeros(length(I),1);
    cfd=matrix(cfd,level,len);
    
    scales=1:level;
    Matplot(abs(cfd)/max(abs(cfd))*256);
    legGradx=[];
    nbGradX=5
    px=[];
    for i=0:nbGradX-1
             ind=fix(i*size(cfd,2)/(nbGradX-1))+1;
             px=[px ind];
             legGradx=[legGradx; string(fix(ind/Fe*100)/100)];
    end
    legGrady=[];
    nbGradY=level;
    py=[];
    for i=0:nbGradY-1
             ind=fix(i)+1;
             py=[py ind];
             legGrady=[ string(fix(nbGradY-ind));legGrady];
    end
    aa=gca();
    aa.x_ticks = tlist(["ticks", "locations", "labels"], px', legGradx);  
    aa.y_ticks = tlist(["ticks", "locations", "labels"], py', legGrady);  
    aa.x_location = 'bottom';
    aa.y_location = 'left';
    xlabel('$ Temps(s) $')
    ylabel('$ échelle  $'),
    title(['DWT : ' wname]);
endfunction

function InitFigure()
    if multiFenetre==1 then
        InitFigureMulti();
    else
        InitFigureMono();
    end
endfunction

function InitFigureMulti()
//  Placement automatique des figures au début de l'acquisition
    global fFig // Liste des figures modifiées dans cette fonction
    largeur=420;
    hauteur=400;
    oriX=430;
    oriY=540;
    if bitand(modeAffichage,mSTPS)~=0 then
       if  is_handle_valid(fFig(1))==%F then
           fFig(1)=scf(1);
           fFig(1).figure_position=[000 ,oriY];
           fFig(1).figure_size=[largeur ,hauteur];
           fFig(1).figure_name='Signal temporel';
           clf();
       end
    else if  is_handle_valid(fFig(1)) then
           fFig(1)=scf(1);
           close(fFig(1));
       end
    end
    if bitand(modeAffichage,mTFD)~=0 then
       if  is_handle_valid(fFig(2))==%F then
           fFig(2)=scf(2);
           fFig(2).figure_position=[oriX ,000];
           fFig(2).figure_size=[largeur ,hauteur];
           fFig(2).figure_name='|TFD|';
           clf();
       end
   else if  is_handle_valid(fFig(2)) then
           fFig(2)=scf(2);
           close(fFig(2));
       end
    end
    if bitand(modeAffichage,mPERIO)~=0 then
       if  is_handle_valid(fFig(3))==%F then
           fFig(3)=scf(3);
           fFig(3).figure_position=[oriX ,hauteur];
           fFig(3).figure_size=[largeur ,hauteur];
           fFig(3).figure_name='|Periodogramme|';
           clf();
       end
   else if  is_handle_valid(fFig(3)) then
           fFig(3)=scf(3);
           close(fFig(3));
       end
    end
    if bitand(modeAffichage,mTFCT)~=0 then
       if  is_handle_valid(fFig(4))==%F then
           fFig(4)=scf(4);
           clf();
           fFig(4).figure_position=[oriX+largeur ,0];
           fFig(4).figure_size=[largeur ,hauteur];
           fFig(4).figure_name='|TFCT|';
           f=gcf();f.color_map=paletteAna;f.background=257;
       end
  else if  is_handle_valid(fFig(4)) then
           fFig(4)=scf(4);
           close(fFig(4));
       end
    end
    if bitand(modeAffichage,mDWT)~=0 then
       if  is_handle_valid(fFig(5))==%F then
           fFig(5)=scf(5);
           clf()
           fFig(5).figure_position=[oriX+largeur ,hauteur];
           fFig(5).figure_size=[largeur ,hauteur];
           fFig(5).figure_name='|DWT|';
           f=gcf();f.color_map=paletteAna;f.background=257;
        end
   else if  is_handle_valid(fFig(5)) then
           fFig(5)=scf(5);
           close(fFig(5));
       end
    end
endfunction 

function InitFigureMono()
//  Placement automatique des figures au début de l'acquisition
    global fAxe // Liste des figures modifiées dans cette fonction
    global ffInterface // Figure modifiée dans cette fonction
    oriX=430;
    oriY=540;
    if bitand(modeAffichage,mSTPS)~=0 then
       if is_handle_valid(fAxe(1))==%F  then
           fAxe(1)=newaxes(); 
           fAxe(1).axes_bounds = [ 0 2/3 1/3 1/3 ];
           fAxe(1).data_bounds = [0 -1 ; nbEch/Fe 1];
       end
    else if  is_handle_valid(fAxe(1)) then
           close(fAxe(1));
       end
    end
    
    if bitand(modeAffichage,mTFD)~=0 then
       if is_handle_valid(fAxe(2))==%F  then
           fAxe(2)=newaxes(); 
           fAxe(2).axes_bounds = [ 1/3 0 1/3 1/3 ];
       end 
    else if  is_handle_valid(fAxe(2)) then
           close(fAxe(2));
       end
    end
    if bitand(modeAffichage,mPERIO)~=0 then
       if is_handle_valid(fAxe(3))==%F  then
           fAxe(3)=newaxes(); 
           fAxe(3).axes_bounds = [ 1/3 2/3 1/3 1/3 ];
        end 
    else if  is_handle_valid(fAxe(3)) then
           close(fAxe(3));
       end
    end
    if bitand(modeAffichage,mTFCT)~=0 then
       if is_handle_valid(fAxe(4))==%F  then
           fAxe(4)=newaxes(); 
           fAxe(4).axes_bounds = [ 2/3 0 1/3 1/3 ];
       end
    else if  is_handle_valid(fAxe(4)) then
           close(fAxe(4));
       end
    end
    if bitand(modeAffichage,mDWT)~=0 then
       if is_handle_valid(fAxe(5))==%F  then
           fAxe(5)=newaxes(); 
           fAxe(5).axes_bounds = [ 2/3 2/3 1/3 1/3 ];
        end 
    else if  is_handle_valid(fAxe(5)) then
           close(fAxe(5));
       end
    end
endfunction 

function ModeMultiFenetre()
    global ffInterface
    global multiFenetre
    global fAxe
    global fFig
    h=findobj("tag","multiF");
    if h.value==1 then
        for i=1:5
            if  is_handle_valid(fAxe(i)) then
               close(fAxe(i));
            end    
        end
        multiFenetre=1;
        largeurEcran=430;
        hauteurEcran=540;
    else
        for i=1:5
            if  is_handle_valid(fFig(i)) then
               close(fFig(i));
            end    
        end
        w=get(0, "screensize_px");
        largeurEcran=w(3);
        hauteurEcran=w(4)-50;
        multiFenetre=0;
    end
    ffInterface.figure_size=[largeurEcran hauteurEcran];
    InitFigure();
endfunction

function FenetrePonderation()
// Gestion de la liste pour les fenêtres de pondération ***********
    h=findobj("tag","listeFCT");
// Récupération des 4 zones de données
    hDP=findobj("tag","DP");
    hDPt=findobj("tag","DPTEXTE");
    hBETAt=findobj("tag","BETATEXTE");
    hBETA=findobj("tag","BETA");
    if  h.value==6 then
        hDPt.visible='on';
        hDP.visible='on';
        hBETAt.visible='off';
        hBETA.visible='off';
    end
    if  h.value==5 then
        hDPt.visible='off';
        hDP.visible='off';
        hBETAt.visible='on';
        hBETA.visible='on';
    end
    if h.value <=4 then
        hDPt.visible='off';
        hBETAt.visible='off';
        hDP.visible='off';
        hBETA.visible='off';
    end
endfunction

function ParamTFCT()
//
//  Gestion des de largeur de la fenêtre et de la discrétisation de tau pour la TFCT
    global larFenetre  // largeur de la fenêtre de pondération
    global pasFenetre  // Discrétisation de tau
    h1=findobj("tag","LARFENETRE");
    h2=findobj("tag","PASFENETRE");
    larFenetre=evstr(h1.string);
    pasFenetre=larFenetre/4;
    h2.string=string(pasFenetre);
    GestionFMinFMax();
endfunction


function ParamPerio()
//  Gestion des paramètres pour le périodogrammme
//  largeur de fenêtre pour la TFD et discrétisation de tau
    global larFenetreP  // largeur de la fenêtre de pondération
    global pasFenetreP  // pas d'avance de la fenetre
    h1=findobj("tag","LARFENETREP");
    h2=findobj("tag","PASFENETREP");
    larFenetreP=evstr(h1.string);
    pasFenetreP=larFenetreP/4;
    h2.string=string(pasFenetreP);
    GestionFMinFMax();
endfunction

function GestionFMinFMax()
//  Fréquence minimale et maximale affichées lors
//  d'une analyse spectrale

    global fMin fMax // Fréquence minimale et maximale affichée
    global indTFD  // Indice associés aux fréquences pour la TFD
    global indTFCT // Indice associés aux fréquences pour la TFCT
    global indPERIO // Indice associés aux fréquences pour le periodogramme
    hMin =findobj("tag","FMIN");
    hMax = findobj("tag","FMAX");
    hvMin =findobj("tag","vFMIN");
    hvMax = findobj("tag","vFMAX");
    fMin=fix(hMin.value);
    fMax=fix(hMax.value);
    hvMin.string=string(hMin.value)+' Hz';
    hvMax.string=string(hMax.value)+' Hz';
    hMin.max=max(0,hMax.value);
    hMin.value=fMin;
    hMax.min=min(Fe/2,hMin.value);
    hMax.value=fMax;
    f=(0:nbEch-1)*Fe/nbEch;
    indTFD=find(f>= fMin & f<=fMax);
    f=(0:larFenetre-1)*Fe/larFenetre;
    indTFCT=find(f>= fMin & f<=fMax);
    f=(0:larFenetreP-1)*Fe/larFenetreP;
    indPERIO=find(f>= fMin & f<=fMax);
endfunction

function SelectPeriph(nom)
    // Gestion du menu peripherique
    // Le peripherique sélectionné est 
    // marqué avec une croix
    global indFluxEntree
    global indFluxSortie
    if strcmp(part(nom,1:2),'PI')==0
        j=0;
        for i=0:NbPeripherique()-1
            nbe=NbEntree(i);
            if nbe>0 then
                tag=['PI'+string(j)];
                h=findobj('tag',tag);
                if strcmp(tag,nom)==0 then
                    h.checked='on';
                    indFluxEntree=i;
                else
                    h.checked='off';
                end
                j=j+1;
            end
        end
    else
        j=0;
        for i=0:NbPeripherique()-1
            nbe=NbSortie(i);
            if nbe>0 then
                tag=['PO'+string(j)];
                h=findobj('tag',tag);
                if strcmp(tag,nom)==0 then
                    h.checked='on';
                    indFluxSortie=i;
                else
                    h.checked='off';
                end
                j=j+1;
            end 
        end
    end   
endfunction

function InstallMenuPeriph(f,interface)
//  Installation des menus Périphérique d'entrée et périphérique de sortie
    global nomPeriphEntree
    global indPeriphEntree
    global nomPeriphSortie
    global indPeriphSortie
    
    scf(f);
    FermerPortAudio();
    InitPortAudio();
    nomPeriphEntree=[];
    indPeriphEntree=[];
    nomPeriphSortie=[];
    indPeriphSortie=[];
    delmenu(f.figure_id,"Périphérique Entrée");
    hIn=uimenu(f,"label","Périphérique Entree","tag","PeriphEntree");
    delmenu(f.figure_id,"Périphérique Sortie");
    if interface==modeIIR
        hOut=uimenu(f,"label","Périphérique Sortie","tag","PeriphSortie");
    end
    jIn=0;
    jOut=0;
    PrepAcq(1.0,0);
    for i=0:NbPeripherique()-1
        nbe=NbEntree(i);
        if nbe>0 then
            nomPeriphEntree=[nomPeriphEntree;NomPeripherique(i)];
            tag=['PI'+string(jIn)];
            fct=['SelectPeriph(""'+tag+'"")'];
            m=uimenu(hIn,'label',NomPeripherique(i),'callback',fct,'tag',tag);
            jIn=jIn+1;
            indPeriphEntree=[indPeriphEntree;i];
        end    
        if interface==modeIIR
            nbe=NbSortie(i);
            if nbe>0 then
                nomPeriphSortie=[nomPeriphSortie;NomPeripherique(i)];
                tag=['PO'+string(jOut)];
                fct=['SelectPeriph(""'+tag+'"")'];
                if jOut==0 then
                    m=uimenu(hOut,'label',NomPeripherique(i),'checked','on','callback',fct,'tag',tag);
                    indFluxSortie=i-1;
                else
                    m=uimenu(hOut,'label',NomPeripherique(i),'callback',fct,'tag',tag);
                end
                jOut=jOut+1;
                indPeriphSortie=[indPeriphSortie;i];
            end  
        end  
    end
    if jIn==0 then
    	disp("Aucun périphérique d''entrée audio détecté!");
    	disp('Arret du programme conseillé');
    end
    if jOut==0 & interface==modeIIR then
    	disp("Aucun périphérique d''entrée audio détecté!");
    	disp('Arret du programme conseillé');
    end
    tag=['PI'+string(indFluxEntree)];
    SelectPeriph(tag);




    if interface==modeIIR then
        tag=['PO'+string(indFluxSortie)];
        SelectPeriph(tag);
    end
endfunction 


function DemarrerAcq()
//  Fonction appelée lors d'un clic sur le bouton "DEMARRER"
//  L'acquisition du signal et les analyses sont appelées à partir de cette fonction
    global D Fe nbEch;      // Durée du signal fréquence d'échantillonnage nombre d'échantillons affichés
    global y;               // Signal
    global wTFCT wTFD       // Fenetre de pondération
    global larFenetre;      // largeur de la fenêtre de pondération
    global pasFenetre;      // Discrétisation de tau
    global nivMax;          // Niveau max de décomposition de l'ondelette
    global hTpsReel;        // Champ statique Temps-réel
    global beta dp;         // Paramètre de la fenêtre de kaiser et chebycheff
    nbCanaux=2;
    h1=findobj("tag","LARFENETRE");
    h2=findobj("tag","PASFENETRE");
    larFenetre=evstr(h1.string);
    pasFenetre=evstr(h2.string);
    h=findobj("tag","DEMARRER");h.enable="off";
    h=findobj("tag","D");D=evstr(h.string);h.enable="off";
    h=findobj("tag","nbEch");nbEch=evstr(h.string);h.enable="off";
    h=findobj("tag","FE");Fe=evstr(h.string);h.enable="off";
    h=findobj("tag","multiF");h.enable="off";
    h=findobj("tag","listeFCT");fctPond=lFctPond(h.value);h.enable="off";
    if h.value<=4 then
        wTFD=window(fctPond,nbEch)';
        wTFCT=window(fctPond,larFenetre)';   
    else
        if h.value==5 then
            h=findobj("tag","BETA");beta=evstr(h.string);
            wTFD=window(fctPond,nbEch,beta)';
            wTFCT=window(fctPond,larFenetre,beta)';
        end
        if h.value==6 then
            h=findobj("tag","DP");beta=evstr(h.string);
            wTFD=window(fctPond,nbEch,[dp -1])';
            wTFCT=window(fctPond,larFenetre,[dp -1])';
        end
    end
    DefNbCanaux(nbCanaux);
    DefFreqEch(Fe);
    PrepAcq(D,indFluxEntree);
    OuvrirFlux();
    DebutAcq();
    sleep(fix((nbEch*1000)/Fe)+1);
    [x err index]=LectureDonnee(nbEch);
    err=0;
    N=nbEch;
    if swtInstall==1 then
        nivMax=wmaxlev(N,wname);
    else
        nivMax=0;
    end
    t=(0:N-1)'/Fe;
    sleep(fix((nbEch*1000)/Fe)+1);
    while (err==0 )
        [x err index]=LectureDonnee(nbEch);
        tic()
        y=x(1:1:N)';
        if multiFenetre==0 then
            drawlater();
        end
        if bitand(modeAffichage,mSTPS)~=0 then
           if multiFenetre==1  then
               scf(fFig(1));
               drawlater();
               clf();
               plot(t,y)
               drawnow()
           else
               sca(fAxe(1))
               if  fAxe(1).children~=[] then
                   delete(fAxe(1).children)
               end
               plot(t,y)
               replot([0 min(y) max(t) max(y) ])
           end    
        end
        if bitand(modeAffichage,mTFD)~=0 then
           if multiFenetre==1  then
               scf(2);
               drawlater();
               clf();
               AfficherTFD();
               drawnow()
           else
               sca(fAxe(2))
               if  fAxe(2).children~=[] then
                   delete(fAxe(2).children)
               end
               AfficherTFD();
           end    
       end
        if bitand(modeAffichage,mPERIO)~=0 then
           if multiFenetre==1  then
               scf(3);
               drawlater();
               clf();
               AfficherPerio();
               drawnow()
            else
               sca(fAxe(3))
               if  fAxe(3).children~=[] then
                   delete(fAxe(3).children)
               end
               AfficherPerio();
            end    
        end
        if bitand(modeAffichage,mTFCT)~=0 then
           if multiFenetre==1  then
               scf(4);
               drawlater();
               clf();
               AfficherTFCT();
               drawnow()
           else
               sca(fAxe(4))
               if  fAxe(4).children~=[] then
                   delete(fAxe(4).children)
               end
               AfficherTFCT();
           end    
         end
        if bitand(modeAffichage,mDWT)~=0 then
           if multiFenetre==1  then
               scf(5);
               drawlater();
               clf()
               AfficherOndelette();
               drawnow()
           else
               sca(fAxe(5))
               if  fAxe(5).children~=[] then
                   delete(fAxe(5).children)
               end
               AfficherOndelette();
           end    
        end
        if multiFenetre==0 then
            drawnow();
        end
        e=toc();
        tps=fix((nbEch/Fe-e)*1000);
// Temps nécessaire pour avoir de nouveaux échantillons
        if tps>=0
            hTpsReel.backgroundcolor=[0.1 0.9 0.1];
            sleep(tps+1);
        else
            hTpsReel.backgroundcolor=[0.9 0.1 0.1];
        end
    end
    ArreterAcq();
    FenetrePonderation();
endfunction

function ArreterAcq()
    global err
    global hTpsReel
    FinAcq();
    err=2;
    hTpsReel.backgroundColor=[0.8,0.8,0.8];
    h=findobj("tag","D");
    h.enable="on";
    h=findobj("tag","FE");
    h.enable="on";
    h=findobj("tag","nbEch");
    h.enable="on";
    h=findobj("tag","listeFCT");
    h.enable="on";
    h=findobj("tag","DEMARRER");h.enable="on";
    h=findobj("tag","multiF");h.enable="on";
endfunction

function InterfaceSpec(f)
// Mise en place de la fenêtre de l'analyseur de spectre
    global hTpsReel
    global paletteAna
    scf(f.figure_id);
    f.Figure_name=blanks(50)+"Analyseur de spectre audio";
    clf();
    w=get(0, "screensize_px");
    largeurEcran=w(3);
    hauteurEcran=w(4)-50;
    f.figure_position=[000 ,000];
    if multiFenetre==1 then
        largeurEcran=430;
        hauteurEcran=540;
    end
    f.figure_size=[largeurEcran ,hauteurEcran];
    g=gca();
//    g.background=33;
    paletteAna = [jetcolormap(256);[0.8 0.8 0.8]];f.color_map=paletteAna;f.background=257;
    fa=gca();
    fa.background=257;
    
    posLigne= 350; // Bouton IIR
    posLigne= [posLigne 380]; // DEMARRER ARRET TempsReel
    posLigne= [posLigne 360]; // Affichage multi-fenêtres
    posLigne= [posLigne 320]; // Fe vFe Duree vDuree NombreEch bNombreEch
    posLigne= [posLigne 280];  // Fenetre de Ponderation vFenetre
    posLigne= [posLigne 240];  // SIGNAL
    posLigne= [posLigne 180];    // TFD
    posLigne= [posLigne 140];    // PERIODOGRAMME
    posLigne= [posLigne 80];     // TFCT largeur vLargeur Pas vPas
    posLigne= [posLigne 20];     // DWT
    posLigne=posLigne+(hauteurEcran-160-posLigne(2));
    indLigne=1
    h=uicontrol(f,"style","pushbutton","string","IIR","position",[10 posLigne(indLigne) 90 60],"callback","BasculeInter(1)","Callback_Type",2,"tag","IIR");
    indLigne=indLigne+1;
    // Bouton Demarrer acquisition ***********************************
    fct="DemarrerAcq()";
    h=uicontrol(f,"style","pushbutton","string","DEMARRER","callback",fct,"Callback_Type",2,"position",[110 posLigne(indLigne) 100 20],"tag","DEMARRER");
    h.backgroundColor=[0,1,0];
    // Bouton Arreter ***********************************
    fct="ArreterAcq()";
    h=uicontrol(f,"style","pushbutton","string","ARRETER","callback",fct,"Callback_Type",2,"position",[210 posLigne(indLigne) 100 20]);
    h.backgroundColor=[1,0,0];
    // Texte Temps-réél ***********************************
    hTpsReel=uicontrol(f,"style","text","string","Temps-réel","position",[320 posLigne(indLigne) 100 20]);
    hTpsReel.backgroundColor=[0.8,0.8,0.8];
    // Affichage multi fenêtre ***********************************
    indLigne=indLigne+1;
    fct="ModeMultiFenetre()";
    h=uicontrol(f,"style","checkbox","string","Affichage multi-fenêtres","position",[110 posLigne(indLigne) 150 20],"callback",fct,"Callback_Type",2,"tag","multiF");
    // Edition Frequence ***********************************
    indLigne =indLigne+1;
    h=uicontrol(f,"style","text","string","Fe (Hz)","position",[10 posLigne(indLigne) 30 20]);
    h=uicontrol(f,"style","edit","string","44100","position",[50 posLigne(indLigne) 40 20],"tag","FE");
    h.string=string(Fe);
    h.backgroundColor=[0.5,0.5,0];
    // Edition Durée de numérisation ***********************************
    h=uicontrol(f,"style","text","string","Duree (s)","position",[90 posLigne(indLigne) 50 20]);
    h=uicontrol(f,"style","edit","string","10","position",[150 posLigne(indLigne) 30 20],"tag","D");
    h.string=string(D);
    h.backgroundcolor=[0.5 0.5 0];
    // Edition Nombre d'échantillons à analyser = nombre d'échantillons dans le graphique vu **************************
    h=uicontrol(f,"style","text","string","Nombre d''échantillons analysés","position",[190 posLigne(indLigne) 150 20]);
    h=uicontrol(f,"style","edit","string","10","position",[350 posLigne(indLigne) 40 20],"tag","nbEch");
    h.string=string(nbEch);
    h.backgroundcolor=[0.5 0.5 0];
    // Liste pour le choix de la fenêtre de pondération ***********************************
    indLigne=indLigne+1;
    h=uicontrol(f,"style","text","string","Fenêtre de pondération","position",[10 posLigne(indLigne) 120 20]);
    fct="FenetrePonderation";
    fenetre=['rectangle';'triangle';'Hamming';'Hann';'kaiser';'Chebycheff'];
    h=uicontrol(f,"style","listbox","string",fenetre,"position",[130 posLigne(indLigne)-10 130 40],"tag","listeFCT","Relief","sunken","callback",fct,"Callback_Type",2);
    h.value=1;
    h=uicontrol(f,"style","text","string","Beta","position",[270 posLigne(indLigne) 30 20],"tag","BETATEXTE");
    h.visible='off';
    h=uicontrol(f,"style","edit","string","10","position",[300 posLigne(indLigne) 40 20],"tag","BETA");
    beta=8.6;
    h.string=string(beta);
    h.visible='off';
    h=uicontrol(f,"style","text","string","dp","position",[270 posLigne(indLigne) 30 20],"tag","DPTEXTE");
    h.visible='off';
    h=uicontrol(f,"style","edit","string","10","position",[300 posLigne(indLigne) 40 20],"tag","DP");
    dp=0.005;
    h.string=string(dp);
    h.visible='off';
    
    
    // Bouton Signal temporel ***********************************
    indLigne=indLigne+1;
    fct="ModeAffichage(""STPS"")";
    h=uicontrol(f,"style","pushbutton","string","Signal","callback",fct,"Callback_Type",2,"position",[10 posLigne(indLigne) 100 20],"tag","STPS");
    h.backgroundcolor=[0.5 0.5 0.5];
    // Bouton TFD ***********************************
    indLigne=indLigne+1;
    fct="ModeAffichage(""TFD"")";
    h=uicontrol(f,"style","pushbutton","string","TFD","callback",fct,"Callback_Type",2,"position",[10 posLigne(indLigne) 100 20],"tag","TFD");
    h.backgroundcolor=[0.5 0.5 0.5];
    // Réglage des fréquences min et max du spectre
    h=uicontrol(f,"style","slider","position",[120 posLigne(indLigne)+20 200 10],"tag","FMIN","min",0,"max",Fe/2,"SliderStep",[10 1000],"TooltipString","réglage de la fréquence minimale affichée","callback",fct,"Callback_Type",2);
    h.value=0;
    fct="GestionFMinFMax()";
    h.callback=fct;
    h=uicontrol(f,"style","text","position",[320 posLigne(indLigne)+20 100 20],"tag","vFMIN","TooltipString","valeur Fréquence minimale affichée");
    h=uicontrol(f,"style","slider","position",[120 posLigne(indLigne)-10 200 10],"tag","FMAX","min",0,"max",Fe/2,"SliderStep",[10 1000],"TooltipString","réglage de la fréquence maximale affichée","callback",fct,"Callback_Type",2);
    h.callback=fct;
    h.value=Fe/2;
    h=uicontrol(f,"style","text","position",[320 posLigne(indLigne)-10 100 20],"tag","vFMAX","TooltipString","valeur de la fréquence maximale affichée");
    GestionFMinFMax();
    
    // Bouton PERIODOGRAMME ***********************************
    indLigne=indLigne+1;
    fct="ModeAffichage(""PERIO"")";
    h=uicontrol(f,"style","pushbutton","string","Periodogramme","callback",fct,"Callback_Type",2,"position",[10 posLigne(indLigne) 100 20],"tag","PERIO");
    h.backgroundcolor=[0.5 0.5 0.5];
    // Edition largeur de la fenêtre de la TFCT ***********************************
    fct="ParamPerio";
    h=uicontrol(f,"style","text","string","Largeur Fenêtre","position",[120 posLigne(indLigne) 80 20]);
    h=uicontrol(f,"style","edit","string","10","callback",fct,"Callback_Type",2,"position",[210 posLigne(indLigne) 50 20],"tag","LARFENETREP");
    h.string=string(larFenetre);
    h.backgroundcolor=[0.5 0.5 0];
    // Nombre d'échantillon entre deux TFD **************************
    h=uicontrol(f,"style","text","string","Pas de la fenêtre","position",[250 posLigne(indLigne) 100 20]);
    h=uicontrol(f,"style","edit","string","10","position",[350 posLigne(indLigne) 40 20],"tag","PASFENETREP");
    h.string=string(pasFenetre);
    h.backgroundcolor=[0.5 0.5 0];
    
    
    // Bouton TFCT ***********************************
    indLigne=indLigne+1;
    fct="ModeAffichage(""TFCT"")";
    h=uicontrol(f,"style","pushbutton","string","TFCT","callback",fct,"Callback_Type",2,"position",[10 posLigne(indLigne) 100 20],"tag","TFCT");
    h.backgroundcolor=[0.5 0.5 0.5];
    // Edition largeur de la fenêtre de la TFCT ***********************************
    fct="ParamTFCT";
    h=uicontrol(f,"style","text","string","Largeur Fenêtre","position",[120 posLigne(indLigne) 80 20]);
    h=uicontrol(f,"style","edit","string","10","callback",fct,"Callback_Type",2,"position",[210 posLigne(indLigne) 50 20],"tag","LARFENETRE");
    h.string=string(larFenetre);
    h.backgroundcolor=[0.5 0.5 0];
    // Nombre d'échantillon entre deux TFD **************************
    h=uicontrol(f,"style","text","string","Pas de la fenêtre","position",[250 posLigne(indLigne) 100 20]);
    h=uicontrol(f,"style","edit","string","10","position",[350 posLigne(indLigne) 40 20],"tag","PASFENETRE");
    h.string=string(pasFenetre);
    h.backgroundcolor=[0.5 0.5 0];
    
    // Bouton Ondelette ***********************************
    indLigne=indLigne+1;
    fct="ModeAffichage(""DWT"")";
    h=uicontrol(f,"style","pushbutton","string","DWT","callback",fct,"Callback_Type",0,"position",[10 posLigne(indLigne) 100 20],"tag","DWT");
    h.backgroundcolor=[0.5 0.5 0.5];
    if swtInstall==1 then
        h.enable='on';
    else
        h.enable='off';
    end
    // Liste pour le choix de l'ondelette
    fct="TypeOndelette()";
    h=uicontrol(f,"style","listbox","string",typeWv(1:11,1),"position",[130 posLigne(indLigne)-10 130 40],"tag","listeDWT","Relief","sunken","callback",fct,"Callback_Type",2);
    if swtInstall==1 then
        h.enable='on';
    else
        h.enable='off';
    end
    h.value=2;
    ondPossible=grep(nomWv,typeWv(h.value,2));
    fct="ChoixOndelette()";
    h=uicontrol(f,"style","listbox","string",nomWv(ondPossible),"position",[260 posLigne(indLigne)-10 60 40],"tag","WNAME","Relief","sunken","callback",fct,"Callback_Type",2);
    if swtInstall==1 then
        h.enable='on';
    else
        h.enable='off';
    end
    
endfunction

function NouveauFiltre()
    if (length(filtre)==0) then
        disp("Le filtre est vide. Au moins une valeur de gain doit être non nulle.")
        return;
    end
    ArretFiltre();
    DefNbCanaux(2);
    DefFreqEch(44100);
    PrepAcq(100,0);
    num=coeff(filtre.num);
    den=coeff(filtre.den);
    h=findobj("tag","FILTRER");
    h.backgroundcolor=[0.1 0.1 0.1];
    h=findobj("tag","ARRETER");
    h.backgroundcolor=[0.9 0.1 0.1];
    OuvrirFluxFiltrage(indFluxEntree,indFluxSortie,num,den);
    DebutAcq();
endfunction

function ArretFiltre()
    FinAcq();
    h=findobj("tag","FILTRER");
    h.backgroundcolor=[0.1 0.9 0.1];
    h=findobj("tag","ARRETER");
    h.backgroundcolor=[0.1 0.1 0.1];
endfunction

function ModifFiltre(idFiltre)
    global filtre       // Filtre somme des filtres
    global gainFiltre   // Gain du filtre
    global ordre        // Ordre du flitre i
    global fBasse       // Fréquence basse du filtre i
    global fHaute       // Fréquence haute du filtre i
    global typeFiltre   // Type du filtre i
    filtre2p=1;         // Passe à 0 lorsque la case fHaute est interdite
    
    tagOrdre=["Or"+string(idFiltre)];
    tagType=["Ty"+string(idFiltre)];
    tagFbasse=["Fb"+string(idFiltre)];
    tagFhaute=["Fh"+string(idFiltre)];
    tagAmplit=["Af"+string(idFiltre)];
    ArretFiltre();

    h=findobj("tag",tagType);
    if h~=[] then
        typeFiltre(idFiltre)=h.value;
        if h.value~=2 then
            filtre2p=0;    
        end
    end
    h=findobj("tag",tagOrdre);
    if h~= [] then
        ordre(idFiltre)=eval(h.string);
    end
    h=findobj("tag",tagFbasse);
    if h~= [] then
        fBasse(idFiltre)=eval(h.string);
    end
    h=findobj("tag",tagFhaute);
    if h~= [] then
        if filtre2p==0 then
            h.enable="off";
        else
            h.enable="on";
            fHaute(idFiltre)=eval(h.string);
        end
    end
    h=findobj("tag",tagAmplit);
    if h~= [] then
        gainFiltre(idFiltre)=eval(h.string);
    end
    typef=['lp';'bp';'hp'];
    hz=[];
    filtre=[];
    for i=1:nbFiltre
       if  fBasse(i) <fHaute(i) | typeFiltre(i)~=2 then
            hz=[hz;iir(ordre(i),typef(typeFiltre(i)),'ellip',[fBasse(i) fHaute(i)]/Fe,[0.1,0.1])];
            filtre=filtre+gainFiltre(i)*hz(2)(i)/hz(3)(i);
       else
            hz=[hz;1];
            disp("Attention la fréquence Fc1 doit être strictement inférieur à Fc2 ");
            disp([" pour le filtre "+string(i)]);
       end
    end
    
    f=scf(2);
    f.figure_name='Fonction de transfert';
    f.figure_position=[450 ,100];
    f.figure_size=[600 ,400];
    clf();
    [hzm,fr]=frmag(filtre.num,filtre.den,1024);
    plot(fr*44100,hzm)
    xlabel('frequence (Hz)');
    ylabel('Gain');
    title(['Nombre de coefficients : "+string(length( coeff(filtre.num))+length(coeff(filtre.den)))]);
endfunction

function InterfaceIIR(ff)
    global filtre       // Filtre somme des filtres
    global gainFiltre   // Gain du filtre
    global ordre        // Ordre du flitre i
    global fBasse       // Fréquence basse du filtre i
    global fHaute       // Fréquence haute du filtre i
    global typeFiltre   // Type du filtre i
    scf(ff);
    clf();
    ff.Figure_name=blanks(50)+"Egaliseur à base de filtre IIR";
    clf()
    ff.background=257;
    ffInterface.figure_position=[000 ,000];
    ff.figure_size=[430 ,nbFiltre*40+220];
    g=gca();
    g.background=257;
    ligne=nbFiltre*40+60;
    h=uicontrol(ff,"style","pushbutton","string","Ana. Spectre","position",[10 ligne-20 90 60],"callback","BasculeInter(2)","Callback_Type",2,"tag","ANASPEC");
    h.backgroundcolor=[0.3 0.6 0.3];
    h=uicontrol(ff,"style","pushbutton","string","FILTRER","position",[110 ligne 100 20],"callback","NouveauFiltre()","Callback_Type",2,"tag","FILTRER");
    h.backgroundcolor=[0.1 0.9 0.1];
    
    h=uicontrol(ff,"style","pushbutton","string","ARRETER","position",[210 ligne 100 20],"callback","ArretFiltre()","Callback_Type",2,"tag","ARRETER");
    h.backgroundcolor=[0.1 0.1 0.1];
    ligne =ligne-40;
    // titre des colonnes 
    h=uicontrol(ff,"style","text","string","Ordre","position",[70 ligne 40 20]);
    h=uicontrol(ff,"style","text","string","type","position",[110 ligne 100 20]);
    h=uicontrol(ff,"style","text","string","Fc1 (Hz)","position",[220 ligne 50 20]);
    h=uicontrol(ff,"style","text","string","Fc2 (Hz)","position",[270 ligne 50 20]);
    h=uicontrol(ff,"style","text","string","Gain","position",[340 ligne 50 20]);
    ligne=ligne-20;
    //Mise en place des paramètres des filtres  ***********************************

    for i=1:nbFiltre
        fct="ModifFiltre("+string(i)+")";
        texte=["Filtre "+string(i)];
        // Texte
        h=uicontrol(ff,"style","text","string",texte,"position",[10 ligne 60 20]);
        // Ordre du filtre
        of=["Or"+string(i)];
        h=uicontrol(ff,"style","edit","string","1","position",[70 ligne 40 20],"tag",of,"callback",fct,"Callback_Type",2);
        h.string=string(ordre(i));
        h.backgroundColor=[0.5,0.5,0];
        // Liste type de filtre passe bas,passe bande, passe haut
        of=["Ty"+string(i)];
        fenetre=['Passe bas';'Passe bande';'Passe haut'];
        h=uicontrol(ff,"style","listbox","string",fenetre,"position",[110 ligne 100 20],"tag",of,"Relief","sunken","callback",fct,"Callback_Type",2);
        h.value=typeFiltre(i);
        h.ListboxTop=h.value;
        // Texte
        // Fréquence basse du filtre
        of=["Fb"+string(i)];
        h=uicontrol(ff,"style","edit","string","1","position",[220 ligne 50 20],"tag",of,"callback",fct,"Callback_Type",2);
        fBasse(i)=min(Fe/2,round(10^(i/nbFiltre*4)));
        h.string=string(fBasse(i));
        // Fréquence haute du filtre
        of=["Fh"+string(i)];
        h=uicontrol(ff,"style","edit","string","1","position",[270 ligne 50 20],"tag",of,"callback",fct,"Callback_Type",2);
        fHaute(i)=min(Fe/2,round(10^((i+1)/nbFiltre*4)));
        h.string=string(fHaute(i));
        // Amplitude du filtre
        of=["Af"+string(i)];
        h=uicontrol(ff,"style","edit","string",string(gainFiltre(i)),"position",[340 ligne 50 20],"tag",of,"callback",fct);

    ligne=ligne-40;
end
endfunction

//
// Programme Principal
// 
// Variables globales
global fFig // Liste des figures
global fAxe // Liste des axes
global multiFenetre // Affichage des analyses dans une ou plusieurs fenêtres
global paletteAna // Palette de couleur utilisée
global indFluxEntree        // Periphérique audio d'entrée sélectionné
global indFluxSortie        // Periphérique audio de sortie sélectionné
global modeAffichage   // Données
global D Fe nbEch// Durée du signal fréquence d'échantillonnage
global fMin fMax // Fréquence minimale et maximale affichée
global indTFD // Indice associés aux fréquences
global indTFCT // Indice associés aux fréquences pour la TFCT
global indPERIO // Indice associés aux fréquences pour le périodogramme
global larFenetreP  // largeur de la fenêtre de pondération periodogramme
global pasFenetreP  // pas d'avance de la fenetre
global y   // Données
global wTFCT wTFD  // Fenetre de pondération TFCT et TFD
global larFenetre  // largeur de la fenêtre de pondération
global pasFenetre  // Discrétisation de tau
global typeWv nomWv // Tableau des types et noms des ondelettes
global wname nivMax // Nom de l'ondelette et niveau maximum de décomposition
global hTpsReel     // Champ statique Temps-réel
global fctPond      // liste des fonctions de pondération
global ffInterface  // identifiant de la figure contenant l'interface
//
global filtre       // Filtre somme des filtres
global gainFiltre   // Gain du filtre
global ordre        // Ordre du flitre i
global fBasse       // Fréquence basse du filtre i
global fHaute       // Fréquence haute du filtre i
global typeFiltre   // Type du filtre i

nbFiltre=8;
ordre=ones(nbFiltre,1);
gainFiltre=zeros(nbFiltre,1);
fBasse=zeros(nbFiltre,1);
fHaute=zeros(nbFiltre,1);
typeFiltre=2*ones(nbFiltre,1);

// Constantes
mSTPS = 1;  // Affichage du signal temporel
mTFD = 2;  // Affichage du spectre
mPERIO = 4;  // Affichage du periodogramme de Welsh
mTFCT = 8;  // Affichage du signal temporel
mDWT = 16;  // Affichage du signal temporel

modeIIR=1;  // Interface IIR
modeSPEC=2; // Interface Spectre
multiFenetre = 0;
lFctPond=['re','tr','hn','hm','kr','ch'];
// Vérification de la présence de swt
if grep(atomsGetInstalled(),'swt')~=[]
    swtInstall=1;
else
    swtInstall=0;
end

dataRep=[SCI+"/contrib/AnaSpec/"];
typeWv=csvRead(dataRep+'/typeOndelette.txt','\t','.','string');
nomWv=csvRead(dataRep+'/nomOndelette.txt','\n','.','string');
  
indFlux=0;
modeAffichage=0;
nbEch=4096;
larFenetreP=fix(nbEch/16);
pasFenetreP=larFenetreP/4;
larFenetre=fix(nbEch/16);
pasFenetre=larFenetre/4;
Fe=44100;
fMin=0;fMax=Fe/2;
D=10;
wname='db1';

// Mise en place de l'interface sur la figure 1000
fFig(1:5)=figure(1001);
fAxe(1:5)=newaxes();
ffInterface=figure(1000);
close(fFig(1));
indFluxEntree=0;
indFluxSortie=0;
InterfaceSpec(ffInterface);
InstallMenuPeriph(ffInterface,modeSPEC);
