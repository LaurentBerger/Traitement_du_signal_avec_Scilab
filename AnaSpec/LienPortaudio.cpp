#include "LienPortaudio.h"
#include <iostream>
#include <fstream>
using namespace std;


static int FiltrageIIR( const void *inputBuffer, void *outputBuffer,
                         unsigned long framesPerBuffer,
                         const PaStreamCallbackTimeInfo* timeInfo,
                         PaStreamCallbackFlags statusFlags,
                         void *userData )
{
    SAMPLE *out = (SAMPLE*)outputBuffer;
    const SAMPLE *in = (const SAMPLE*)inputBuffer;
     int i,j;
    float *x=(float*)((ZoneAudio*)userData)->xin;    // Entrée
    float *y=(float*)((ZoneAudio*)userData)->xout;    //Sortie
	int ordre=((ZoneAudio*)userData)->ordre;
	float *a=((ZoneAudio*)userData)->den;
	float *b=((ZoneAudio*)userData)->num;



    x+=ordre;
    y+=ordre;

    if( inputBuffer == NULL )
    {
        for( i=0; i<framesPerBuffer; i++ )
        {
            *out++ = 0;  /* left - silent */
            *out++ = 0;  /* right - silent */
        }
    }
    else
    {
        for( i=0; i<framesPerBuffer; i++ )
        {
            *x = *in++;
			*in++;
            *y=x[0]*b[0];
			
            for (j=1;j<ordre;j++)
                *y += (x[-j]*b[j]-y[-j]*a[j]);
			*out++ =*y;
            *out++= *y++;
            x++;
        }
		x=(float*)((ZoneAudio*)userData)->xin;
		y=(float*)((ZoneAudio*)userData)->xout;
		for (i=0;i<ordre;i++)
			{
			x[ordre-1-i]=x[framesPerBuffer-1-i+ordre];
			y[ordre-1-i]=y[framesPerBuffer-1-i+ordre];
			}

    }

    return paContinue;
}



/* This routine will be called by the PortAudio engine when audio is needed.
** It may be called at interrupt level on some machines so don't do anything
** that could mess up the system like calling malloc() or free().
Par défaut les données sont de type short
*/
static int recordCallback( const void *inputBuffer, void *outputBuffer,
                           unsigned long framesPerBuffer,
                           const PaStreamCallbackTimeInfo* timeInfo,
                           PaStreamCallbackFlags statusFlags,
                           void *userData )
{
    ZoneAudio *data = (ZoneAudio*)userData;
    const float *rptr = (const float*)inputBuffer;
    float *wptr1 = (data->canal32[0])+data->indexDonnee;
    float *wptr2 = (data->canal32[1])+data->indexDonnee;
    long framesToCalc;
    long i;
    int finished;
    unsigned long framesLeft = data->nbDonneeMax - data->indexDonnee;

    (void) outputBuffer; /* Prevent unused variable warnings. */
    (void) timeInfo;
    (void) statusFlags;
    (void) userData;

    if( framesLeft < framesPerBuffer )
    {
        framesToCalc = framesLeft;
        finished = paComplete;
    }
    else
    {
        framesToCalc = framesPerBuffer;
        finished = paContinue;
    }

    if( inputBuffer == NULL )
    {
		if(data->nbCanaux==2)
			for( i=0; i<framesToCalc; i++ )
			{
				*wptr1++ = SAMPLE_SILENCE;  /* left */
				*wptr2++ = SAMPLE_SILENCE;  /* right */
			}
		else
			for( i=0; i<framesToCalc; i++ )
			{
				*wptr1++ = SAMPLE_SILENCE;  /* left */
			}

    }
    else
    {
 		if(data->nbCanaux==2)
			for( i=0; i<framesToCalc; i++ )
			{
				*wptr1++ = *rptr++;  /* left */
				*wptr2++ = *rptr++;  /* right */
			}
		else
			for( i=0; i<framesToCalc; i++ )
			{
				*wptr1++ = *rptr++;  /* left */
			}

    }
    data->indexDonnee += framesToCalc;
    return finished;
}

PortAudio::PortAudio(double nbSecondes)
{ 
err = paNoError;
freqEch=44100;
nbEch=1024;
audio.nbCanaux=2;
audio.indexDonnee = 0;
audio.canal32[0]=NULL;
audio.canal32[1]=NULL;
audio.xin=NULL;
audio.xout=NULL;
tailleBuffer =512;
if (nbSecondes!=1.988)
	PrepAcq(nbSecondes);
}

void PortAudio::DefFreqEch(int f)
{
freqEch=f;
}

void PortAudio::DefTailleBuffer(int f)
{
tailleBuffer=f;
}

void PortAudio::DefNbEch(int n)
{
nbEch=n;
}

void PortAudio::DefNbCanaux(int n)
{
nbCanaux=n;
}

void PortAudio::PrepAcqContinu()
{
}

int PortAudio::NbPeripherique()
{
return int(Pa_GetDeviceCount( ) );
}

int PortAudio::InitPortAudio()
{
	PaError p=0;
	if (init==0)
		{
			p=Pa_Initialize();
			if (p==paNoError)
				init=1;
			
	}
	return int(p);
}
int PortAudio::FermerPortAudio()
{
	PaError p=0;
	if (init==1)
		{
			p=Pa_Terminate();
			if (p==paNoError)
				init=0;
			
	}
	return int(p);
}

const char * PortAudio::NomPeripherique(int ind)
{
	if (ind>=0 && ind<NbPeripherique())
	{
		const PaDeviceInfo *x;
		x=Pa_GetDeviceInfo(ind);
		return x->name;
	}
	else
		return NULL;
}

int PortAudio::NbEntree(int ind)
{
	if (ind>=0 && ind<NbPeripherique())
	{
		const PaDeviceInfo *x;
		x=Pa_GetDeviceInfo(ind);
		return x->maxInputChannels;
	}
	else
		return -1;

}

int PortAudio::NbSortie(int ind)
{
	if (ind>=0 && ind<NbPeripherique())
	{
		const PaDeviceInfo *x;
		x=Pa_GetDeviceInfo(ind);
		return x->maxOutputChannels;
	}
	else
		return -1;
}


void PortAudio::PrepAcq(double nbSecondes,int indPeriph)
{
if (audio.canal32[0]!=NULL)
	delete audio.canal32[0];
if (audio.canal32[1]!=NULL)
	delete audio.canal32[1];

preIndex=0;
audio.nbDonneeMax =  nbSecondes * freqEch; /* Record for a few seconds. */
audio.indexDonnee = 0;
nbEch = audio.nbDonneeMax;
nbOctets = nbEch * sizeof(float);
audio.canal32[0] =  new float[ nbEch ]; /* From now on, recordedSamples is initialised. */
if (audio.nbCanaux==2)
	audio.canal32[1] = new float[ nbEch ]; /* From now on, recordedSamples is initialised. */
if(  audio.canal32[0]==NULL || (audio.canal32[1] == NULL && audio.nbCanaux==2))
{
    err = 1;
}
else
	{
		if (init==0)
			InitPortAudio();
		for(int i=0; i<nbEch; i++ ) 
			{
			(audio.canal32[0])[i] = 0;
			if 	(audio.canal32[1] !=NULL)
				(audio.canal32[1])[i] = 0;
			}
		if( init == 1 ) 
		{
			if (indPeriph==-1)
				paramEntree.device = Pa_GetDefaultInputDevice(); /* default input device */
			else
				paramEntree.device = indPeriph; /* default input device */
			if (paramEntree.device == paNoDevice) 
			{
				err = 1;
			}
			else
			{
				paramEntree.channelCount = audio.nbCanaux;         /* stereo input */
				paramEntree.sampleFormat = paFloat32;
				paramEntree.suggestedLatency = Pa_GetDeviceInfo( paramEntree.device )->defaultLowInputLatency;
				paramEntree.hostApiSpecificStreamInfo = NULL;
			}
		}
	}
}

void PortAudio::OuvrirFluxFiltrage(int indFluxEntree,int indFluxSortie,int &o,double *num,double *den)
{
if (init==0)
	InitPortAudio();
if (init==0)
	return;
if (o>ORDREMAX)
	o=ORDREMAX;
for (int i=0;i<ORDREMAX;i++)
	audio.den[i]=0;
for (int i=0;i<ORDREMAX;i++)
	audio.num[i]=0;
audio.ordre=o;
for (int i=0;i<audio.ordre && i<ORDREMAX;i++)
	audio.num[i]=num[i];
for (int i=0;i<audio.ordre && i<ORDREMAX;i++)
{
	audio.den[i]=den[audio.ordre-i-1];
}
audio.den[0]=0;

delete audio.xin;
delete audio.xout;
audio.xin =(float*)new float[2*(tailleBuffer+ORDREMAX)];
audio.xout =(float*)new float[2*(tailleBuffer+ORDREMAX)];
for (int i=0;i<2*(tailleBuffer+ORDREMAX);i++)
	{
	audio.xin [i]=0;
	audio.xout [i]=0;
	}

paramEntree.device = indFluxEntree;//Pa_GetDefaultInputDevice(); /* default input device */
if (paramEntree.device == paNoDevice) {
    return;
}
paramEntree.channelCount = 2;       /* stereo input */
paramEntree.sampleFormat = PA_SAMPLE_TYPE;
paramEntree.suggestedLatency = Pa_GetDeviceInfo( paramEntree.device )->defaultLowInputLatency;
paramEntree.hostApiSpecificStreamInfo = NULL;
paramSortie.device = indFluxSortie;//Pa_GetDefaultOutputDevice(); /* default output device */
if (paramSortie.device == paNoDevice) {
    return;
}
paramSortie.channelCount = 2;       /* stereo output */
paramSortie.sampleFormat = PA_SAMPLE_TYPE;
paramSortie.suggestedLatency = Pa_GetDeviceInfo( paramSortie.device )->defaultLowOutputLatency;
paramSortie.hostApiSpecificStreamInfo = NULL;
err = Pa_OpenStream(
            &flux,
            &paramEntree,
            &paramSortie,
            freqEch,
            tailleBuffer,
            0, /* paClipOff, */  /* we won't output out of range samples so don't bother clipping them */
            FiltrageIIR,
            &audio );

return;

return;

}


void PortAudio::OuvrirFlux()
{
	if (init==0)
		return;
	err = Pa_OpenStream(
				&flux,
				&paramEntree,
				NULL,                  /* &outputParameters, */
				freqEch,
				tailleBuffer,
				paClipOff,      /* we won't output out of range samples so don't bother clipping them */
				recordCallback,
				&audio );
}

void PortAudio::DebutAcq()
{
	if (init==0)
		return;
	if( err == paNoError ) 
	{

		err = Pa_StartStream( flux );
	}
}

int PortAudio::Lecture(int &index)
{
if (init==0)
	return 1;
err = Pa_IsStreamActive( flux );
err = !(err==1);
index = audio.indexDonnee;
return err;
}


void PortAudio::FinAcq()
{
	if( err >= 0 ) 
		err = Pa_CloseStream( flux );
}

int PortAudio::LireDonnee(int nbVal,double *x,int *pos)
{
	if (init==0)
		return 1;
	int index;
	int max=nbVal;
	err=Lecture(index);
	index=index-1;		// Dernière donnée valide
	float *ptr=(audio.canal32[0]);
	if (index-nbVal+1>=0)
	{
		ptr += index-nbVal+1;
		*pos = nbVal-(index-preIndex+1);
		max = nbVal;
	}
	else
	{
		*pos = (index-nbVal+1);
		max = index+1;

	}
	for (int i=0;i<max;i++)
		x[i]=double(*ptr++);
	
	preIndex=index+1;
	return err;
}
