#ifndef __LIENPORTAUDIO__
#define __LIENPORTAUDIO__
// Le bloc ifdef suivant est la façon standard de créer des macros qui facilitent l'exportation 
// à partir d'une DLL. Tous les fichiers contenus dans cette DLL sont compilés avec le symbole DLLSCILAB_EXPORTS
// défini sur la ligne de commande. Ce symbole ne doit pas être défini dans les projets
// qui utilisent cette DLL. De cette manière, les autres projets dont les fichiers sources comprennent ce fichier considèrent les fonctions 
// DLLSCILAB_API comme étant importées à partir d'une DLL, tandis que cette DLL considère les symboles
// définis avec cette macro comme étant exportés.

#include "portaudio.h"
#ifdef _WINDOWS
#ifdef _USRDLL
#define DLLSCILABPORTAUDIO_EXPORTS __declspec(dllexport)
#else 
#define DLLSCILABPORTAUDIO_EXPORTS __declspec(dllimport)
#endif //DLLSCILABPORTAUDIO_EXPORTS
#else
#define DLLSCILABPORTAUDIO_EXPORTS
#endif //_WINDOWS


#define SAMPLE float
#define SAMPLE_RATE
#define SAMPLE_SILENCE  (0)
#define NUM_CHANNELS 2
#define PA_SAMPLE_TYPE      paFloat32
//#define FRAMES_PER_BUFFER   (16)
#define ORDREMAX    20

typedef struct
{
	int				nbCanaux;				// Nombre de canaux
    int				indexDonnee;			// index de la prochaine donnée. 
    int				nbDonneeMax;			// Nombre de données maximales sur un canal
	float			*canal32[2];			// float 32 bits
	float			*xin;					// Buffer entrée pour le filtrage IIR
	float			*xout;					// Buffer sortie pour le filtrage IIR
	int				ordre;
	float			den[ORDREMAX];
	float			num[ORDREMAX];
}
ZoneAudio;


class DLLSCILABPORTAUDIO_EXPORTS PortAudio {
    PaStreamParameters  paramEntree,
                        paramSortie;
    PaStream*           flux;
    PaError             err;
	ZoneAudio			audio;
	int					init;

	int				nbEch;
	int				nbCanaux;
	int				nbOctets;
	int				freqEch;
	int				nouIndex;		// Index de la dernière donnée valide
	int				preIndex;		// Index de la dernière donnée lue
	unsigned long	tailleBuffer;

public :
// Constructeur par défaut Fe=44100hz nbEch=1024 2 canaux
PortAudio(double );
int InitPortAudio();
int FermerPortAudio();
int NbPeripherique();
const char* NomPeripherique(int);
int NbEntree(int);
int NbSortie(int);
void DefFreqEch(int);
void DefNbEch(int);
void DefTailleBuffer(int f);
void DefNbCanaux(int);
void PrepAcq(double =-1,int =-1);
void PrepAcqContinu();
void OuvrirFlux();
void OuvrirFluxFiltrage(int indFluxEntree,int indFluxSortie,int &o,double *num,double *den);
void DebutAcq();
int Lecture(int &index);
void FinAcq();
int LireDonnee(int ,double *,int *);
int Erreur(){return err;};
int LireNbEch(){return audio.nbDonneeMax;};
};


#endif
