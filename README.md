Noise reduction in audio signal using spectral substraction method

1. Project description
	
   Spectral substraction method is used to recover original signal from its noisy realization (measurment). 
   To perform it, some assumptions are made:
   - signal is noised with white, uniformly distributed noise
   - first seconds of signal is noise only
   
   To eliminate signal discontinuities that may occur at the beginning/end of each denoised speech segment, 'overlap-add' technic is used.
   
