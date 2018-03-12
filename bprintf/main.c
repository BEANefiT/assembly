int	bprintf (char* msg, ...);

int main()
{
	char*	str = "comes";
	char	c = '1';
	unsigned long long	a = 48858;

	bprintf ("%d\n", bprintf ("%x not %s %c\n",a, str, c) );
	
	return 0;
}
