
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#include "LienPortaudio.h"

#ifdef _USRDLL
extern "C" {
DLLSCILABPORTAUDIO_EXPORTS void TestParam(double *xin,int *you,int *err);
DLLSCILABPORTAUDIO_EXPORTS void InitPortAudio(int *);
DLLSCILABPORTAUDIO_EXPORTS void FermerPortAudio(int *);
DLLSCILABPORTAUDIO_EXPORTS void NbPeripherique(int *);
DLLSCILABPORTAUDIO_EXPORTS void NomPeripherique(int *,char *);
DLLSCILABPORTAUDIO_EXPORTS void NbEntree(int *,int *);
DLLSCILABPORTAUDIO_EXPORTS void NbSortie(int *,int*);
DLLSCILABPORTAUDIO_EXPORTS void PrepAcq(double *tps,int *,int *);
DLLSCILABPORTAUDIO_EXPORTS void OuvrirFlux(int *);
DLLSCILABPORTAUDIO_EXPORTS void OuvrirFluxFiltrage(int *,int *,int *,int *o,double *num,double *den);
DLLSCILABPORTAUDIO_EXPORTS void DebutAcq(int *);
DLLSCILABPORTAUDIO_EXPORTS void FinAcq(int *);
DLLSCILABPORTAUDIO_EXPORTS void LectureDonnee(int *nbVal,double *x,int *err,int *pos);
DLLSCILABPORTAUDIO_EXPORTS void Lecture(int *index,int *err);
DLLSCILABPORTAUDIO_EXPORTS void DefNbEch(int *index,int *err);
DLLSCILABPORTAUDIO_EXPORTS void DefTailleBuffer(int *index,int *err);
DLLSCILABPORTAUDIO_EXPORTS void DefFreqEch(int *index,int *err);
DLLSCILABPORTAUDIO_EXPORTS void DefNbCanaux(int *index,int *err);
DLLSCILABPORTAUDIO_EXPORTS PortAudio carte(1.988);
}
#else
#define DLLSCILABPORTAUDIO_EXPORTS
PortAudio carte(10);
#endif

DLLSCILABPORTAUDIO_EXPORTS  void InitPortAudio(int *res)
{
	*res = carte.InitPortAudio();
}

DLLSCILABPORTAUDIO_EXPORTS  void FermerPortAudio(int *res)
{
	*res = carte.FermerPortAudio();
}


DLLSCILABPORTAUDIO_EXPORTS  void  NomPeripherique(int *ind,char *s)
{
	s[255]=0;
	strncpy(s, carte.NomPeripherique(*ind),255);
}

DLLSCILABPORTAUDIO_EXPORTS  void NbPeripherique(int *res)
{
	*res = carte.NbPeripherique();
}

DLLSCILABPORTAUDIO_EXPORTS  void NbEntree(int *ind,int *res)
{
	*res= carte.NbEntree(*ind);
}


DLLSCILABPORTAUDIO_EXPORTS  void NbSortie(int *ind,int *res)
{
	*res= carte.NbSortie(*ind);
}




DLLSCILABPORTAUDIO_EXPORTS  void TestParam(double *xin,int *you,int *err)
{
	*you=carte.LireNbEch()+1234; 
	carte.PrepAcq(*xin,-1);
	*err = carte.LireNbEch() ;
}

DLLSCILABPORTAUDIO_EXPORTS  void PrepAcq(double *tps,int *indPeriph,int *err)
{
	carte.PrepAcq(*tps,*indPeriph);
	*err=carte.Erreur(); 
}


DLLSCILABPORTAUDIO_EXPORTS  void DefFreqEch(int *f,int *err)
{
	carte.DefFreqEch(*f);
	*err=carte.Erreur(); 
}

DLLSCILABPORTAUDIO_EXPORTS  void DefTailleBuffer(int *f,int *err)
{
	carte.DefTailleBuffer(*f);
	*err=carte.Erreur(); 
}

DLLSCILABPORTAUDIO_EXPORTS  void DefNbEch(int *n,int *err)
{
	carte.DefNbEch(*n);
	*err=carte.Erreur(); 
}
DLLSCILABPORTAUDIO_EXPORTS  void DefNbCanaux(int *n,int *err)
{
	carte.DefNbCanaux(*n);
	*err=carte.Erreur(); 
}


DLLSCILABPORTAUDIO_EXPORTS  void OuvrirFlux(int *err)
{
	carte.OuvrirFlux();
	*err=carte.Erreur(); 
	if (*err==int(paUnanticipatedHostError) )
		*err =(int) Pa_GetLastHostErrorInfo();
			
}

#include <fstream>
using namespace std;

DLLSCILABPORTAUDIO_EXPORTS  void OuvrirFluxFiltrage(int *iEntree,int *iSortie,int *err,int *o,double *num,double *den)
{
{
ofstream ff("f:\\laurent\\test.txt",ios::app);
if (ff.is_open())
{
	ff<<"Appel OuvrirFluxFiltrage"<<endl;
	ff.flush();
	ff.close();
}
}
	carte.OuvrirFluxFiltrage(*iEntree,*iSortie,*o,num,den);
{
ofstream ff("f:\\laurent\\test.txt",ios::app);
if (ff.is_open())
{
	ff<<"Appel Erreur"<<endl;
	ff.flush();
	ff.close();
}
}
	*err=carte.Erreur(); 
{
ofstream ff("f:\\laurent\\test.txt",ios::app);
if (ff.is_open())
{
	ff<<" Erreur"<<*err<<endl;
	ff.flush();
	ff.close();
}
}
	if (*err==int(paUnanticipatedHostError) )
		*err =(int) Pa_GetLastHostErrorInfo();
}



DLLSCILABPORTAUDIO_EXPORTS  void DebutAcq(int *err)
{
carte.DebutAcq();
*err=carte.Erreur(); 
}

DLLSCILABPORTAUDIO_EXPORTS  void LectureDonnee(int *nbVal,double *x,int *err,int *pos)
{
	int i;
	carte.LireDonnee(*nbVal,x,pos);
	*err=carte.Erreur();
}

DLLSCILABPORTAUDIO_EXPORTS  void Lecture(int *index,int *err)
{
	*err=carte.Lecture(*index);
}


DLLSCILABPORTAUDIO_EXPORTS  void FinAcq(int *err)
{
	carte.FinAcq();
	*err = carte.Erreur();
}


