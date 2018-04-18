#include <iostream>
#include <stdlib.h>

__global__ void staticReverse(int *d, int n)
{
	__shared__ int s[64]; //static shared memory allocation
	int t = threadIdx.x; 
	int tr = n - threadIdx.x - 1;
	if(t < n)
	{
		s[t] = d[t]; 
		__syncthreads(); //None shall pass
		d[t] = s[tr];
	}
}

__global__ void dynamicReverse(int *d, int n)
{
	extern __shared__ int s[]; 
	int t = threadIdx.x;
	int tr = n-t-1; 
	if(t < n)
	{
		s[t] = d[t];
		__syncthreads();
		d[t] = s[tr];
	}
}

int main()
{
	const int n = 64; 
	int *a, *d_a; 
	a = (int*)malloc(n*sizeof(int));
	cudaMalloc(&d_a, n*sizeof(int)); 

	for(int i =0; i < n; i++)
		a[i] = i; 
	
	cudaMemcpy(d_a, a, n*sizeof(int), cudaMemcpyHostToDevice); // Transfer to device

	dynamicReverse<<<1, n, n*sizeof(int)>>>(d_a, n); //grid ,block ,shared
	
	cudaMemcpy(a,d_a, n*sizeof(int), cudaMemcpyDeviceToHost); //bring it back
	
	std::cout<<a[0]<<std::endl;
	free(a);
	cudaFree(d_a);
	return 0;
}
