#include <stdio.h>
#include <stdlib.h>

extern char state_[];
extern int WorldWidth;
extern int WorldLength;

int calc_actual_location(int,int);
int calc_alive_neighbors(int,int);
int isAlive(int,int);

/**
 * gets the cell's coordinate and return 0 if in the next turn the cell is dead and 1 otherwise
 */
int cell(int x, int y) {
    
    int alive_neig = calc_alive_neighbors(x, y);
    
  /*  printf("our cell is %d\n", isAlive(x,y));
    printf("our cell had %d brothers \n", alive_neig);*/
    
    if( isAlive(x,y) == 1 ) {
    /* cell is alive */
        if ( (2 == alive_neig) || (3 == alive_neig) ) {
            return 1;   /* stays alive */
        } else {
            return 0;   /* dies */
        }
    } 
    /* cell is dead */
    if ( 3 == alive_neig ) {
        return 1;   /* born */
    } else {
        return 0;   /* stays dead */
    }
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
 
    int actual = calc_actual_location(x,y);
   /* printf("actual in cell [%d,%d]=%d  ",x,y,actual);*/
    if( state_[actual] == 0) {
       /* printf("dead\n\n");*/
        return 0;
    }
  /*  printf("alive\n\n");*/
    return 1;
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
            
            
           /** printf("ny = (%d + %d + %d) mod %d \n ", x,arr[i],WorldWidth,WorldWidth);
            printf("ny = (%d + %d + %d) mod %d \n ", y,arr[j],WorldLength,WorldLength);*/
            ny = (y + arr[j] + WorldWidth) % WorldWidth;
            /*printf("nieghbor [%d][%d]=[%d][%d] is %d\n" ,arr[i],arr[j],nx,ny,isAlive(nx,ny));*/
            count += isAlive(nx,ny);
        }
    }
    
    return count;
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