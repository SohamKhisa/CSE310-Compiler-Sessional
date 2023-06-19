int main(){
    int a,b,c,i, j;
    b=0;
	c=1;
    for(i=0;i<4;i++){
        a++;
        for(j=0; j<3; j++) {
            b++;
        }
    }
    println(a);
    println(b);
    println(c);
}