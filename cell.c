#include <stdio.h>
#include <stdlib.h>

extern char state_[];
extern int WorldWidth;
extern int WorldLength;

int calc_actual_location(int,int);
int calc_alive_neighbors(int,int);
int valueAt(int,int);
int isAlive(int,int);
int min(int,int);
/**
 * gets the cell's coordinate and return 0 if in the next turn the cell is dead and 1 otherwise
 */
int cell(int x, int y) {
    
    int alive_neig = calc_alive_neighbors(x, y);
    int age = valueAt(x, y);
	int result = 0;
	
    if( isAlive(x,y) == 1 ) {
		/* cell is alive */
        if ( (2 == alive_neig) || (3 == alive_neig) ) {
            result = min(age + 1, 9);   /* stays alive (max age = 9) */
        }
    } else { /* cell is dead */
		if ( 3 == alive_neig ) {
			result = 1;   /* born */
		}
	}
	
	return ( result + '0') ;
}

/**
 * returns the cell's actual location in state buffer
 */
int calc_actual_location(int x, int y) {
 
    return (x * WorldWidth) + y;
}

/**
 * checks if current cell is alive (return 1) or dead (return 0)
 */
int isAlive(int x, int y) {
 
    int age = valueAt(x,y);
  
    if( age == 0) {
        return 0;
    }
    return 1;
}

/**
 * returns current cell's value
 */
int valueAt(int x, int y) {
 
    char actual = calc_actual_location(x,y);
	int ac = actual - '0';
    return ((int) state_[ac]);
}

/**
 * returns the number of neighbors of current cell
 */
int calc_alive_neighbors(int x, int y) {
    
    int arr[3] = { -1, 0, 1};
    int i = 0, j = 0;
    int count = 0, nx = 0, ny = 0;
    
    for ( ; i < 3 ; i++ ){
        
        nx = (x + arr[i] + WorldLength) % WorldLength;
        j = 0;
        for (  ; j < 3 ; j++ ) {
           
            if( (i==1) && (j==1) ) { continue; } /* current cell ignored */

            ny = (y + arr[j] + WorldWidth) % WorldWidth;
            count += isAlive(nx,ny);
        }
    }
    
    return count;
}

int min(int x, int y) {
 
    if ( x>y ) return y;
    return x;
}

/*
void test () {
    
    int i=0,j=0;
    int targetx = 0, targety = 1;
    int actual=0;
    
    printf("WorldLength %d \n",WorldLength);
    printf("WorldWidth %d \n\n",WorldWidth);

    for( i=0 ; i<WorldLength ; i++){
        for( j=0 ; j<WorldWidth ; j++){
                actual = calc_actual_location(i,j);
                if( targetx==i && targety==j){
                    printf("h");
                }
                printf("%d ",state_[actual]);
        }
        printf("\n");
    }
    
    
    int ans = cell(targetx,targety);
    printf("answer: %d\n",ans);
    exit(1);
}
*/

/*void print() {
    
    int i=0,j=0;
    int actual=0;
    
    printf("\n");
    
    for( i=0 ; i<WorldLength ; i++){
        for( j=0 ; j<WorldWidth ; j++){
                actual = calc_actual_location(i,j);
                printf("%d ",state_[actual]);
        }
        printf("\n");
    }
    
    exit(1);
}*/
