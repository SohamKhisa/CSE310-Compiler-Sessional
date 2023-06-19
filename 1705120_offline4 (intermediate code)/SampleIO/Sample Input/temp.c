/*
int main(){
    int a,b,c;
    a=13;
    b=2;
	c=1;
    if(c < b--) {
        a++;
        println(c);
    }
    println(a);
    println(b);
}
*/

/*
int main(){
    int a,b,c;
    a=13;
    b=2;
	c=1;
    while((c+3)<a) {
        c++;
        println(c);
    }
    println(a);
    println(b);
}
*/


/*
int main(){
    int a,b,c;
    a=13;
    b=0;
	c=1;
    if(c-- > b) {
        a++;
        println(c);
    }
    println(a);
    println(b);
}

*/


/*
int arr[6];
int show(int n)
{
    if(n>=6)
    {
        return -1;
    }
    show(n+1);
    int x;
    x=arr[n];
    println(x);
    return -1;
}
int main()
{
    int j;
    for(j=0;j<6;j++)
    {
        arr[j]=j*j;
    }
    show(0);
    return 0;
}
*/


/*
int main()
{
    int d[20];
    d[0]=1;
    d[1]=2;
    d[2]=3;
    d[4]=4;
    d[d[2]+d[1]-d[0]]=50+d[4];
    int x;
    x=d[4];
    println(x);
    return 0;
}
*/


/*

int rec(int n)
{
    if(n > 1)
        return 2 + rec(n - 1);
    else
        return 2;
}
int main(){
    int a,b, r;
    a=5;
    b=2;

    r = rec(a);
    println(r);
    return 0;
}


*/