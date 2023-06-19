int fun(int a, int b, int c)
{
    int x;
    if(a>=b && a>=c) return a;
    else if(b>=a && b>=c) return b;
    else    return c;
    x = 30;
    x = x -10;
}

int main()
{
    int a, b, c, x;
    a = 30;
    b = 40;
    c = 10;
    x = fun(a, b, c);
    println(x);
    return 0;
}