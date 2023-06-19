int dosomething(int x, int y) {
	if(x>y)	return x;
	else if(x<y)	return y;
	return x+y;
}

int main()
{
	int x, y, c[1];
    y = 11;
    c[0] = y;
    c[0] = -c[0];
	x = 3 * dosomething(5, y) + 3;
	println(x);
    println(y);
    y = c[0];
    println(y);
	return 0;
}