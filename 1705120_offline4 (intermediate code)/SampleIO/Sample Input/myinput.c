int y;

int add(int x, int y);

int mul(int x, int y);

int add(int x, int y)
{
    if(x>y) return x+y;
    return x+y;
}

int mul(int k, int j) {
    if(k>j) return k*j;
    else    return k*j;
}

int main()
{
    int a, i, b[10];
    int c;
    c=0;
    a=2;
    for(i=0; i<10; i++) {
        b[i] = c;
        c++;
        if(c>5) i=10;
        else b[i] = b[i] + add(a, c);
    }
    println(c);
    y = b[4];
    println(y);
    println(a);
}
