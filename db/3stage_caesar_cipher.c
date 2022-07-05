#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <pthread.h>
#include <stdlib.h>
#include <stdio.h>
#include <limits.h> 
#include <string.h>
#include <arpa/inet.h>
#define UPPERCASE_A_CHAR 65
#define UPPERCASE_Z_CHAR 90
#define LOWERCASE_A_CHAR 97
#define LOWERCASE_Z_CHAR 122

//function to generate a random vector
void randstring(char* stringa) {

    static char charset[] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789,.-#'?!";        
    char randomString[356];
         
    for (int n = 0;n < 356;n++) {            
        int key = rand() % (int)(sizeof(charset) -1);
        randomString[n] = charset[key];
    }

    randomString[356] = '\0';

    strcpy(stringa,randomString);
}

void randstring_2(char* stringa) {

    static char charset[] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789,.-#'?!";        
    char randomString[54];
         
    for (int n = 0;n < 54;n++) {            
        int key = rand() % (int)(sizeof(charset) -1);
        randomString[n] = charset[key];
    }

    randomString[54] = '\0';

    strcpy(stringa,randomString);
}

int main(int argc, char* argv[]){

    //input mode, k1,k3,shift1, shift3
    srand(time(NULL));
    int mode, d1, d3, shift1, shift3;
    int shift2, k2;

    bool err_invalid_key_shift_num,
        ptxt_char_is_uppercase_letter,
        ptxt_char_is_lowercase_letter,
        ptxt_char_is_letter,
        err_invalid_ptxt_char;

    mode = atoi(argv[1]);
    d1 = atoi(argv[2]);
    d3 = atoi(argv[3]);
    shift1 = atoi(argv[4]);
    shift3 = atoi(argv[5]);

    //control for the inpit
    if(mode != 0 && mode != 1)
        return 0;
    if(d1 != 0 && d1 != 1)
        return 0;
    if(d3 != 0 && d3 != 1)
        return 0;

    err_invalid_key_shift_num = shift1 > 26 || shift3 > 26 || shift1 == shift3; //generation of the err_invalid_key_shift_ num signal

    shift2 = (shift1 + shift3)%27; //generation of the key_shidt_num_x

    FILE* fd,*fd2,*fd3;
    char ctxt[1];
    char ptxt[1];


    if(!mode){ //encryption

    printf("Cifratura on\n");

        char stringa_prova[356];
        randstring(stringa_prova);
        fd = fopen("./prova.txt","w"); 
        fwrite(stringa_prova,sizeof(char),356,fd); //the file prova.txt is written with a random vector
        fclose(fd);
        fd = fopen("./prova.txt","r");
        fd2 = fopen("enc.txt","w");
        fclose(fd2);
        fd2 = fopen("enc.txt","a+");
    
        //read char by char the file prova.txt
        while((*ptxt = fgetc(fd)) != EOF){

            ptxt[1]='\0';

            memset(ctxt,0,sizeof(ctxt));

            ptxt_char_is_uppercase_letter = (*ptxt >= UPPERCASE_A_CHAR) && (*ptxt <= UPPERCASE_Z_CHAR); //control to check uppercase letter
            ptxt_char_is_lowercase_letter = (*ptxt >= LOWERCASE_A_CHAR) && (*ptxt <= LOWERCASE_Z_CHAR); //control to check lowercase letter
            ptxt_char_is_letter = ptxt_char_is_uppercase_letter || ptxt_char_is_lowercase_letter;
            err_invalid_ptxt_char = !ptxt_char_is_letter; //generation of the err_invalid_ptxt_char signal

            /* case d1 = 0, d3 = 0*/
            if(!d1 && !d3){
                printf("ptxt: %s\n",ptxt);
                char supporto[2];
                char ptxt2[1];
                char ptxt3[1];
                char ptxt4[1];
                memset(ptxt2,0, sizeof(ptxt2));
                memset(ptxt3,0, sizeof(ptxt3));
                memset(ptxt4,0, sizeof(ptxt4));
                strncpy(ptxt2,ptxt,1);
                strncpy(ptxt3,ptxt,1);
                strncpy(ptxt4,ptxt,1);
                memset(supporto,0, sizeof(supporto));
                sprintf(supporto, "%d", *ptxt + shift1 + shift2 + shift3);
                *ctxt = (char) atoi(supporto);
                ctxt[1]='\0';
                if(ptxt_char_is_uppercase_letter && (atoi(supporto) > UPPERCASE_Z_CHAR)){ //check if is over the range [A-B]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 + shift1 + shift2 + shift3 -26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_uppercase_letter && (atoi(supporto) > UPPERCASE_Z_CHAR)){ //check if is over the range [A-B]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 + shift1 + shift2 + shift3 - 52);
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                        if(ptxt_char_is_uppercase_letter && (atoi(supporto) > UPPERCASE_Z_CHAR)){ //check if is over the range [A-B]
                            memset(ctxt,0,sizeof(ctxt));
                            memset(supporto,0, sizeof(supporto));
                            sprintf(supporto, "%d", *ptxt4 + shift1 + shift2 + shift3 - 78);
                            *ctxt = (char) atoi(supporto);
                            ctxt[1]='\0';
                        }
                    }
                }
                if(ptxt_char_is_lowercase_letter && (atoi(supporto) > LOWERCASE_Z_CHAR)){ //check if is over the range [a-b]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 + shift1 + shift2 + shift3 -26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_lowercase_letter && (atoi(supporto) > LOWERCASE_Z_CHAR)){ //check if is over the range [a-b]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 + shift1 + shift2 + shift3 - 52);
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                        if(ptxt_char_is_lowercase_letter && (atoi(supporto) > LOWERCASE_Z_CHAR)){ //check if is over the range [a-b]
                            memset(ctxt,0,sizeof(ctxt));
                            memset(supporto,0, sizeof(supporto));
                            sprintf(supporto, "%d", *ptxt4 + shift1 + shift2 + shift3 - 78);
                            *ctxt = (char) atoi(supporto);
                            ctxt[1]='\0';
                        }
                    }
                }
            }

            /* case d1 = 0, d3 = 1*/
            if(!d1 && d3){
                printf("ptxt: %s\n",ptxt);
                char supporto[2];
                char ptxt2[1];
                memset(ptxt2,0, sizeof(ptxt2));
                strncpy(ptxt2,ptxt,1);
                char ptxt3[1];
                memset(ptxt3,0, sizeof(ptxt3));
                strncpy(ptxt3,ptxt,1);
                memset(supporto,0, sizeof(supporto));
                sprintf(supporto, "%d", *ptxt + shift1 - shift2 - shift3);
                *ctxt = (char) atoi(supporto);
                ctxt[1]='\0';              
                if(ptxt_char_is_uppercase_letter && (atoi(supporto) > UPPERCASE_Z_CHAR)){ //check if is over the range [A-B]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 + shift1 - shift2 - shift3 -26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_uppercase_letter && (atoi(supporto) > UPPERCASE_Z_CHAR)){ //check if is over the range [A-B]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 + shift1 - shift2 - shift3 -52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_lowercase_letter && (atoi(supporto) > LOWERCASE_Z_CHAR)){ //check if is over the range [a-b]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 + shift1 - shift2 - shift3 -26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_lowercase_letter && (atoi(supporto) > LOWERCASE_Z_CHAR)){ ////check if is over the range [a-b]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 + shift1 - shift2 - shift3 -52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_uppercase_letter && (atoi(supporto) < UPPERCASE_A_CHAR)){ //check if is over the range [A-B]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 + shift1 - shift2 - shift3 +26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_uppercase_letter && (atoi(supporto) < UPPERCASE_A_CHAR)){ //check if is over the range [A-B]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 + shift1 - shift2 - shift3 +52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_lowercase_letter && (atoi(supporto) < LOWERCASE_A_CHAR)){ //check if is over the range [a-b]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 + shift1 - shift2 - shift3 +26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_lowercase_letter && (atoi(supporto) < LOWERCASE_A_CHAR)){ //check if is over the range [a-b]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 + shift1 - shift2 - shift3 +52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
            }

            /* case d1 = 1, d3 = 0*/
             if(d1 && !d3){              
                printf("ptxt: %s\n",ptxt);
                char supporto[2];
                char ptxt2[1];
                memset(ptxt2,0, sizeof(ptxt2));
                strncpy(ptxt2,ptxt,1);
                char ptxt3[1];
                memset(ptxt3,0, sizeof(ptxt3));
                strncpy(ptxt3,ptxt,1);
                memset(supporto,0, sizeof(supporto));
                sprintf(supporto, "%d", *ptxt - shift1 - shift2 + shift3);
                *ctxt = (char) atoi(supporto);
                ctxt[1]='\0';              
                if(ptxt_char_is_uppercase_letter && (atoi(supporto) > UPPERCASE_Z_CHAR)){ //check if is over the range [A-B]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 - shift1 - shift2 + shift3 -26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_uppercase_letter && (atoi(supporto) > UPPERCASE_Z_CHAR)){ //check if is over the range [A-B]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 - shift1 - shift2 + shift3 -52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_lowercase_letter && (atoi(supporto) > LOWERCASE_Z_CHAR)){ //check if is over the range [a-b]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 - shift1 - shift2 + shift3 -26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_lowercase_letter && (atoi(supporto) > LOWERCASE_Z_CHAR)){ //check if is over the range [a-b]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 - shift1 - shift2 + shift3 -52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_uppercase_letter && (atoi(supporto) < UPPERCASE_A_CHAR)){ //check if is over the range [A-B]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 - shift1 - shift2 + shift3 +26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_uppercase_letter && (atoi(supporto) < UPPERCASE_A_CHAR)){ //check if is over the range [A-B]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 - shift1 - shift2 + shift3 +52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_lowercase_letter && (atoi(supporto) < LOWERCASE_A_CHAR)){ //check if is over the range [a-b]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 - shift1 - shift2 + shift3 +26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_lowercase_letter && (atoi(supporto) < LOWERCASE_A_CHAR)){ //check if is over the range [a-b]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 - shift1 - shift2 + shift3 +52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
            }
            
            /* caso d1 = 1, d3 = 1*/
             if(d1 && d3){
                printf("ptxt: %s\n",ptxt);
                char supporto[2];
                char ptxt2[1];
                char ptxt3[1];
                memset(ptxt2,0, sizeof(ptxt2));
                memset(ptxt3,0, sizeof(ptxt3));
                strncpy(ptxt2,ptxt,1);
                strncpy(ptxt3,ptxt,1);
                memset(supporto,0, sizeof(supporto));
                sprintf(supporto, "%d", *ptxt - shift1 + shift2 - shift3);
                *ctxt = (char) atoi(supporto);
                ctxt[1]='\0';
                if(ptxt_char_is_uppercase_letter && (atoi(supporto) < UPPERCASE_A_CHAR)){ //check if is over the range [A-B]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 - shift1 + shift2 - shift3 +26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_uppercase_letter && (atoi(supporto) < UPPERCASE_A_CHAR)){ //check if is over the range [A-b]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 - shift1 + shift2 - shift3 + 52);
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_lowercase_letter && (atoi(supporto) < LOWERCASE_A_CHAR)){ //check if is over the range [a-b]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 - shift1 + shift2 - shift3 +26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_lowercase_letter && (atoi(supporto) < LOWERCASE_A_CHAR)){ //check if is over the range [a-b]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 - shift1 + shift2 - shift3 +52);
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
            }

            if(err_invalid_ptxt_char || err_invalid_key_shift_num){
                printf("ctxt: \n");
                fwrite(" ",sizeof(char),1,fd2);
            }
            else{
                printf("ctxt: %s\n",ctxt);
                fwrite(ctxt,sizeof(char),1,fd2);
            }
            memset(ptxt,0,sizeof(ptxt));

        }
        printf("Cifratura finita\n");
        fclose(fd);
        fclose(fd2);
        

    }else{ //decrypt

        printf("Decifratura on\n");

        fd2 = fopen("enc.txt","r");
        fd3 = fopen("dec.txt","w");
        fclose(fd3);
        fd3 = fopen("dec.txt","a+");

        
        while((*ptxt = fgetc(fd2)) != EOF){

            ptxt[1]='\0';

            memset(ctxt,0,sizeof(ctxt));

            ptxt_char_is_uppercase_letter = (*ptxt >= UPPERCASE_A_CHAR) && (*ptxt <= UPPERCASE_Z_CHAR); //control to check uppercase letter
            ptxt_char_is_lowercase_letter = (*ptxt >= LOWERCASE_A_CHAR) && (*ptxt <= LOWERCASE_Z_CHAR); //control to check lowercase letter
            ptxt_char_is_letter = ptxt_char_is_uppercase_letter || ptxt_char_is_lowercase_letter;
            err_invalid_ptxt_char = !ptxt_char_is_letter; //generation of the err_invalid_ptxt_char signal

            /* case d1 = 0, d3 = 0*/
            if(!d1 && !d3){
                printf("ptxt: %s\n",ptxt);
                char supporto[2];
                char ptxt2[1];
                char ptxt3[1];
                char ptxt4[1];
                memset(ptxt2,0, sizeof(ptxt2));
                memset(ptxt3,0, sizeof(ptxt3));
                memset(ptxt4,0, sizeof(ptxt4));
                strncpy(ptxt2,ptxt,1);
                strncpy(ptxt3,ptxt,1);
                strncpy(ptxt4,ptxt,1);
                memset(supporto,0, sizeof(supporto));
                sprintf(supporto, "%d", *ptxt - shift1 - shift2 - shift3);
                *ctxt = (char) atoi(supporto);
                ctxt[1]='\0';
                if(ptxt_char_is_uppercase_letter && (atoi(supporto) < UPPERCASE_A_CHAR)){ //check if is over the range [A-B]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 - shift1 - shift2 - shift3 + 26);
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_uppercase_letter && (atoi(supporto) < UPPERCASE_A_CHAR)){ //check if is over the range [A-B]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 - shift1 - shift2 - shift3 + 52);
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                        if(ptxt_char_is_uppercase_letter && (atoi(supporto) < UPPERCASE_A_CHAR)){ //check if is over the range [A-B]
                            memset(ctxt,0,sizeof(ctxt));
                            memset(supporto,0, sizeof(supporto));
                            sprintf(supporto, "%d", *ptxt4 - shift1 - shift2 - shift3 + 78);
                            *ctxt = (char) atoi(supporto);
                            ctxt[1]='\0';
                        }
                    }
                }
                if(ptxt_char_is_lowercase_letter && (atoi(supporto) < LOWERCASE_A_CHAR)){ //check if is over the range [a-b]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 - shift1 - shift2 - shift3 + 26);
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_lowercase_letter && (atoi(supporto) < LOWERCASE_A_CHAR)){ //check if is over the range [a-b]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 - shift1 - shift2 - shift3 + 52);
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                        if(ptxt_char_is_lowercase_letter && (atoi(supporto) < LOWERCASE_A_CHAR)){ //check if is over the range [a-b]
                            memset(ctxt,0,sizeof(ctxt));
                            memset(supporto,0, sizeof(supporto));
                            sprintf(supporto, "%d", *ptxt4 - shift1 - shift2 - shift3 + 78);
                            *ctxt = (char) atoi(supporto);
                            ctxt[1]='\0';
                        }
                    }
                }
            }
                
            

            /* case d1 = 0, d3 = 1*/
            if(!d1 && d3){
                printf("ptxt: %s\n",ptxt);
                char supporto[2];
                char ptxt2[1];
                memset(ptxt2,0, sizeof(ptxt2));
                strncpy(ptxt2,ptxt,1);
                char ptxt3[1];
                memset(ptxt3,0, sizeof(ptxt3));
                strncpy(ptxt3,ptxt,1);
                memset(supporto,0, sizeof(supporto));
                sprintf(supporto, "%d", *ptxt - shift1 + shift2 + shift3);
                *ctxt = (char) atoi(supporto);
                ctxt[1]='\0';              
                if(ptxt_char_is_uppercase_letter && (atoi(supporto) > UPPERCASE_Z_CHAR)){ //check if is over the range [A-B]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 - shift1 + shift2 + shift3 -26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_uppercase_letter && (atoi(supporto) > UPPERCASE_Z_CHAR)){ //check if is over the range [A-B]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 - shift1 + shift2 + shift3 -52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_lowercase_letter && (atoi(supporto) > LOWERCASE_Z_CHAR)){ //check if is over the range [a-b]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 - shift1 + shift2 + shift3 -26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_lowercase_letter && (atoi(supporto) > LOWERCASE_Z_CHAR)){ //check if is over the range [a-b]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 - shift1 + shift2 + shift3 -52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_uppercase_letter && (atoi(supporto) < UPPERCASE_A_CHAR)){ //check if is over the range [A-B]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 - shift1 + shift2 + shift3 +26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_uppercase_letter && (atoi(supporto) < UPPERCASE_A_CHAR)){ //check if is over the range [A-B]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 - shift1 + shift2 + shift3 +52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_lowercase_letter && (atoi(supporto) < LOWERCASE_A_CHAR)){ //check if is over the range [a-b]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 - shift1 + shift2 + shift3 +26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_lowercase_letter && (atoi(supporto) < LOWERCASE_A_CHAR)){ //check if is over the range [a-b]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 - shift1 + shift2 + shift3 +52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
            }
            

            /* case d1 = 1, d3 = 0*/
            if(d1 && !d3){
                printf("ptxt: %s\n",ptxt);
                char supporto[2];
                char ptxt2[1];
                memset(ptxt2,0, sizeof(ptxt2));
                strncpy(ptxt2,ptxt,1);
                char ptxt3[1];
                memset(ptxt3,0, sizeof(ptxt3));
                strncpy(ptxt3,ptxt,1);
                memset(supporto,0, sizeof(supporto));
                sprintf(supporto, "%d", *ptxt + shift1 + shift2 - shift3);
                *ctxt = (char) atoi(supporto);
                ctxt[1]='\0';              
                if(ptxt_char_is_uppercase_letter && (atoi(supporto) > UPPERCASE_Z_CHAR)){ //check if is over the range [A-B]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 + shift1 + shift2 - shift3 -26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_uppercase_letter && (atoi(supporto) > UPPERCASE_Z_CHAR)){ //check if is over the range [A-B]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 + shift1 + shift2 - shift3 -52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_lowercase_letter && (atoi(supporto) > LOWERCASE_Z_CHAR)){ //check if is over the range [a-b]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 + shift1 + shift2 - shift3 -26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_lowercase_letter && (atoi(supporto) > LOWERCASE_Z_CHAR)){ //check if is over the range [a-b]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 + shift1 + shift2 - shift3 -52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_uppercase_letter && (atoi(supporto) < UPPERCASE_A_CHAR)){ //check if is over the range [A-B]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 + shift1 + shift2 - shift3 +26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_uppercase_letter && (atoi(supporto) < UPPERCASE_A_CHAR)){ //check if is over the range [A-B]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 + shift1 + shift2 - shift3 +52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_lowercase_letter && (atoi(supporto) < LOWERCASE_A_CHAR)){ //check if is over the range [a-b]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 + shift1 + shift2 - shift3 +26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_lowercase_letter && (atoi(supporto) < LOWERCASE_A_CHAR)){ //check if is over the range [a-b]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 + shift1 + shift2 - shift3 +52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
            }
            

            /* caso d1 = 1, d3 = 1*/
            if(d1 && d3){
                printf("ptxt: %s\n",ptxt);
                char supporto[2];
                char ptxt2[1];
                char ptxt3[1];
                memset(ptxt2,0, sizeof(ptxt2));
                memset(ptxt3,0, sizeof(ptxt3));
                strncpy(ptxt2,ptxt,1);
                strncpy(ptxt3,ptxt,1);
                memset(supporto,0, sizeof(supporto));
                sprintf(supporto, "%d", *ptxt + shift1 - shift2 + shift3);
                *ctxt = (char) atoi(supporto);
                ctxt[1]='\0';              
                if(ptxt_char_is_uppercase_letter && (atoi(supporto) > UPPERCASE_Z_CHAR)){ //check if is over the range [A-B]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 + shift1 - shift2 + shift3 -26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_uppercase_letter && (atoi(supporto) > UPPERCASE_Z_CHAR)){ //check if is over the range [A-B]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 + shift1 - shift2 + shift3 - 52);
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_lowercase_letter && (atoi(supporto) > LOWERCASE_Z_CHAR)){ //check if is over the range [a-b]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 + shift1 - shift2 + shift3 -26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_lowercase_letter && (atoi(supporto) > LOWERCASE_Z_CHAR)){ //check if is over the range [a-b]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 + shift1 - shift2 + shift3 - 52);
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
            }

            if(err_invalid_ptxt_char || err_invalid_key_shift_num){
                printf("ctxt: \n");
                fwrite(" ",sizeof(char),1,fd3);
            }
            else{
                printf("ctxt: %s\n",ctxt);
                fwrite(ctxt,sizeof(char),1,fd3);
            }
            memset(ptxt,0,sizeof(ptxt));

        }

        printf("Decifratura finita\n");
        fclose(fd2);
        fclose(fd3);
    }  

    if(!mode){ //encryption_second file

    printf("Cifratura_2 on\n");

        char stringa_prova[54];
        randstring_2(stringa_prova);
        fd = fopen("./prova2.txt","w"); 
        fwrite(stringa_prova,sizeof(char),54,fd); //the file prova.txt is written with a random vector
        fclose(fd);
        fd = fopen("./prova2.txt","r");
        fd2 = fopen("enc2.txt","w");
        fclose(fd2);
        fd2 = fopen("enc2.txt","a+");
    
        //read char by char the file prova.txt
        while((*ptxt = fgetc(fd)) != EOF){

            ptxt[1]='\0';

            memset(ctxt,0,sizeof(ctxt));

            ptxt_char_is_uppercase_letter = (*ptxt >= UPPERCASE_A_CHAR) && (*ptxt <= UPPERCASE_Z_CHAR); //control to check uppercase letter
            ptxt_char_is_lowercase_letter = (*ptxt >= LOWERCASE_A_CHAR) && (*ptxt <= LOWERCASE_Z_CHAR); //control to check lowercase letter
            ptxt_char_is_letter = ptxt_char_is_uppercase_letter || ptxt_char_is_lowercase_letter;
            err_invalid_ptxt_char = !ptxt_char_is_letter; //generation of the err_invalid_ptxt_char signal

            /* case d1 = 0, d3 = 0*/
            if(!d1 && !d3){
                printf("ptxt: %s\n",ptxt);
                char supporto[2];
                char ptxt2[1];
                char ptxt3[1];
                char ptxt4[1];
                memset(ptxt2,0, sizeof(ptxt2));
                memset(ptxt3,0, sizeof(ptxt3));
                memset(ptxt4,0, sizeof(ptxt4));
                strncpy(ptxt2,ptxt,1);
                strncpy(ptxt3,ptxt,1);
                strncpy(ptxt4,ptxt,1);
                memset(supporto,0, sizeof(supporto));
                sprintf(supporto, "%d", *ptxt + shift1 + shift2 + shift3);
                *ctxt = (char) atoi(supporto);
                ctxt[1]='\0';
                if(ptxt_char_is_uppercase_letter && (atoi(supporto) > UPPERCASE_Z_CHAR)){ //check if is over the range [A-B]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 + shift1 + shift2 + shift3 -26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_uppercase_letter && (atoi(supporto) > UPPERCASE_Z_CHAR)){ //check if is over the range [A-B]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 + shift1 + shift2 + shift3 - 52);
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                        if(ptxt_char_is_uppercase_letter && (atoi(supporto) > UPPERCASE_Z_CHAR)){ //check if is over the range [A-B]
                            memset(ctxt,0,sizeof(ctxt));
                            memset(supporto,0, sizeof(supporto));
                            sprintf(supporto, "%d", *ptxt4 + shift1 + shift2 + shift3 - 78);
                            *ctxt = (char) atoi(supporto);
                            ctxt[1]='\0';
                        }
                    }
                }
                if(ptxt_char_is_lowercase_letter && (atoi(supporto) > LOWERCASE_Z_CHAR)){ //check if is over the range [a-b]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 + shift1 + shift2 + shift3 -26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_lowercase_letter && (atoi(supporto) > LOWERCASE_Z_CHAR)){ //check if is over the range [a-b]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 + shift1 + shift2 + shift3 - 52);
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                        if(ptxt_char_is_lowercase_letter && (atoi(supporto) > LOWERCASE_Z_CHAR)){ //check if is over the range [a-b]
                            memset(ctxt,0,sizeof(ctxt));
                            memset(supporto,0, sizeof(supporto));
                            sprintf(supporto, "%d", *ptxt4 + shift1 + shift2 + shift3 - 78);
                            *ctxt = (char) atoi(supporto);
                            ctxt[1]='\0';
                        }
                    }
                }
            }

            /* case d1 = 0, d3 = 1*/
            if(!d1 && d3){
                printf("ptxt: %s\n",ptxt);
                char supporto[2];
                char ptxt2[1];
                memset(ptxt2,0, sizeof(ptxt2));
                strncpy(ptxt2,ptxt,1);
                char ptxt3[1];
                memset(ptxt3,0, sizeof(ptxt3));
                strncpy(ptxt3,ptxt,1);
                memset(supporto,0, sizeof(supporto));
                sprintf(supporto, "%d", *ptxt + shift1 - shift2 - shift3);
                *ctxt = (char) atoi(supporto);
                ctxt[1]='\0';              
                if(ptxt_char_is_uppercase_letter && (atoi(supporto) > UPPERCASE_Z_CHAR)){ //check if is over the range [A-B]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 + shift1 - shift2 - shift3 -26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_uppercase_letter && (atoi(supporto) > UPPERCASE_Z_CHAR)){ //check if is over the range [A-B]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 + shift1 - shift2 - shift3 -52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_lowercase_letter && (atoi(supporto) > LOWERCASE_Z_CHAR)){ //check if is over the range [a-b]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 + shift1 - shift2 - shift3 -26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_lowercase_letter && (atoi(supporto) > LOWERCASE_Z_CHAR)){ ////check if is over the range [a-b]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 + shift1 - shift2 - shift3 -52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_uppercase_letter && (atoi(supporto) < UPPERCASE_A_CHAR)){ //check if is over the range [A-B]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 + shift1 - shift2 - shift3 +26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_uppercase_letter && (atoi(supporto) < UPPERCASE_A_CHAR)){ //check if is over the range [A-B]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 + shift1 - shift2 - shift3 +52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_lowercase_letter && (atoi(supporto) < LOWERCASE_A_CHAR)){ //check if is over the range [a-b]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 + shift1 - shift2 - shift3 +26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_lowercase_letter && (atoi(supporto) < LOWERCASE_A_CHAR)){ //check if is over the range [a-b]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 + shift1 - shift2 - shift3 +52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
            }

            /* case d1 = 1, d3 = 0*/
             if(d1 && !d3){              
                printf("ptxt: %s\n",ptxt);
                char supporto[2];
                char ptxt2[1];
                memset(ptxt2,0, sizeof(ptxt2));
                strncpy(ptxt2,ptxt,1);
                char ptxt3[1];
                memset(ptxt3,0, sizeof(ptxt3));
                strncpy(ptxt3,ptxt,1);
                memset(supporto,0, sizeof(supporto));
                sprintf(supporto, "%d", *ptxt - shift1 - shift2 + shift3);
                *ctxt = (char) atoi(supporto);
                ctxt[1]='\0';              
                if(ptxt_char_is_uppercase_letter && (atoi(supporto) > UPPERCASE_Z_CHAR)){ //check if is over the range [A-B]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 - shift1 - shift2 + shift3 -26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_uppercase_letter && (atoi(supporto) > UPPERCASE_Z_CHAR)){ //check if is over the range [A-B]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 - shift1 - shift2 + shift3 -52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_lowercase_letter && (atoi(supporto) > LOWERCASE_Z_CHAR)){ //check if is over the range [a-b]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 - shift1 - shift2 + shift3 -26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_lowercase_letter && (atoi(supporto) > LOWERCASE_Z_CHAR)){ //check if is over the range [a-b]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 - shift1 - shift2 + shift3 -52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_uppercase_letter && (atoi(supporto) < UPPERCASE_A_CHAR)){ //check if is over the range [A-B]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 - shift1 - shift2 + shift3 +26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_uppercase_letter && (atoi(supporto) < UPPERCASE_A_CHAR)){ //check if is over the range [A-B]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 - shift1 - shift2 + shift3 +52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_lowercase_letter && (atoi(supporto) < LOWERCASE_A_CHAR)){ //check if is over the range [a-b]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 - shift1 - shift2 + shift3 +26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_lowercase_letter && (atoi(supporto) < LOWERCASE_A_CHAR)){ //check if is over the range [a-b]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 - shift1 - shift2 + shift3 +52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
            }
            
            /* caso d1 = 1, d3 = 1*/
             if(d1 && d3){
                printf("ptxt: %s\n",ptxt);
                char supporto[2];
                char ptxt2[1];
                char ptxt3[1];
                memset(ptxt2,0, sizeof(ptxt2));
                memset(ptxt3,0, sizeof(ptxt3));
                strncpy(ptxt2,ptxt,1);
                strncpy(ptxt3,ptxt,1);
                memset(supporto,0, sizeof(supporto));
                sprintf(supporto, "%d", *ptxt - shift1 + shift2 - shift3);
                *ctxt = (char) atoi(supporto);
                ctxt[1]='\0';
                if(ptxt_char_is_uppercase_letter && (atoi(supporto) < UPPERCASE_A_CHAR)){ //check if is over the range [A-B]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 - shift1 + shift2 - shift3 +26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_uppercase_letter && (atoi(supporto) < UPPERCASE_A_CHAR)){ //check if is over the range [A-b]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 - shift1 + shift2 - shift3 + 52);
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_lowercase_letter && (atoi(supporto) < LOWERCASE_A_CHAR)){ //check if is over the range [a-b]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 - shift1 + shift2 - shift3 +26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_lowercase_letter && (atoi(supporto) < LOWERCASE_A_CHAR)){ //check if is over the range [a-b]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 - shift1 + shift2 - shift3 +52);
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
            }

            if(err_invalid_ptxt_char || err_invalid_key_shift_num){
                printf("ctxt: \n");
                fwrite(" ",sizeof(char),1,fd2);
            }
            else{
                printf("ctxt: %s\n",ctxt);
                fwrite(ctxt,sizeof(char),1,fd2);
            }
            memset(ptxt,0,sizeof(ptxt));

        }
        printf("Cifratura_2 finita\n");
        fclose(fd);
        fclose(fd2);
        exit(1);

    }else{ //decrypt

        printf("Decifratura_2 on\n");

        fd2 = fopen("enc2.txt","r");
        fd3 = fopen("dec2.txt","w");
        fclose(fd3);
        fd3 = fopen("dec2.txt","a+");

        
        while((*ptxt = fgetc(fd2)) != EOF){

            ptxt[1]='\0';

            memset(ctxt,0,sizeof(ctxt));

            ptxt_char_is_uppercase_letter = (*ptxt >= UPPERCASE_A_CHAR) && (*ptxt <= UPPERCASE_Z_CHAR); //control to check uppercase letter
            ptxt_char_is_lowercase_letter = (*ptxt >= LOWERCASE_A_CHAR) && (*ptxt <= LOWERCASE_Z_CHAR); //control to check lowercase letter
            ptxt_char_is_letter = ptxt_char_is_uppercase_letter || ptxt_char_is_lowercase_letter;
            err_invalid_ptxt_char = !ptxt_char_is_letter; //generation of the err_invalid_ptxt_char signal

            /* case d1 = 0, d3 = 0*/
            if(!d1 && !d3){
                printf("ptxt: %s\n",ptxt);
                char supporto[2];
                char ptxt2[1];
                char ptxt3[1];
                char ptxt4[1];
                memset(ptxt2,0, sizeof(ptxt2));
                memset(ptxt3,0, sizeof(ptxt3));
                memset(ptxt4,0, sizeof(ptxt4));
                strncpy(ptxt2,ptxt,1);
                strncpy(ptxt3,ptxt,1);
                strncpy(ptxt4,ptxt,1);
                memset(supporto,0, sizeof(supporto));
                sprintf(supporto, "%d", *ptxt - shift1 - shift2 - shift3);
                *ctxt = (char) atoi(supporto);
                ctxt[1]='\0';
                if(ptxt_char_is_uppercase_letter && (atoi(supporto) < UPPERCASE_A_CHAR)){ //check if is over the range [A-B]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 - shift1 - shift2 - shift3 + 26);
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_uppercase_letter && (atoi(supporto) < UPPERCASE_A_CHAR)){ //check if is over the range [A-B]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 - shift1 - shift2 - shift3 + 52);
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                        if(ptxt_char_is_uppercase_letter && (atoi(supporto) < UPPERCASE_A_CHAR)){ //check if is over the range [A-B]
                            memset(ctxt,0,sizeof(ctxt));
                            memset(supporto,0, sizeof(supporto));
                            sprintf(supporto, "%d", *ptxt4 - shift1 - shift2 - shift3 + 78);
                            *ctxt = (char) atoi(supporto);
                            ctxt[1]='\0';
                        }
                    }
                }
                if(ptxt_char_is_lowercase_letter && (atoi(supporto) < LOWERCASE_A_CHAR)){ //check if is over the range [a-b]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 - shift1 - shift2 - shift3 + 26);
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_lowercase_letter && (atoi(supporto) < LOWERCASE_A_CHAR)){ //check if is over the range [a-b]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 - shift1 - shift2 - shift3 + 52);
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                        if(ptxt_char_is_lowercase_letter && (atoi(supporto) < LOWERCASE_A_CHAR)){ //check if is over the range [a-b]
                            memset(ctxt,0,sizeof(ctxt));
                            memset(supporto,0, sizeof(supporto));
                            sprintf(supporto, "%d", *ptxt4 - shift1 - shift2 - shift3 + 78);
                            *ctxt = (char) atoi(supporto);
                            ctxt[1]='\0';
                        }
                    }
                }
            }
                
            

            /* case d1 = 0, d3 = 1*/
            if(!d1 && d3){
                printf("ptxt: %s\n",ptxt);
                char supporto[2];
                char ptxt2[1];
                memset(ptxt2,0, sizeof(ptxt2));
                strncpy(ptxt2,ptxt,1);
                char ptxt3[1];
                memset(ptxt3,0, sizeof(ptxt3));
                strncpy(ptxt3,ptxt,1);
                memset(supporto,0, sizeof(supporto));
                sprintf(supporto, "%d", *ptxt - shift1 + shift2 + shift3);
                *ctxt = (char) atoi(supporto);
                ctxt[1]='\0';              
                if(ptxt_char_is_uppercase_letter && (atoi(supporto) > UPPERCASE_Z_CHAR)){ //check if is over the range [A-B]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 - shift1 + shift2 + shift3 -26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_uppercase_letter && (atoi(supporto) > UPPERCASE_Z_CHAR)){ //check if is over the range [A-B]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 - shift1 + shift2 + shift3 -52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_lowercase_letter && (atoi(supporto) > LOWERCASE_Z_CHAR)){ //check if is over the range [a-b]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 - shift1 + shift2 + shift3 -26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_lowercase_letter && (atoi(supporto) > LOWERCASE_Z_CHAR)){ //check if is over the range [a-b]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 - shift1 + shift2 + shift3 -52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_uppercase_letter && (atoi(supporto) < UPPERCASE_A_CHAR)){ //check if is over the range [A-B]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 - shift1 + shift2 + shift3 +26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_uppercase_letter && (atoi(supporto) < UPPERCASE_A_CHAR)){ //check if is over the range [A-B]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 - shift1 + shift2 + shift3 +52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_lowercase_letter && (atoi(supporto) < LOWERCASE_A_CHAR)){ //check if is over the range [a-b]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 - shift1 + shift2 + shift3 +26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_lowercase_letter && (atoi(supporto) < LOWERCASE_A_CHAR)){ //check if is over the range [a-b]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 - shift1 + shift2 + shift3 +52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
            }
            

            /* case d1 = 1, d3 = 0*/
            if(d1 && !d3){
                printf("ptxt: %s\n",ptxt);
                char supporto[2];
                char ptxt2[1];
                memset(ptxt2,0, sizeof(ptxt2));
                strncpy(ptxt2,ptxt,1);
                char ptxt3[1];
                memset(ptxt3,0, sizeof(ptxt3));
                strncpy(ptxt3,ptxt,1);
                memset(supporto,0, sizeof(supporto));
                sprintf(supporto, "%d", *ptxt + shift1 + shift2 - shift3);
                *ctxt = (char) atoi(supporto);
                ctxt[1]='\0';              
                if(ptxt_char_is_uppercase_letter && (atoi(supporto) > UPPERCASE_Z_CHAR)){ //check if is over the range [A-B]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 + shift1 + shift2 - shift3 -26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_uppercase_letter && (atoi(supporto) > UPPERCASE_Z_CHAR)){ //check if is over the range [A-B]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 + shift1 + shift2 - shift3 -52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_lowercase_letter && (atoi(supporto) > LOWERCASE_Z_CHAR)){ //check if is over the range [a-b]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 + shift1 + shift2 - shift3 -26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_lowercase_letter && (atoi(supporto) > LOWERCASE_Z_CHAR)){ //check if is over the range [a-b]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 + shift1 + shift2 - shift3 -52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_uppercase_letter && (atoi(supporto) < UPPERCASE_A_CHAR)){ //check if is over the range [A-B]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 + shift1 + shift2 - shift3 +26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_uppercase_letter && (atoi(supporto) < UPPERCASE_A_CHAR)){ //check if is over the range [A-B]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 + shift1 + shift2 - shift3 +52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_lowercase_letter && (atoi(supporto) < LOWERCASE_A_CHAR)){ //check if is over the range [a-b]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 + shift1 + shift2 - shift3 +26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_lowercase_letter && (atoi(supporto) < LOWERCASE_A_CHAR)){ //check if is over the range [a-b]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 + shift1 + shift2 - shift3 +52 );
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
            }
            

            /* caso d1 = 1, d3 = 1*/
            if(d1 && d3){
                printf("ptxt: %s\n",ptxt);
                char supporto[2];
                char ptxt2[1];
                char ptxt3[1];
                memset(ptxt2,0, sizeof(ptxt2));
                memset(ptxt3,0, sizeof(ptxt3));
                strncpy(ptxt2,ptxt,1);
                strncpy(ptxt3,ptxt,1);
                memset(supporto,0, sizeof(supporto));
                sprintf(supporto, "%d", *ptxt + shift1 - shift2 + shift3);
                *ctxt = (char) atoi(supporto);
                ctxt[1]='\0';              
                if(ptxt_char_is_uppercase_letter && (atoi(supporto) > UPPERCASE_Z_CHAR)){ //check if is over the range [A-B]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 + shift1 - shift2 + shift3 -26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_uppercase_letter && (atoi(supporto) > UPPERCASE_Z_CHAR)){ //check if is over the range [A-B]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 + shift1 - shift2 + shift3 - 52);
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
                if(ptxt_char_is_lowercase_letter && (atoi(supporto) > LOWERCASE_Z_CHAR)){ //check if is over the range [a-b]
                    memset(ctxt,0,sizeof(ctxt));
                    memset(supporto,0, sizeof(supporto));
                    sprintf(supporto, "%d", *ptxt2 + shift1 - shift2 + shift3 -26 );
                    *ctxt = (char) atoi(supporto);
                    ctxt[1]='\0';
                    if(ptxt_char_is_lowercase_letter && (atoi(supporto) > LOWERCASE_Z_CHAR)){ //check if is over the range [a-b]
                        memset(ctxt,0,sizeof(ctxt));
                        memset(supporto,0, sizeof(supporto));
                        sprintf(supporto, "%d", *ptxt3 + shift1 - shift2 + shift3 - 52);
                        *ctxt = (char) atoi(supporto);
                        ctxt[1]='\0';
                    }
                }
            }

            if(err_invalid_ptxt_char || err_invalid_key_shift_num){
                printf("ctxt: \n");
                fwrite(" ",sizeof(char),1,fd3);
            }
            else{
                printf("ctxt: %s\n",ctxt);
                fwrite(ctxt,sizeof(char),1,fd3);
            }
            memset(ptxt,0,sizeof(ptxt));

        }

        printf("Decifratura_2 finita\n");
        fclose(fd2);
        fclose(fd3);
        exit(1);
    }  
}
