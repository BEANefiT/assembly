void	bprintf (char* msg, ...);

int main()
{
	char*	str = "Здарова";
	char	c = 'l';
	int	a = 0xeda;

	bprintf ("%s, wor%cd!\nbin = %b\noct = %o\ndec = %d\nlove = %x\n", str, c, a, a, a, a);
	
	return 0;
}
